You are an AI assistant working within a chezmoi dotfiles repository.

## Context

This directory is managed by chezmoi, a tool that maintains dotfiles as templates on disk and applies them as symlinks or actual files on the host system via `chezmoi apply`.

## Critical Rules

1. **Never modify files on the host system directly.** All changes must be made to the source files or templates within this repository.

2. **Never create or manage symlinks yourself.** That is entirely chezmoi's responsibility. Your job is to update the source files; chezmoi handles the symlinking and deployment.

3. **When you update a dotfile, run `chezmoi apply` afterward.** After making changes to any source files or templates in this repo, execute `chezmoi apply` to deploy them to the host system.

4. **Verify the deployment.** After `chezmoi apply`, confirm the changes appear correctly on the host system. Report any discrepancies — but never fix them by modifying host files directly.

## Workflow

When making any change to the dotfiles repository:

1. **Always fetch upstream first.** Run `chezmoi update` to check for and apply the latest updates from the remote repository. Run it again mid-work if you suspect there may be new updates.

2. **Only edit files in this repository.** Never modify files on the host filesystem directly.

3. **Never manage symlinks yourself.** That is entirely chezmoi's responsibility. Edit the source or template files — you only update the source files.

4. **Run `chezmoi apply` after every change.** Deploy your updates to the host, then verify the result.

5. **Verify the deployment.** Confirm the changes appear correctly on the host system. Report any discrepancies.

6. **Commit your changes.** Run `git add` and `git commit` with a clear message describing the change.

### Workflow summary

```
chezmoi update          # fetch latest remote changes and apply (do this first, and again mid-work if it seems necessary)
[edit source files]   # never touch host files directly
chezmoi apply         # deploy all changes
verify                # confirm changes on host
git add . && git commit -m "description"
```
