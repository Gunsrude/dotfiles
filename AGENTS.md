# Repo Context

This is a **[chezmoi](https://chezmoi.io)** dotfiles repository, not a traditional codebase. All source files deploy to the host via `chezmoi apply`.

## Conventions

### Chezmoi File Prefixes

Source files use special prefixes that are stripped during deployment via `chezmoi apply`.

#### Location Prefixes (removed on deploy)

- `dot_<name>` → deploys to `~/.<name>` (e.g., `dot_vimrc` → `~/.vimrc`)
- `dot_config/<name>/file` → deploys to `~/.config/<name>/file`
- `dot_local/share/<name>/file` → deploys to `~/.local/share/<name>/file`

#### Permission Prefixes (removed on deploy)

- `private_<name>` → deploys as `<name>` with 600 permissions (read/write owner only)
- `executable_<name>` → deploys as `<name>` with execute permissions

#### Template Files

Files with `.tmpl` extension use Go template syntax (`{{ .machine_type }}`, etc.) and are processed during deployment.

- **machine_type**: All templates branch on `{{ .machine_type }}` (work / personal / server / container). SSH key ignores in `.chezmoiignore.tmpl` differ per machine_type.
- **No build/test pipeline** — `chezmoi apply` is the deployment step.

## Key Directories

- **dot_config/opencode/** — OpenCode IDE assistant config
- **.chezmoiscripts/** — Auto-install scripts (nvim, nvm)

## Config Directories (do not mix up)

- **`.opencode/`** — Repo-local OpenCode config. Contains `opencode.json` (external dir permissions), `INSTRUCTIONS.md` (chezmoi workflow), `package.json` (plugin dep). Stays in the source tree — does not deploy to host.
- **`dot_config/opencode/`** — Deploys to `~/.config/opencode/` on the host. Contains `opencode.json` (provider/model), `CLAUDE.md` (git rules), `PROFILE.md` (user name), `tui.json` (theme). Always edit this directory for global settings.

## Credential and Secrets Handling

**Always handle credentials through approved channels:**

- **Use environment variables** for all secrets, API keys, and authentication tokens
- **Only read `.env` files or secrets managers** when a task explicitly requires that specific credential with documented justification
- **Proceed only when you have verified access** — if a credential file is missing, blocked, or returns an error, stop immediately
- **Always ask the user** for missing credentials rather than attempting to generate, guess, or bypass authentication
- **Escalate access issues** by reporting the specific credential needed and where it should come from
- **Delegate to the user** for any operation that requires authentication you don't possess

**Why this matters:** Credentials stored in code or databases create persistent security exposures. When access is blocked, workarounds bypass the user's control — report the gap and wait for authorization.
