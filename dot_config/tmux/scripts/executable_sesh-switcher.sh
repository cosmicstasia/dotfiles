#!/usr/bin/env bash

set -u

readonly script_path="${BASH_SOURCE[0]}"

strip_ansi() {
  local value="$1"

  while [[ "$value" =~ $'\e'\[[0-9\;]*m ]]; do
    value="${value/"${BASH_REMATCH[0]}"/}"
  done

  printf '%s' "$value"
}

kill_tmux_session() {
  local entry="${1:-}"
  local plain target

  [[ -n "$entry" ]] || exit 0

  plain="$(strip_ansi "$entry")"
  target="${plain#* }"

  # Ignore zoxide/config/path entries; only exact tmux session names are removed.
  if [[ "$target" != "$plain" ]] && tmux has-session -t "=$target" 2>/dev/null; then
    tmux kill-session -t "=$target"
  fi
}

if [[ "${1:-}" == "--kill" ]]; then
  kill_tmux_session "${2:-}"
  exit 0
fi

# fzf actions use $SHELL. Force a POSIX-compatible shell because tmux itself
# uses Nushell as its interactive default shell.
export SHELL=/bin/bash

selection="$(
  sesh list --icons --hide-duplicates |
    fzf \
      --ansi \
      --no-sort \
      --cycle \
      --info=inline-right \
      --prompt='⚡  ' \
      --pointer='▶' \
      --header='^r all  ^t tmux  ^g configs  ^x zoxide  ^f find  ^d kill  ctrl-space preview' \
      --bind='tab:down,btab:up' \
      --bind='ctrl-r:change-prompt(⚡  )+reload(sesh list --icons --hide-duplicates)' \
      --bind='ctrl-t:change-prompt(🪟  )+reload(sesh list --tmux --icons)' \
      --bind='ctrl-g:change-prompt(⚙️  )+reload(sesh list --config --icons)' \
      --bind='ctrl-x:change-prompt(📁  )+reload(sesh list --zoxide --icons)' \
      --bind='ctrl-f:change-prompt(🔎  )+reload(fd --hidden --max-depth 2 --type d --exclude .Trash . ~)' \
      --bind="ctrl-d:execute-silent($script_path --kill {})+change-prompt(⚡  )+reload(sesh list --icons --hide-duplicates)" \
      --bind='ctrl-space:toggle-preview' \
      --preview-window='right,55%,border-left' \
      --preview='sesh preview {}'
)" || exit 0

[[ -n "$selection" ]] || exit 0
exec sesh connect "$selection"
