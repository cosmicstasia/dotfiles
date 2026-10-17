# Dotfiles

Cross-platform configuration for the MacBook (macOS) and the Omarchy desktop
(Arch Linux), managed by chezmoi.

## Defaults

- **zsh** is the login shell on both machines (`~/.zshenv`, `~/.zprofile`,
  `~/.zshrc`). kitty, tmux, herdr, Neovim terminals and tuios panes all start it.
- **tuios** is the terminal workspace, opt-in: terminals open a plain zsh. Set
  `TUIOS_AUTOSTART=1` and a top-level zsh runs `tuios attach`, which restores
  or creates a session (skipped inside tuios/tmux/herdr/zellij, editors and
  SSH logins). On Omarchy, `Super+Alt+Return` opens a terminal straight into tuios.
- On Omarchy, `~/.config/xdg-terminals.list` makes kitty the default terminal.

## Theming

On Omarchy every app follows the Omarchy theme and changes with it; on the Mac
each app keeps its own colours (Catppuccin Mocha, Noctalia for kitty). Templates
tell the two apart with `.chezmoitemplates/omarchy-theme`, which finds the active
Omarchy theme directory (`~/.local/state/omarchy/current/theme` on Omarchy 4).

| App | On Omarchy |
| --- | --- |
| Neovim | `lua/plugins/theme.lua` links the theme's `neovim.lua`, plus omarchy-nvim's hot-reload, all-themes and transparency files; `colorscheme.lua` is Mac-only |
| kitty | includes Omarchy's defaults and the theme's `kitty.conf`; no font, opacity or theme of its own |
| tmux, herdr, tuios, starship | draw with the terminal (ANSI) palette, as Omarchy's own configs do |
| btop | `color_theme = "current"`, linked to the theme's `btop.theme` |
| tuios selection colours, omp | rendered by Omarchy from `~/.config/omarchy/themed/*.tpl` on every theme change |
| pi | `omarchy-theme-set-pi` owns `omarchy-system.json` |
| Emacs | `~/.config/omarchy/hooks/theme-set.d/emacs` passes the theme name on |

## Packages

- **mise** (`~/.config/mise/config.toml`) installs the shared CLI toolchain and
  language runtimes on both machines, at the same versions. `chezmoi apply`
  runs `mise install` whenever that file changes.
- **Homebrew** (`~/Brewfile`, macOS only) keeps GUI casks and the formulae mise
  cannot provide: system libraries, daemons and compiled toolchains.
- **pacman** (Omarchy) installs the same native set; see
  `run_onchange_after_20-native-packages.sh.tmpl`.
- zsh-autosuggestions and fast-syntax-highlighting are git checkouts in
  `~/.local/share/zsh/plugins` (see `.chezmoiexternal.toml`).

## Working across both machines

Each machine knows the other under `peerName`, reached at `peerAddr` (chezmoi
data; `chezmoi init` asks for both).

- **tuios** lists it in `~/.config/tuios/config.d/hosts.toml`. Its sessions show
  in the tuios sidebar, or open one directly:

  ```sh
  tuios attach --host omarchy        # from the MacBook
  tuios attach --host macbook        # from the Omarchy desktop
  ```

  tuios asks before it trusts a new host: run `tuios config apply` from a
  terminal outside tuios after the first `chezmoi apply`, and keep a tuios
  daemon running on the peer.
- **herdr** saves it as an SSH machine (`run_after_28-herdr-peer-machine.sh`
  runs `herdr machine add` when it is missing, which also starts the peer's
  herdr server). Its workspaces and agents show in the herdr sidebar; `prefix+w`
  switches across both machines, and `herdr --machine omarchy agent list` works
  from the CLI. An unreachable peer is retried on the next `chezmoi apply`.

Both links go over SSH, so each machine needs sshd (Remote Login on macOS) and
a key the other accepts without a prompt.

`~/.ssh/authorized_keys` gets every key in the `sshAuthorizedKeys` chezmoi
value (a list; `chezmoi init` asks for the first one). Keys already in the file
are kept, so pairing keys and keys added by hand survive `chezmoi apply`.

## Git signing and SSH agent

Commits are SSH-signed through 1Password. `chezmoi init` defaults
`gitSigningKey` (public key of the `Git Signing Key` item),
`gitSigningProgram` (`op-ssh-sign`) and `sshAuthSock` (the 1Password agent
socket) per OS; accept them or clear `gitSigningKey` to turn signing off.
`~/.gitconfig` then sets `gpg.format = ssh` and `commit.gpgsign = true`, and
`~/.config/git/allowed_signers` lets `git verify-commit` trust the key.

Which agent is used depends on how you're connected. A remote SSH session
(`ssh -A`) keeps the forwarded agent it inherits, so signing and SSH use the
client machine's 1Password (`~/.ssh/config` sets `ForwardAgent yes` for the
peer machine in a marked block; other hosts in that file stay as they are).
Otherwise `~/.zshenv` and nushell set
`SSH_AUTH_SOCK` from `sshAuthSock`, this machine's 1Password agent. tuios panes
re-resolve it before every prompt (`tuios ssh-agent-path`): the forwarded agent
while a remote client uses the session, the local agent once that socket is
gone. herdr panes do the same with herdr's stable `herdr.sock.agent` address.
Git signs through `~/.local/bin/git-ssh-sign`, which uses the agent in
`SSH_AUTH_SOCK` when it holds the signing key and otherwise falls back to
`gitSigningProgram`.

1Password only serves the Personal vault by default; list other vaults in
`~/.config/1Password/ssh/agent.toml` (per account, not managed here).

## omp

omp itself comes from mise (`oh-my-pi`, the standalone release binary), like
every other CLI tool; it is not installed with `bun install -g`.

`~/.omp/agent/config.yml` (theme, symbols, model roles) is shared as-is.
`~/.omp/agent/models.yml` is a template: the 9router provider is written only
when the `nineRouterApiKey` chezmoi value is set, and the key never enters this
public repository. tuios writes its own omp extension
(`tuios integration install omp`), so a script re-runs that instead of
tracking the file. Sessions, history and model caches stay per machine.

## Bootstrap

```sh
chezmoi init https://github.com/cosmicstasia/dotfiles.git
chezmoi diff
chezmoi apply
```

The scripts run in order: install mise, install native packages (Homebrew or
pacman), `mise install`, generate the Nushell integrations, install the tuios
omp integration, and set zsh as the login shell. The first initialization
prompts for machine-specific paths, the tuios peer and the 9router key; re-run
`chezmoi init` to change them later.
