#!/usr/bin/env bash
# system.sh — Bootstrap script for fresh Debian (trixie+) or Arch Linux installs.
# Deploys core tools, desktop/server packages, hardware drivers, and hands off to chezmoi.
# Idempotent: safe to re-run at any stage.
set -euo pipefail

PREFIX="[system.sh]"

# ─── Helpers ───────────────────────────────────────────────────────────────────

have()       { command -v "$1" &>/dev/null; }
log_skip()   { echo "  ${PREFIX} SKIP: $*"; }
ask() {
    local reply; read -rp "$1 " reply
    [[ "${reply,,}" == "y" || "${reply,,}" == "yes" ]]
}

# ─── Distro Detection ──────────────────────────────────────────────────────────

detect_distro() {
    if [[ ! -f /etc/os-release ]]; then
        echo "${PREFIX} ERROR: /etc/os-release not found." >&2; exit 1
    fi
    # shellcheck disable=SC1091
    source /etc/os-release
    case "${ID,,}" in
        arch)   DISTRO="arch" ;;
        debian) DISTRO="debian" ;;
        *)
            if [[ "${ID_LIKE,,}" == *"arch"* ]];   then DISTRO="arch"
            elif [[ "${ID_LIKE,,}" == *"debian"* ]]; then DISTRO="debian"
            else echo "${PREFIX} ERROR: Unsupported distro '${ID}'." >&2; exit 1
            fi ;;
    esac
    echo "${PREFIX} Detected distro: ${DISTRO} (${PRETTY_NAME})"
}

# ─── Privilege Handling ────────────────────────────────────────────────────────

setup_privileges() {
    if [[ $EUID -eq 0 ]]; then SUDO=""; echo "${PREFIX} Running as root."; return; fi
    if have sudo; then SUDO="sudo"; echo "${PREFIX} Using sudo."; return; fi

    echo "${PREFIX} sudo not found — attempting to install (requires root password)..."
    if [[ $DISTRO == "arch" ]]; then pacman -S --noconfirm sudo
    else apt-get update -qq && apt-get install -y sudo; fi

    if have sudo; then
        echo "${PREFIX} sudo installed but NOT configured — add yourself to wheel/sudo group."
        echo "  sudo usermod -aG wheel $USER   # Arch"
        echo "  sudo usermod -aG sudo  $USER   # Debian"
        SUDO=""
    else
        echo "${PREFIX} ERROR: Cannot install sudo. Re-run as root to bootstrap sudo." >&2; exit 1
    fi
}

# ─── Package Install Wrappers ──────────────────────────────────────────────────

pkg_installed() {
    if [[ $DISTRO == "arch" ]]; then pacman -Q "$1" &>/dev/null
    else dpkg -s "$1" &>/dev/null 2>&1; fi
}

install_pkg() {
    local pkg="$1"
    if pkg_installed "$pkg"; then echo "  ${PREFIX} SKIP (installed): $pkg"; return; fi
    echo "  ${PREFIX} Installing: $pkg"
    if [[ $DISTRO == "arch" ]]; then $SUDO pacman -S --noconfirm "$pkg"
    else $SUDO apt-get install -y "$pkg"; fi
}

# Install a list of packages; besteffort=true logs skips instead of returning failure.
install_pkgs() {
    local besteffort="${1:-false}"; shift
    local failed=0
    for pkg in "$@"; do
        if ! install_pkg "$pkg"; then
            if [[ "$besteffort" == "true" ]]; then
                log_skip "$pkg — not available"
            else
                log_skip "$pkg — install failed"
                ((failed++)) || true
            fi
        fi
    done
    return $failed
}

# ─── Core Packages (always) ────────────────────────────────────────────────────

install_core() {
    echo ""; echo "${PREFIX} === CORE PACKAGES ==="
    # Refresh package index first — required before any installs
    if [[ $DISTRO == "debian" ]]; then
        echo "${PREFIX} Running: apt-get update"; $SUDO apt-get update -qq
    else
        echo "${PREFIX} Running: pacman -Syu"; $SUDO pacman -Syu --noconfirm
    fi

    install_pkgs false \
        git curl zsh tmux ripgrep fzf bat direnv unzip tar \
        openssh man-db git-lfs pciutils

    # fd has different package names per distro
    if [[ $DISTRO == "arch" ]]; then
        install_pkg "fd"
    else
        install_pkg "fd-find"
        # Debian ships fdfind; symlink to fd for consistency
        if have fdfind && [[ ! -e "$HOME/.local/bin/fd" ]]; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
            echo "${PREFIX} Symlink: ~/.local/bin/fd -> $(command -v fdfind)"
        fi
    fi
}

