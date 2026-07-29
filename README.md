# Dotfiles

This are configuration I use across different machines.

## Requirements

- [chezmoi](https://www.chezmoi.io/)

Automatic sync also requires [Dagu](https://dagu.cloud/). Install the tool
already declared in the mise configuration with `mise install dagu` before
applying these dotfiles. Linux desktop notifications require `notify-send`
(provided by Arch's `libnotify` package); macOS uses the built-in `osascript`.

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

- **Setup a macOS machine:**

```bash
xcode-select --install # if Command Line Tools are not installed yet
export GITHUB_USERNAME=hossainemruz
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

On macOS, chezmoi installs Homebrew if needed and then runs `brew bundle` from
`Brewfile`. Hyprland, Waybar, and the Linux webapp installer are skipped; native
macOS apps are installed via Homebrew casks where available.

- **Navigate to source directory:**
```bash
chezmoi cd
```

- **Merge machine state with source state:**

```bash
chezmoi merge
```

## Automatic repository sync

Dagu runs independent sync workflows for `$HOME/agent-vault` and the chezmoi
source repository every 15 minutes. Each workflow commits local changes without
GPG signing, fetches and rebases onto the branch's configured upstream, then
pushes only when the local branch is ahead. The Dagu scheduler starts at login
as a systemd user service on Arch Linux or a LaunchAgent on macOS. The web UI is
not started automatically; run `dagu server`, then open
<http://localhost:8080>, when it is needed.

Both repositories must have a checked-out branch with a remote upstream. A
failed rebase is deliberately left in place and triggers a desktop notification;
inspect the Dagu run, resolve the conflict, run `git rebase --continue` (or
`git rebase --abort`), then restart the failed workflow from the UI.

On Linux, Dagu and interactive shells share a per-user systemd SSH agent. An
encrypted key must be unlocked once per login/session with `ssh-add` before
unattended sync can authenticate, unless another non-interactive credential
mechanism is configured.

Useful service commands:

```bash
# Arch Linux
systemctl --user status dagu
systemctl --user status ssh-agent
journalctl --user -u dagu

# macOS
launchctl print "gui/$(id -u)/com.hossainemruz.dagu"
tail -f ~/.local/share/dagu/launchd.stderr.log
```
