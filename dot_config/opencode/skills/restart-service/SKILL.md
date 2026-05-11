---
name: restart-service
description: Restart the opencode-web systemd service for the current working directory. Derives the service name (opencode-web-<directory>.service) from the cwd. Accepts an optional explicit service name as override.
license: MIT
---

## What I do
- Gets the current working directory on the remote machine
- Derives the service name from the last directory component: `opencode-web-<dir>.service`
- Runs `systemctl --user restart` for that service
- Accepts an explicit service name or directory to override the auto-detected name

## When to use me
Use this when the user asks to restart the opencode-web service for the project they're working on. Also use when the user explicitly mentions restarting a service by name.

## How to use me
1. Get the current working directory: `pwd`
2. Extract the last path component (e.g., `/home/user/projects/chezmoi` → `chezmoi`)
3. Derive the service name: `opencode-web-<dir>.service`
4. Run: `systemctl --user restart opencode-web-<dir>.service`
5. If the user provides an explicit directory or service name, use that instead

## Notes
- The service must match the pattern `opencode-web-<directory>.service`
- If the derived service doesn't exist, ask the user for the correct service name
- Do not add any extra flags to systemctl --user restart