# ─── Desktop Packages ──────────────────────────────────────────────────────────

install_desktop() {
    echo ""; echo "${PREFIX} === DESKTOP PACKAGES ==="
    if [[ $DISTRO == "arch" ]]; then
        install_pkgs true \
            ly niri kitty waybar dunst rofi wpaperd \
            xdg-utils xdg-user-dirs polkit-gnome gnome-keyring \
            pipewire wireplumber pipewire-pulse playerctl \
            brightnessctl grim slurp qt6-wayland xwayland-satellite
    else
        # Debian: polkit-gnome → policykit-1-gnome
        install_pkgs false \
            xdg-utils xdg-user-dirs policykit-1-gnome gnome-keyring \
            pipewire wireplumber pipewire-pulse playerctl \
            brightnessctl grim slurp qt6-wayland
        # May not exist in Debian repos — attempt gracefully
        install_pkgs true \
            niri kitty waybar dunst rofi wpaperd xwayland-satellite
        # ly — may not be packaged on Debian
        install_pkgs true ly
    fi

    # Enable pipewire user services (systemd only)
    if have systemctl && [[ -n "${XDG_RUNTIME_DIR:-}" ]] && systemctl --user list-units &>/dev/null; then
        echo "${PREFIX} Enabling pipewire user services..."
        systemctl --user enable --now pipewire wireplumber pipewire-pulse 2>/dev/null || \
            log_skip "pipewire user services — session may not support it"
    else
        log_skip "pipewire user services — no systemd user session"
    fi

    install_fonts
}

install_fonts() {
    local fontdir="$HOME/.local/share/fonts" installed=false
    if [[ $DISTRO == "arch" ]]; then
        if install_pkg "ttf-sourcecodepro-nerd" && install_pkg "ttf-jetbrains-mono-nerd"; then
            installed=true
        fi
    fi
    # Debian: download from GitHub releases (nerd-fonts not in repos)
    if [[ $DISTRO == "debian" ]] || [[ "$installed" == "false" ]]; then
        local sauce="$fontdir/SauceCodeProNerdFontCompleteMono.ttf"
        local jetb="$fontdir/JetBrainsMonoNerdFontCompleteMono.ttf"
        if [[ -f "$sauce" && -f "$jetb" ]]; then
            log_skip "Nerd Fonts already present"; return
        fi
        echo "${PREFIX} Downloading Nerd Fonts from GitHub releases..."
        mkdir -p "$fontdir"
        local nf_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
        for font in SauceCodePro JetBrainsMono; do
            local dst="$fontdir/${font}NerdFontCompleteMono.ttf"
            [[ -f "$dst" ]] && continue
            echo "${PREFIX} Downloading ${font} Nerd Font..."
            if curl -fsSL "$nf_url/${font}.tar.xz" | tar -xOf - "*/${font}NerdFontCompleteMono.ttf" > "$dst" 2>/dev/null; then
                echo "${PREFIX} Installed: $font Nerd Font"
            else log_skip "$font Nerd Font — download failed"; fi
        done
        have fc-cache && fc-cache -f
    fi
}

# ─── Browsers (desktop only) ───────────────────────────────────────────────────

install_browsers() {
    echo ""; echo "${PREFIX} === BROWSERS ==="
    install_pkg "firefox"  # repo package on both distros

    if [[ $DISTRO == "arch" ]]; then
        install_pkg "vivaldi"
        install_pkg "librewolf"
    else
        install_vivaldi_debian
        install_librewolf_debian
    fi
}

install_vivaldi_debian() {
    local keyring="/usr/share/keyrings/vivaldi-archive-signing-keyring.gpg"
    local listfile="/etc/apt/sources.list.d/vivaldi.list"
    if ! $SUDO curl -fsSL https://repo.vivaldi.com/archive/vivaldi-archive_signing.key \
        | $SUDO gpg --dearmor -o "$keyring" 2>/dev/null; then
        log_skip "Vivaldi — could not add signing key"; return
    fi
    $SUDO bash -c "echo 'deb [arch=amd64 signed-by=$keyring] https://repo.vivaldi.com/stable/stable/ vivaldi-stable main' > $listfile"
    $SUDO apt-get update -qq
    install_pkg "vivaldi-stable" || log_skip "Vivaldi — package not found after repo setup"
}

