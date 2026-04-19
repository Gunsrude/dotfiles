# Repo Context

This is a **[chezmoi](https://chezmoi.io)** dotfiles repository, not a traditional codebase. All source files deploy to the host via `chezmoi apply`.

## Conventions

- **Prefixes**: `dot_<name>` → `~/<name>`, `dot_config/<name>` → `~/.config/<name>`, `dot_local/share/<name>` → `~/.local/share/<name>`. Template files use `.tmpl` extension and Go template syntax (`{{ }}`).
- **machine_type**: All templates branch on `{{ .machine_type }}` (work / personal / server / container). SSH key ignores in `.chezmoiignore.tmpl` differ per machine_type.
- **Remote**: `ssh://git@codeberg.org/Gunsrude/dotfiles.git` (Codeberg)
- **No build/test pipeline** — `chezmoi apply` is the deployment step.

## Key Directories

- **dot_config/hypr/** — Hyprland Wayland WM (16 files, entry: `hyprland.conf`)
- **dot_config/nvim/** — Neovim (Lua, lazy.nvim)
- **dot_config/kitty/** / **dot_config/alacritty/** — Terminal emulators
- **dot_config/opencode/** — OpenCode IDE assistant config
- **.chezmoiscripts/** — Auto-install scripts (nvim, nvm)

## Config Directories (do not mix up)

- **`.opencode/`** — Repo-local OpenCode config. Contains `opencode.json` (external dir permissions), `INSTRUCTIONS.md` (chezmoi workflow), `package.json` (plugin dep). Stays in the source tree — does not deploy to host.
- **`dot_config/opencode/`** — Deploys to `~/.config/opencode/` on the host. Contains `opencode.json` (provider/model), `AGENTS.md` (git rules), `PROFILE.md` (user name), `tui.json` (theme). Always edit this directory for global settings.
