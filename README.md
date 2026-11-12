# Dotfiles

Configuration for three machines — the Omarchy desktop (`omarchy`, Arch
Linux), a Dell XPS 15 also on Omarchy (`dell-xps`), and this MacBook
(`macbook`) — managed by chezmoi. `omarchy` is the hub: it pairs with both
other machines, while `dell-xps` and `macbook` each pair only with `omarchy`.

## Defaults

- **zsh** is the login shell on every machine (`~/.zshenv`, `~/.zprofile` on
  the Mac, `~/.zshrc`). kitty, tmux, herdr, Neovim terminals and tuios panes
  all start it.
- **tuios** is the terminal workspace, opt-in: terminals open a plain zsh. Set
  `TUIOS_AUTOSTART=1` and a top-level zsh runs `tuios attach`, which restores
  or creates a session (skipped inside tuios/tmux/herdr/zellij, editors and
  SSH logins). On Omarchy, `Super+Alt+Return` opens a terminal straight into
  tuios.
- On Omarchy, `~/.config/xdg-terminals.list` makes kitty the default terminal.

## Theming

On Omarchy every app follows the Omarchy theme and changes with it; on the
Mac each app keeps its own colours (Catppuccin Mocha, kitty's own theme).
Templates tell the two apart with `.chezmoitemplates/omarchy-theme`, which
finds the active Omarchy theme directory
(`~/.local/state/omarchy/current/theme` on Omarchy 4).

| App | On Omarchy |
| --- | --- |
| Neovim | `lua/plugins/theme.lua` links the theme's `neovim.lua`, plus omarchy-nvim's hot-reload, all-themes and transparency files; `colorscheme.lua` is Mac-only |
| kitty | includes Omarchy's defaults and the theme's `kitty.conf`; the Mac keeps its own font, opacity and theme |
| tmux, herdr, tuios, starship | draw with the terminal (ANSI) palette, as Omarchy's own configs do |
| btop | `color_theme = "current"`, linked to the theme's `btop.theme` |
| tuios selection colours, omp | rendered by Omarchy from `~/.config/omarchy/themed/*.tpl` on every theme change |
| pi | `omarchy-theme-set-pi` owns `omarchy-system.json` |
| Emacs | `~/.config/omarchy/hooks/theme-set.d/emacs` passes the theme name on |

## Packages

- **mise** (`~/.config/mise/config.toml`) installs the shared CLI toolchain and
  language runtimes on every machine, at the same versions. `chezmoi apply`
  runs `mise install` whenever that file changes.
- **Homebrew** (macOS only) and **pacman** (Omarchy) install the native set
  mise cannot provide — GUI apps and system libraries/daemons; see
  `run_onchange_after_20-native-packages.sh.tmpl`.
- zsh-autosuggestions and fast-syntax-highlighting are git checkouts in
  `~/.local/share/zsh/plugins` (see `.chezmoiexternal.toml`).

## Working across machines

`omarchy` is the hub, paired with both `dell-xps` and `macbook`; the spokes
each pair only with `omarchy`. Pairings live in the `peers` chezmoi value — a
list of `{ name, addr }` — asked for once per machine as `peersSpec`
(`chezmoi init` prompts for "name=addr" pairs, comma-separated; empty skips
peer config entirely). Every address uses NetBird DNS, so NetBird must be
connected on both ends of a pairing; ordinary OpenSSH provides
authentication:

- `omarchy` (desktop) → `dell-xps.netbird.selfhosted`, `macbook-pro-16.netbird.selfhosted`
- `dell-xps` (this Dell) → `omarchy.netbird.selfhosted`
- `macbook` (this MacBook) → `omarchy.netbird.selfhosted`

For each peer:

- **tuios** lists it in `~/.config/tuios/config.d/hosts.toml`. Its sessions
  show in the tuios sidebar, or open one directly:

  ```sh
  tuios attach --host omarchy    # from dell-xps or macbook
  tuios attach --host dell-xps   # from omarchy
  tuios attach --host macbook    # from omarchy
  ```

  tuios asks before it trusts a new host: run `tuios config apply` from a
  terminal outside tuios after the first `chezmoi apply`, and keep a tuios
  daemon running on the peer.
- **herdr** saves it as an SSH machine (`run_after_28-herdr-peer-machine.sh`
  runs `herdr machine add` for each peer missing from its list, which also
  starts that peer's herdr server). Its workspaces and agents show in the
  herdr sidebar; `prefix+w` switches across machines, and
  `herdr --machine omarchy agent list` works from the CLI. An unreachable
  peer is retried on the next `chezmoi apply`.

Both links go over SSH, so each machine needs sshd (Remote Login on macOS)
running and a key the other accepts without a prompt.

`~/.ssh/authorized_keys` gets every key in the `sshAuthorizedKeys` chezmoi
value (a list; `chezmoi init` asks for the first one). Keys already in the file
are kept, so pairing keys and keys added by hand survive `chezmoi apply`.

## Git signing and SSH keys

Each machine has its own `~/.ssh/id_ed25519`, and git and SSH read it straight
from disk: no SSH agent, agent forwarding or password manager. It signs
commits and tags (`~/.gitconfig` sets `gpg.format = ssh`,
`user.signingkey = ~/.ssh/id_ed25519` and `commit.gpgsign = true`) and logs in
to the git hosts and each peer; `~/.ssh/config` gets a managed block for
those hosts and leaves the rest of the file alone.

`.chezmoidata/git.toml` lists the git hosts (`gitHosts`) and the public keys
trusted to sign (`git.signerKeys`), which `~/.config/git/allowed_signers` is
built from so `git verify-commit` works for commits from any machine. The
first MacBook's key (sold, replaced by this one) stays listed so its old
signed commits still verify.

On a new machine:

1. `ssh-keygen -t ed25519 -C "$USER@$(hostname -s)"` (a passphrase is
   optional; with one, git asks for it when signing).
2. Add `~/.ssh/id_ed25519.pub` to `git.signerKeys`, to `sshAuthorizedKeys` on
   the peer machines, and to your account on each git host, marked for
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
skill with `chezmoi add <skill-directory>` before committing; apply on the
other machines to install it. Codex's `.system` skills, Claude's `synced`
cache and installer metadata are not tracked. Omarchy's `omarchy` and
`diagnose-crash` symlinks stay Linux-only and are not installed on the Mac.

## Servers

A remote host reached over SSH uses the `server` profile: the same shell,
tmux, editor, git and agent configuration and the same mise toolchain, but no
desktop theming, no native package install (servers usually give no sudo) and
no peer machines. The profile is stored as `data.profile` in the chezmoi
config; every other value defaults to `workstation`, so the Mac and the
Omarchy machines behave exactly as before.

Install on a fresh server with the bootstrap script (`git` is the only
prerequisite):

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cosmicstasia/dotfiles/main/install-server.sh)"
```

By hand, if you prefer:

```sh
sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
DOTFILES_PROFILE=server chezmoi init --apply https://github.com/cosmicstasia/dotfiles.git
```

If an earlier `chezmoi init` ran without a repository, it left an empty Git
repository in `~/.local/share/chezmoi`; chezmoi then skips cloning and
`apply` silently does nothing. Remove it before retrying:

```sh
rm -rf ~/.local/share/chezmoi
```

What differs:

- `run_onchange_after_20-native-packages.sh` installs nothing: the mise config
  is the whole toolchain. Every tool lands under `~/.local`, so no sudo is
  needed; the host still needs `git` and `curl` to bootstrap.
- Desktop app configs are ignored: kitty, Hyprland, btop, Omarchy, tuios,
  Emacs and `xdg-terminals.list`.
- The login-shell script switches to zsh only when zsh exists and passwordless
  sudo works; otherwise it leaves bash and prints the command to run.
- `~/.bash_profile` and `~/.bashrc` hand interactive bash sessions to zsh (set
  `DOTFILES_BASH_KEEP=1` to stay in bash); bash also gets the mise shims on
  `PATH`.
- Peers, the Obsidian vault, the Talos config and the herdr workspace path are
  not prompted for. Git signing, SSH keys, the git-host block and the agent
  skills still apply, so generate `~/.ssh/id_ed25519` on the server first if
  you want signed commits there (see "On a new machine").

After `init` the profile is in the config file, so plain `chezmoi apply` works
without the environment variable.

## Bootstrap

```sh
chezmoi init https://github.com/cosmicstasia/dotfiles.git
chezmoi diff
chezmoi apply
```

The scripts run in order: install mise, install native packages (Homebrew or
pacman), `mise install`, generate the Nushell integrations, install the tuios
omp integration, and set zsh as the login shell. The first initialization
prompts for machine-specific paths, the peer list and the 9router key; re-run
`chezmoi init` to change them later. On a server, prefix the init with
`DOTFILES_PROFILE=server` (see Servers above).