install_librewolf_debian() {
    local keyring="/usr/share/keyrings/librewolf-archive-keyring.gpg"
    local listfile="/etc/apt/sources.list.d/librewolf.list"
    if ! $SUDO curl -fsSL https://deb.librewolf.net/pool/librewolf.gpg \
        | $SUDO gpg --dearmor -o "$keyring" 2>/dev/null; then
        log_skip "LibreWolf — could not add signing key"; return
    fi
    $SUDO bash -c "echo 'deb [arch=amd64 signed-by=$keyring] https://deb.librewolf.net/ stable main' > $listfile"
    $SUDO apt-get update -qq
    install_pkg "librewolf" || log_skip "LibreWolf — package not found after repo setup"
}

# ─── yay-bin (Arch only, before AUR packages) ──────────────────────────────────

install_yay() {
    echo ""; echo "${PREFIX} === yay-bin (AUR helper) ==="
    if have yay; then log_skip "yay already installed"; return; fi
    if ! ask "${PREFIX} Install yay-bin from AUR? [y/N] "; then
        log_skip "yay — declined"; return
    fi

    install_pkg "base-devel"; install_pkg "git"

    # makepkg refuses root
    if [[ $EUID -eq 0 ]]; then
        echo "${PREFIX} WARNING: Running as root — makepkg refuses to build."
        echo "${PREFIX} Install yay manually as your normal user:"
        echo "  tmpdir=\$(mktemp -d) && git clone https://aur.archlinux.org/yay-bin.git \"\$tmpdir\""
        echo "  cd \"\$tmpdir/yay-bin\" && makepkg -si --noconfirm"
        log_skip "yay — skipped (root)"; return
    fi

    local tmpdir; tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay-bin.git "$tmpdir/yay-bin" || {
        log_skip "yay — clone failed"; rm -rf "$tmpdir"; return; }
    (cd "$tmpdir/yay-bin" && makepkg -si --noconfirm) 2>&1 || log_skip "yay — build failed"
    rm -rf "$tmpdir"
    have yay && echo "${PREFIX} yay installed successfully."
}

# ─── Hardware Detection ────────────────────────────────────────────────────────

install_hardware() {
    echo ""; echo "${PREFIX} === HARDWARE DRIVERS ==="

    # CPU microcode (both desktop and server)
    local cpu_vendor; cpu_vendor=$(grep -m1 vendor_id /proc/cpuinfo | awk '{print $NF}')
    echo "${PREFIX} Detected CPU vendor: $cpu_vendor"
    local ucode_pkg
    if [[ "$cpu_vendor" == "AuthenticAMD" ]]; then
        ucode_pkg=$([[ $DISTRO == "arch" ]] && echo "amd-ucode" || echo "amd64-microcode")
        ask "${PREFIX} Install ${ucode_pkg}? [y/N] " && install_pkg "$ucode_pkg"
    elif [[ "$cpu_vendor" == "GenuineIntel" ]]; then
        ucode_pkg=$([[ $DISTRO == "arch" ]] && echo "intel-ucode" || echo "intel-microcode")
        ask "${PREFIX} Install ${ucode_pkg}? [y/N] " && install_pkg "$ucode_pkg"
    fi

    # GPU detection (desktop only — servers skip this)
    if [[ "$ROLE" == "desktop" ]]; then
        local gpu_line; gpu_line=$(lspci -nn 2>/dev/null | grep -iE 'vga|3d|display' | head -1 || true)
        if [[ -n "$gpu_line" ]]; then
            echo "${PREFIX} Detected GPU: $gpu_line"
            if echo "$gpu_line" | grep -qiE 'amd|ati'; then
                if ask "${PREFIX} Install AMD GPU drivers (mesa + vulkan)? [y/N] "; then
                    install_pkg "mesa"
                    install_pkg "$([[ $DISTRO == "arch" ]] && echo "vulkan-radeon" || echo "mesa-vulkan-drivers")"
                fi
            elif echo "$gpu_line" | grep -qi 'intel'; then
                if ask "${PREFIX} Install Intel GPU drivers (mesa + media driver)? [y/N] "; then
                    install_pkg "mesa"
                    install_pkg "$([[ $DISTRO == "arch" ]] && echo "intel-media-driver" || echo "intel-media-va-driver")"
                fi
            elif echo "$gpu_line" | grep -qi 'nvidia'; then
                echo "${PREFIX} NVIDIA GPU detected."
                if ask "${PREFIX} Install proprietary NVIDIA drivers? (default: nouveau/open-source) [y/N] "; then
                    if [[ $DISTRO == "arch" ]]; then
                        install_pkg "nvidia"; install_pkg "nvidia-utils"
                        echo "${PREFIX} NOTE: If using a custom kernel, use nvidia-dkms instead."
                    else ensure_debian_nonfree; install_pkg "nvidia-driver"; fi
                else log_skip "NVIDIA — using nouveau/open-source"; fi
            elif echo "$gpu_line" | grep -qiE 'virtio|qxl|vmware|virtualbox'; then
                log_skip "Virtual GPU — no driver needed"
            else log_skip "Unknown GPU — skipping"; fi
        else log_skip "No GPU found via lspci"; fi
    else
        log_skip "GPU drivers — skipped (server role)"
    fi

    # Firmware (both desktop and server)
    if ask "${PREFIX} Install firmware packages? [y/N] "; then
        if [[ $DISTRO == "arch" ]]; then install_pkg "linux-firmware"
        else ensure_debian_nonfree_firmware; install_pkg "firmware-linux"; fi
    fi

    # Post-microcode initramfs
    if [[ $DISTRO == "debian" ]] && have update-initramfs; then
        echo "${PREFIX} Updating initramfs..."; $SUDO update-initramfs -u
    elif [[ $DISTRO == "arch" ]]; then
        echo "${PREFIX} NOTE: mkinitcpio picks up microcode automatically on next kernel install."
        echo "${PREFIX} For custom kernels, re-run mkinitcpio -P after microcode install."
    fi
}

