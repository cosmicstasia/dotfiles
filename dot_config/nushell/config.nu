# ~/.config/nushell/config.nu

$env.config.show_banner = false

overlay use starship.nu 
overlay use zoxide.nu 

# ------- SSH Agent ---------------------------------------------------------- 
if "XDG_RUNTIME_DIR" in $env {
    $env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
}
# --- Aliases ---------------------------------------------------------------
alias python = python3
alias oc = opencode
alias v = nvim
alias vim = nvim
alias vi = nvim
alias k = kubectl
alias lg = lazygit
alias cat = bat
alias cd = z
alias weather = curl wttr.in
alias py = python3
alias ".." = cd ..


# --- path join ---------------------------------------------------------------
$env.PATH = ($env.PATH | prepend [
    "/opt/homebrew/bin"
    "/usr/local/bin"
    $"($env.HOME)/.cargo/bin"
    $"($env.HOME)/.bun"
    $"($env.HOME)/.bun/bin"
    $"($env.HOME)/.local/bin"
])


# --- tv / carapace vendor autoload -----------------------------------------
mkdir ($nu.data-dir | path join "vendor/autoload")
tv init nu | save -f ($nu.data-dir | path join "vendor/autoload/tv.nu")

# --- Completers --------------------------------------------------------
let carapace_completer = {|spans: list<string>|
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}


let external_completer = {|spans: list<string>|
    let expanded_alias = (
      scope aliases
      | where name == $spans.0
      | get -o 0.expansion
    )
    let resolved_spans = if $expanded_alias != null {
      $spans
      | skip 1
      | prepend ($expanded_alias | split row " " | get 0)
    } else {
      $spans
    }
    match $resolved_spans.0 {
      git => (do $carapace_completer $resolved_spans)
      ssh => (do $carapace_completer $resolved_spans)
      scp => (do $carapace_completer $resolved_spans)
      sftp => (do $carapace_completer $resolved_spans)
      _ => (do $carapace_completer $resolved_spans)
    }
}

$env.config = (
    $env.config
    | merge {
        completions: {
          external: {
            enable: true
            completer: $external_completer
          }
        }
      }
)
$env.EDITOR = "nvim"
$env.TALOSCONFIG = ($env.HOME | path join "Projects/BM/talos_setup/credentials/talosconfig")
# --- direnv ------------------------------------------------------------
# Home Manager's `programs.direnv.enable` wires this hook automatically;
# in a plain config you add it yourself:
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | default []
    | append {|before, after| direnv export json | from json | default {} | load-env }
)

use std/formats "from ndjson"
