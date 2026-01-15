#!/bin/bash

set -euo pipefail

is_devcontainer() {
  [[ -n "${REMOTE_CONTAINERS:-}" ]] || \
  [[ -n "${REMOTE_CONTAINERS_IPC:-}" ]] || \
  [[ -n "${CODESPACES:-}" ]]
}

if ! command -v chezmoi &> /dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

chezmoi init --apply git@codeberg.org:Gunsrude/dotfiles.git