# Ensure Debian non-free components are in apt sources
ensure_debian_nonfree() {
    local sources="/etc/apt/sources.list"
    if [[ -f "$sources" ]] && ! grep -q 'non-free' "$sources" 2>/dev/null; then
        echo "${PREFIX} Adding non-free to $sources..."; $SUDO sed -i 's/ main$/ main non-free/' "$sources"
        $SUDO apt-get update -qq
    fi
}

ensure_debian_nonfree_firmware() {
    local sources="/etc/apt/sources.list"
    if [[ -f "$sources" ]] && ! grep -q 'non-free-firmware' "$sources" 2>/dev/null; then
        echo "${PREFIX} Adding non-free-firmware to $sources..."
        $SUDO sed -i 's/ main$/ main non-free-firmware/' "$sources"
        $SUDO sed -i 's/ main non-free$/ main non-free non-free-firmware/' "$sources"
        $SUDO apt-get update -qq
    fi
}

# ─── Server Tier ───────────────────────────────────────────────────────────────

install_server() {
    echo ""; echo "${PREFIX} === SERVER PACKAGES ==="
    if have systemctl && ask "${PREFIX} Enable SSH daemon? [y/N] "; then
        local ssh_unit; ssh_unit=$([[ $DISTRO == "arch" ]] && echo "sshd.service" || echo "ssh.service")
        echo "${PREFIX} Enabling ${ssh_unit}..."
        $SUDO systemctl enable --now "$ssh_unit" || log_skip "sshd enable failed"
    elif ! have systemctl; then log_skip "sshd — no systemctl"; fi

    if ask "${PREFIX} Install Docker? [y/N] "; then
        if [[ $DISTRO == "arch" ]]; then install_pkgs false "docker" "docker-compose"
        else
            install_pkg "docker.io"
            install_pkg "docker-compose-v2" || install_pkg "docker-compose" || \
                log_skip "docker-compose — not available"
        fi
        have systemctl && ($SUDO systemctl enable --now docker || log_skip "docker enable failed")
        echo "${PREFIX} NOTE: Add yourself to docker group: sudo usermod -aG docker $USER"
    fi
}

# ─── ly Configuration (desktop only) ──────────────────────────────────────────

