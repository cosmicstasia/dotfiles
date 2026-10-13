# Dotfiles

Cross-platform configuration for the MacBook (macOS) and the Omarchy desktop
(Arch Linux), managed by chezmoi.

## Defaults

- **zsh** is the login shell on both machines (`~/.zshenv`, `~/.zprofile`,
  `~/.zshrc`). kitty, tmux, herdr, Neovim terminals and tuios panes all start it.
- **tuios** is the terminal workspace: a top-level zsh in kitty (or any local
  terminal) runs `tuios attach`, which restores or creates a session. It is
  skipped inside tuios/tmux/herdr/zellij, editors and SSH logins. Set
  `TUIOS_AUTOSTART=0` to get a plain shell; kitty splits already do.
- On Omarchy, `~/.config/xdg-terminals.list` makes kitty the default terminal.

## Packages

- **mise** (`~/.config/mise/config.toml`) installs the shared CLI toolchain and
  language runtimes on both machines, at the same versions. `chezmoi apply`
  runs `mise install` whenever that file changes.
- **Homebrew** (`~/Brewfile`, macOS only) keeps GUI casks and the formulae mise
  cannot provide: system libraries, daemons and compiled toolchains.
- **pacman** (Omarchy) installs the same native set; see
  `run_onchange_after_20-native-packages.sh.tmpl`.
- zsh-autosuggestions and zsh-syntax-highlighting are git checkouts in
  `~/.local/share/zsh/plugins` (see `.chezmoiexternal.toml`).

## Working across both machines

Each machine's tuios lists the other in `~/.config/tuios/config.d/hosts.toml`,
rendered from `tuiosPeerName`/`tuiosPeerAddr` in chezmoi's data. Sessions on
the other machine show in the tuios sidebar, or open one directly:

```sh
tuios attach --host omarchy        # from the MacBook
tuios attach --host macbook        # from the Omarchy desktop
```

tuios asks before it trusts a new host: run `tuios config apply` from a
terminal outside tuios after the first `chezmoi apply`. The link goes over SSH,
so the peer needs sshd (Remote Login on macOS) and a running tuios daemon.

`~/.ssh/authorized_keys` gets every key in the `sshAuthorizedKeys` chezmoi
value (a list; `chezmoi init` asks for the first one). Keys already in the file
are kept, so pairing keys and keys added by hand survive `chezmoi apply`.

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
