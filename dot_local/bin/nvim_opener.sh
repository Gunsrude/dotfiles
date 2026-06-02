#!/bin/bash
#chezmoi:executable=true
# Open file in existing nvim instance using --remote
# If nvim server not running, open new instance
# Deployed to ~/.local/bin/nvim_opener.sh via chezmoi

FILE="$1"

if [ -z "$FILE" ]; then
    exit 0
fi

# Check if nvim is available
if ! command -v nvim &> /dev/null; then
    echo "nvim not found" >&2
    exit 1
fi

# Check if nvim server is running
if [ -n "$NVIM_LISTEN_ADDRESS" ] || nvim --serverlist 2>/dev/null | grep -q .; then
    # Open in existing nvim instance
    if [ -d "$FILE" ]; then
        # It's a directory - cd into it and open nvim
        cd "$FILE" && nvim
    else
        # It's a file - open remotely
        nvim --remote "$FILE" 2>/dev/null || nvim "$FILE"
    fi
else
    # No running nvim instance, start a new one
    if [ -d "$FILE" ]; then
        cd "$FILE" && nvim
    else
        nvim "$FILE"
    fi
fi