configure_ly() {
    echo ""
    echo "${PREFIX} === CONFIGURE ly ==="
    local config="/etc/ly/config.ini"

    if [[ ! -f "$config" ]]; then
        log_skip "ly config — $config not found"
        return
    fi

    local settings=(
        "animation=gameoflife"
        "gameoflife_fg=0x00FF8C00"
        "gameoflife_frame_delay=16"
        "gameoflife_initial_density=0.3"
        "clear_password=true"
        "allow_empty_password=true"
        "start_cmd=null"
    )

    for setting in "${settings[@]}"; do
        local key="${setting%%=*}"
        local value="${setting#*=}"

        if $SUDO grep -q "^${key} = " "$config" 2>/dev/null; then
            local current; current=$($SUDO grep "^${key} = " "$config" 2>/dev/null | head -1)
            if [[ "$current" == "${key} = ${value}" ]]; then
                echo "  ${PREFIX} OK: ${key} = ${value}"
            else
                $SUDO sed -i "s/^${key} = .*/${key} = ${value}/" "$config"
                echo "  ${PREFIX} SET:  ${key} = ${value}"
            fi
        else
            echo "${key} = ${value}" | $SUDO tee -a "$config" >/dev/null
            echo "  ${PREFIX} ADD:  ${key} = ${value}"
        fi
    done

    # Enable ly@tty1.service (do not start — never kill a running session)
    if have systemctl && [[ "$ROLE" == "desktop" ]]; then
        local unit_found=false
        if [[ -f /usr/lib/systemd/system/ly@.service ]]; then unit_found=true; fi
        if ! $unit_found && $SUDO systemctl list-unit-files 2>/dev/null | grep -q "^ly@\.service"; then unit_found=true; fi

        if $unit_found; then
            local state; state=$($SUDO systemctl is-enabled ly@tty1.service 2>/dev/null || true)
            if [[ "$state" == "enabled" ]]; then
                echo "  ${PREFIX} OK: ly@tty1.service already enabled"
            else
                $SUDO systemctl enable ly@tty1.service
                echo "  ${PREFIX} Enabled ly@tty1.service (not started — manual activation required)"
            fi
        else
            log_skip "ly@.service — template unit not found"
        fi
    fi
}

# ─── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
    echo ""
    echo "${PREFIX} === INSTALLATION SUMMARY ==="
    echo "  Distro : $DISTRO ($PRETTY_NAME)"
    echo "  Role   : $ROLE"
    echo "  Sudo   : ${SUDO:-(none)}"
    echo "  Core   : installed"
    if [[ "$ROLE" == "desktop" ]]; then
        echo "  Desktop: installed"
        echo "  Browsers: installed"
        if pkg_installed ly; then echo "  ly     : installed + configured"
        else echo "  ly     : skipped (not available)"; fi
    else echo "  Server : installed"; fi
}

# ─── Chezmoi Handoff ───────────────────────────────────────────────────────────

chezmoi_handoff() {
    echo ""
    echo "${PREFIX} ============================================"
    echo "${PREFIX} System setup complete."
    echo "${PREFIX} ============================================"
    echo ""
    echo "${PREFIX} Next: deploy dotfiles with chezmoi:"
    echo "  chezmoi init --apply git@github.com:Gunsrude/dotfiles.git"
    echo ""

    if ! ask "${PREFIX} Proceed with chezmoi now? [y/N] "; then
        echo "${PREFIX} Manual setup later:"
        echo "  curl -fsLS get.chezmoi.io | sh -s -- -b ~/.local/bin"
        echo "  chezmoi init --apply git@github.com:Gunsrude/dotfiles.git"
        exit 0
    fi

    if ! have chezmoi; then
        echo "${PREFIX} chezmoi not found — installing..."
        curl -fsLS get.chezmoi.io | sh -s -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    # Run as invoking user (never with sudo)
    echo "${PREFIX} Running chezmoi init..."
    chezmoi init --apply git@github.com:Gunsrude/dotfiles.git
    echo "${PREFIX} Dotfiles deployed."
}

# ─── Main ──────────────────────────────────────────────────────────────────────

main() {
    echo "${PREFIX} Dotfiles bootstrap — starting..."

    detect_distro
    setup_privileges

    local role_input
    read -rp "${PREFIX} Machine role: [1] desktop [2] server (default: 1) " role_input
    role_input="${role_input:-1}"
    ROLE=$([[ "$role_input" == "2" ]] && echo "server" || echo "desktop")
    echo "${PREFIX} Role: $ROLE"

    install_core
    [[ $DISTRO == "arch" ]] && install_yay
    install_hardware

    if [[ "$ROLE" == "desktop" ]]; then install_desktop; install_browsers
    else install_server; fi

    if [[ "$ROLE" == "desktop" ]] && pkg_installed ly; then configure_ly; fi

    print_summary
    chezmoi_handoff
}

main "$@"
