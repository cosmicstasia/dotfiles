#!/bin/sh
# Install the server profile of these dotfiles on a headless Linux host.
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/cosmicstasia/dotfiles/main/install-server.sh)"
#
# Override DOTFILES_REPO or DOTFILES_SOURCE if needed. Idempotent: running it
# again applies the latest dotfiles.
set -eu

repo=${DOTFILES_REPO:-https://github.com/cosmicstasia/dotfiles.git}
src=${DOTFILES_SOURCE:-$HOME/.local/share/chezmoi}

# ~/.local/bin is not on the default PATH on a fresh host.
PATH="$HOME/.local/bin:$PATH"
export PATH

if ! command -v git >/dev/null 2>&1; then
  echo "git is required to clone the dotfiles; install it and re-run." >&2
  exit 1
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

# A malformed first run (`chezmoi init` with no repo) leaves an empty Git
# repository in the source directory. chezmoi then detects a repository and
# skips cloning, so `apply` silently does nothing. Clear that empty repo.
if [ -d "$src/.git" ] && [ -z "$(git -C "$src" ls-files 2>/dev/null)" ]; then
  echo "removing empty chezmoi source directory $src" >&2
  rm -rf "$src"
fi

DOTFILES_PROFILE=server chezmoi init --apply "$repo"
