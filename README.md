# Dotfiles

This are configuration I use across different machines.

## Requirements

- [chezmoi](https://www.chezmoi.io/)

## Usage

- **Setup**
```bash
chezmoi init git@github.com:hossainemruz/dotfiles.git
```

- **Add a file/directory to track:**
```bash
chezmoi add $FILE
```

- **Check diff between source state and machine state:**
```bash
chezmoi diff
```

- **Apply source state into machine:**
```bash
chezmoi apply
```

- **Pull latest change from remote repo and diff with machine state:**
```bash
chezmoi git pull -- --autostash --rebase && chezmoi diff
```

- **Pull latest change from remote and apply them:**

```bash
chezmoi update
```

- **Setup new machine with single command:**
```bash
export GITHUB_USERNAME=hossainemruz
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

- **Navigate to source directory:**
```bash
chezmoi cd
```

- **Merge machine state with source state:**

```bash
chezmoi merge
```
