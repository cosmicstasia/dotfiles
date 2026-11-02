# Dotfiles

Configuration for two Omarchy (Arch Linux) machines — the desktop
(`omarchy`) and this Dell XPS 15 (`dell-xps`) — managed by chezmoi. The
MacBook that used to be the second machine was sold; nothing here targets
macOS anymore.

## Defaults

- **zsh** is the login shell on both machines (`~/.zshenv`, `~/.zshrc`).
  kitty, tmux, herdr, Neovim terminals and tuios panes all start it.
- **tuios** is the terminal workspace, opt-in: terminals open a plain zsh. Set
  `TUIOS_AUTOSTART=1` and a top-level zsh runs `tuios attach`, which restores
  or creates a session (skipped inside tuios/tmux/herdr/zellij, editors and
  SSH logins). `Super+Alt+Return` opens a terminal straight into tuios.
- `~/.config/xdg-terminals.list` makes kitty the default terminal.

## Theming

Every app follows the Omarchy theme and changes with it. Templates find the
active theme directory via `.chezmoitemplates/omarchy-theme`
(`~/.local/state/omarchy/current/theme` on Omarchy 4).

| App | Behaviour |
| --- | --- |
| Neovim | `lua/plugins/theme.lua` links the theme's `neovim.lua`, plus omarchy-nvim's hot-reload, all-themes and transparency files |
| kitty | includes Omarchy's defaults and the theme's `kitty.conf` |
| tmux, herdr, tuios, starship | draw with the terminal (ANSI) palette, as Omarchy's own configs do |
| btop | `color_theme = "current"`, linked to the theme's `btop.theme` |
| tuios selection colours, omp | rendered by Omarchy from `~/.config/omarchy/themed/*.tpl` on every theme change |
| pi | `omarchy-theme-set-pi` owns `omarchy-system.json` |
| Emacs | `~/.config/omarchy/hooks/theme-set.d/emacs` passes the theme name on |

## Packages

- **mise** (`~/.config/mise/config.toml`) installs the shared CLI toolchain and
  language runtimes on both machines, at the same versions. `chezmoi apply`
  runs `mise install` whenever that file changes.
- **pacman** installs the native set mise cannot provide (system libraries,
  daemons, compiled toolchains); see `run_onchange_after_20-native-packages.sh.tmpl`.
- zsh-autosuggestions and fast-syntax-highlighting are git checkouts in
  `~/.local/share/zsh/plugins` (see `.chezmoiexternal.toml`).

## Working across two machines

Each machine knows the other under `peerName`, reached at `peerAddr`
(chezmoi data; `chezmoi init` asks for both). Both peer addresses use NetBird
DNS, so NetBird must be connected on both machines; ordinary OpenSSH provides
authentication:

- `omarchy` (desktop) → `omarchy.netbird.selfhosted`
- `dell-xps` (this machine) → its own NetBird address, set when this Dell was
  initialized

Setting either empty skips the peer config below: no extra `~/.ssh/config`
host, no tuios host and no herdr machine for it.

- **tuios** lists the peer in `~/.config/tuios/config.d/hosts.toml`. Its
  sessions show in the tuios sidebar, or open one directly:

  ```sh
  tuios attach --host omarchy   # from dell-xps
  tuios attach --host dell-xps  # from omarchy
  ```

  tuios asks before it trusts a new host: run `tuios config apply` from a
  terminal outside tuios after the first `chezmoi apply`, and keep a tuios
  daemon running on the peer.
- **herdr** saves it as an SSH machine (`run_after_28-herdr-peer-machine.sh`
  runs `herdr machine add` when it is missing, which also starts the peer's
  herdr server). Its workspaces and agents show in the herdr sidebar; `prefix+w`
  switches across both machines, and `herdr --machine omarchy agent list` works
  from the CLI. An unreachable peer is retried on the next `chezmoi apply`.

Both links go over SSH, so each machine needs sshd running and a key the
other accepts without a prompt.

`~/.ssh/authorized_keys` gets every key in the `sshAuthorizedKeys` chezmoi
value (a list; `chezmoi init` asks for the first one). Keys already in the file
are kept, so pairing keys and keys added by hand survive `chezmoi apply`.

## Git signing and SSH keys

Each machine has its own `~/.ssh/id_ed25519`, and git and SSH read it straight
from disk: no SSH agent, agent forwarding or password manager. It signs
commits and tags (`~/.gitconfig` sets `gpg.format = ssh`,
`user.signingkey = ~/.ssh/id_ed25519` and `commit.gpgsign = true`) and logs in
to the git hosts and the other machine; `~/.ssh/config` gets a managed block
for those hosts and leaves the rest of the file alone.

`.chezmoidata/git.toml` lists the git hosts (`gitHosts`) and the public keys
trusted to sign (`git.signerKeys`), which `~/.config/git/allowed_signers` is
built from so `git verify-commit` works for commits from either machine. The
sold MacBook's key stays listed so its old signed commits still verify.

On a new machine:

1. `ssh-keygen -t ed25519 -C "$USER@$(hostname -s)"` (a passphrase is
   optional; with one, git asks for it when signing).
2. Add `~/.ssh/id_ed25519.pub` to `git.signerKeys`, to `sshAuthorizedKeys` on
   the other machine, and to your account on each git host, marked for
   signing as well as authentication where the forge offers it.

## omp

omp itself comes from mise (`oh-my-pi`, the standalone release binary), like
every other CLI tool; it is not installed with `bun install -g`.

`~/.omp/agent/config.yml` (theme, symbols, model roles) is shared as-is.
`~/.omp/agent/models.yml` is a template: the 9router provider is written only
when the `nineRouterApiKey` chezmoi value is set, and the key never enters this
public repository. tuios writes its own omp extension
(`tuios integration install omp`), so a script re-runs that instead of
tracking the file. Sessions, history and model caches stay per machine.

Agent skills in `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills` and
`~/.pi/agent/skills` are tracked with their supporting scripts and references.
Home-directory paths in skills are templated for each machine. Add or update a
skill with `chezmoi add <skill-directory>` before committing; apply on the other
machine to install it. Codex's `.system` skills, Claude's `synced` cache and
installer metadata are not tracked.

## Bootstrap

```sh
chezmoi init https://github.com/cosmicstasia/dotfiles.git
chezmoi diff
chezmoi apply
```

The scripts run in order: install mise, install native packages via pacman,
`mise install`, generate the Nushell integrations, install the tuios
omp integration, and set zsh as the login shell. The first initialization
prompts for machine-specific paths, the tuios peer and the 9router key; re-run
`chezmoi init` to change them later.
