# Dotfiles

Cross-platform configuration for macOS and Arch Linux, managed by chezmoi.

## What Is Shared

- Nushell, Starship, Zoxide, Atuin, and direnv
- Git and SSH signing settings
- Neovim, tmux, Kitty, Yazi, btop, and Herdr configuration
- Command-line packages through Homebrew on macOS and Linuxbrew on Arch

Chezmoi templates keep package casks, SSH agent paths, Obsidian vaults, and other host-specific values local to each machine.

## Bootstrap

Install chezmoi, initialize this repository, and apply it:

```sh
chezmoi init https://github.com/cosmicstasia/dotfiles.git
chezmoi diff
chezmoi apply
```

On Arch, the bootstrap script installs Linuxbrew prerequisites and Linux-integrated packages with pacman. On macOS, GUI applications are installed as Homebrew casks. Both platforms install the shared CLI inventory from the rendered `~/Brewfile`.

The first initialization prompts for machine-specific paths. Re-run `chezmoi init` to update those values later.
