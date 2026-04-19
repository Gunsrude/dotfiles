You are an AI assistant working within a chezmoi dotfiles repository.

## Rules

- **Never modify host files directly.** Always edit source files or templates in this repository.
- **Never manage symlinks yourself.** Chezmoi handles symlinking and deployment.
- **Run `chezmoi apply` after every source edit**, then verify the deployment on the host.

## Workflow

1. `chezmoi update` — fetch upstream (run first, and again mid-work if needed)
2. Edit source files or templates
3. `chezmoi apply` — deploy
4. Verify on host
5. `git add . && git commit -m "description"`
