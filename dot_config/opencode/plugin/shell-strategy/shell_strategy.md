# Shell Non-Interactive Strategy

OpenCode's shell is **non-interactive** (no TTY/PTY). Commands that prompt for input will hang and timeout.

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `CI` | `true` | CI detection |
| `DEBIAN_FRONTEND` | `noninteractive` | Apt/dpkg prompts |
| `GIT_TERMINAL_PROMPT` | `0` | Git auth prompts |
| `GIT_EDITOR` | `true` | Block git editor |
| `GIT_PAGER` | `cat` | Disable git pager |
| `PAGER` | `cat` | Disable system pager |
| `HOMEBREW_NO_AUTO_UPDATE` | `1` | Homebrew updates |
| `npm_config_yes` | `true` | NPM prompts |
| `PIP_NO_INPUT` | `1` | Pip prompts |

## Command Reference

### Package Managers

| Tool | Bad | Good |
|------|-----|------|
| npm | `npm init` | `npm init -y` |
| npm | `npm install` | `npm install --yes` |
| Yarn | `yarn install` | `yarn install --non-interactive` |
| PNPM | `pnpm install` | `pnpm install --reporter=silent` |
| Bun | `bun init` | `bun init -y` |
| APT | `apt-get install pkg` | `apt-get install -y pkg` |
| PIP | `pip install pkg` | `pip install --no-input pkg` |
| Homebrew | `brew install pkg` | `HOMEBREW_NO_AUTO_UPDATE=1 brew install pkg` |

### Git

| Action | Bad | Good |
|--------|-----|------|
| Commit | `git commit` | `git commit -m "msg"` |
| Merge | `git merge branch` | `git merge --no-edit branch` |
| Pull | `git pull` | `git pull --no-edit` |
| Rebase | `git rebase -i` | `git rebase` (non-interactive) |
| Add | `git add -p` | `git add .` |
| Log/Diff | `git log` / `git diff` | `git --no-pager log` / `git --no-pager diff` |

### System & Docker

| Tool | Bad | Good |
|------|-----|------|
| rm | `rm file` | `rm -f file` |
| cp/mv | `cp -i` / `mv -i` | `cp -f` / `mv -f` |
| unzip | `unzip file.zip` | `unzip -o file.zip` |
| SSH | `ssh host` | `ssh -o BatchMode=yes host` |
| docker run | `docker run -it image` | `docker run image` |
| docker exec | `docker exec -it` | `docker exec` |
| docker build | `docker build .` | `docker build --progress=plain .` |
| compose | `docker-compose up` | `docker-compose up -d` |

### Python/Node

| Tool | Bad | Good |
|------|-----|------|
| Python | `python` | `python -c "code"` or `python script.py` |
| Node | `node` | `node -e "code"` or `node script.js` |

## Banned Commands

These will hang indefinitely:
- **Editors**: `vim`, `vi`, `nano`, `emacs`, `pico`
- **Pagers**: `less`, `more`, `man`
- **Interactive git**: `git add -p`, `git rebase -i`, `git commit` (without -m)
- **REPLs**: `python`, `node`, `ipython` (without `-c`/script)
- **Interactive shells**: `bash -i`, `zsh -i`

For commands without non-interactive flags, use: `yes | cmd`, heredocs, or `timeout 30 cmd`.
