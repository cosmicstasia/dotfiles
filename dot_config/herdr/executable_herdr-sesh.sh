#!/usr/bin/env bash

set -euo pipefail

for dependency in herdr jq fzf; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'herdr-sesh: missing dependency: %s\n' "$dependency" >&2
    exit 1
  fi
done

workspace_json="$(herdr workspace list)"
rows="$({
  jq -r '
    .result.workspaces[] |
    [
      .workspace_id,
      (if .focused then "●" else " " end),
      (.label // .workspace_id),
      ("#" + (.number | tostring)),
      ((.tab_count | tostring) + if .tab_count == 1 then " tab" else " tabs" end),
      ((.pane_count | tostring) + if .pane_count == 1 then " pane" else " panes" end),
      (.agent_status // "idle")
    ] | @tsv
  ' <<<"$workspace_json"
} )"

[[ -n "$rows" ]] || exit 0

selection="$({
  printf '%s\n' "$rows" |
    fzf \
      --ansi \
      --cycle \
      --delimiter=$'\t' \
      --with-nth=2.. \
      --nth=2.. \
      --layout=reverse \
      --info=inline-right \
      --prompt='⚡  ' \
      --pointer='▶' \
      --header='Search Herdr workspaces · Enter to switch · Esc to close' \
      --border=rounded \
      --color='bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#a6adc8,info:#cba6f7,pointer:#f5e0dc,marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
} )" || exit 0

workspace_id="${selection%%$'\t'*}"
[[ -n "$workspace_id" ]] || exit 0

herdr workspace focus "$workspace_id" >/dev/null
