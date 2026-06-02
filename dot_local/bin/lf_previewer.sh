#!/usr/bin/env bash
# lf previewer script
# Deployed to ~/.local/bin/lf_previewer.sh via chezmoi

set -o pipefail

FILE_PATH="$1"
PV_WIDTH="$2"
PV_HEIGHT="$3"

# Get file extension (lowercase)
FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER=$(echo "$FILE_EXTENSION" | tr '[:upper:]' '[:lower:]')

# Get MIME type
MIME_TYPE=$(file --dereference --brief --mime-type -- "$FILE_PATH" 2>/dev/null || echo "application/octet-stream")

case "$MIME_TYPE" in
    # Text files with syntax highlighting via bat
    text/*|application/json|application/x-yaml|application/xml)
        # Use bat for syntax highlighting, limit to 200 lines for performance
        if command -v bat &> /dev/null; then
            bat --strip-ansi=always --color=always --style=plain \
                --line-range=:200 -- "$FILE_PATH" 2>/dev/null
        else
            # Fallback to cat if bat not installed
            head -200 "$FILE_PATH"
        fi
        ;;
    
    # Images (if using imgcat or similar)
    image/png|image/jpeg|image/gif|image/webp)
        if command -v imgcat &> /dev/null; then
            imgcat --scale-down-to="$PV_WIDTH" -- "$FILE_PATH" 2>/dev/null
        elif command -v chafa &> /dev/null; then
            chafa "$FILE_PATH" --width="$PV_WIDTH" 2>/dev/null
        else
            echo "[Image: $(basename "$FILE_PATH")]"
            file --dereference --brief "$FILE_PATH"
        fi
        ;;
    
    # Archives - list contents
    application/zip|application/gzip|application/x-tar|application/x-rar-compressed|application/x-7z-compressed)
        case "$FILE_EXTENSION_LOWER" in
            tar)   tar -tf "$FILE_PATH" 2>/dev/null | head -100 ;;
            gz)    tar -tzf "$FILE_PATH" 2>/dev/null | head -100 ;;
            zip)   unzip -l "$FILE_PATH" 2>/dev/null | head -100 ;;
            tgz)   tar -tzf "$FILE_PATH" 2>/dev/null | head -100 ;;
            rar)   unrar l "$FILE_PATH" 2>/dev/null | head -100 ;;
            7z)    7z l "$FILE_PATH" 2>/dev/null | head -100 ;;
            *)     echo "Archive: $(basename "$FILE_PATH")" ;;
        esac
        ;;
    
    # PDFs
    application/pdf)
        if command -v pdftotext &> /dev/null; then
            pdftotext -l 10 - "$FILE_PATH" - 2>/dev/null
        elif command -v pdfinfo &> /dev/null; then
            pdfinfo -- "$FILE_PATH" 2>/dev/null
        else
            file --dereference --brief "$FILE_PATH"
        fi
        ;;
    
    # Binary files - show file info
    application/octet-stream|application/x-executable)
        echo "Binary file: $(basename "$FILE_PATH")"
        file --dereference --brief -- "$FILE_PATH"
        ls -lh -- "$FILE_PATH" 2>/dev/null | awk '{print "Size:", $5}'
        ;;
    
    # Everything else - try bat, fallback to head
    *)
        if command -v bat &> /dev/null; then
            bat --color=always --paging=never --style=plain "$FILE_PATH" 2>/dev/null
        else
            head -200 "$FILE_PATH" 2>/dev/null
        fi
        ;;
esac

exit 0
