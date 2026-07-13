# ~/.config/nushell/config.nu

$env.config.show_banner = false

overlay use starship.nu 
overlay use zoxide.nu 

# ------- SSH Agent ---------------------------------------------------------- 
$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)/ssh-agent.socket"
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

let fish_completer = {|spans: list<string>|
    fish --command $"
      complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'
    "
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
        let value = $row.value
        let need_quote = [' ' '[' ']' '(' ')' '\t' "'" '"' '`'] | any {|x| $x in $value}
        if ($need_quote and ($value | path exists)) {
          let expanded_path = if ($value starts-with "~") {
            $value | path expand --no-symlink
          } else {
            $value
          }
          $'"($expanded_path | str replace --all "\"" "\\\"")"'
        } else {
          $value
        }
      }
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
      git => (do $fish_completer $resolved_spans)
      ssh => (do $fish_completer $resolved_spans)
      scp => (do $fish_completer $resolved_spans)
      sftp => (do $fish_completer $resolved_spans)
      _ => (do $fish_completer $resolved_spans)
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
# --- direnv ------------------------------------------------------------
# Home Manager's `programs.direnv.enable` wires this hook automatically;
# in a plain config you add it yourself:
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | default []
    | append {|before, after| direnv export json | from json | default {} | load-env }
)

use std/formats "from ndjson"
