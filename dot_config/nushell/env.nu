let extra_paths = [
    ($env.HOME | path join ".local" "bin")
    ($env.HOME | path join ".cargo" "bin")
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "/home/linuxbrew/.linuxbrew/bin"
]

$env.PATH = (
    if (($env.PATH | describe) =~ "string") {
        $env.PATH | split row (char esep)
    } else {
        $env.PATH
    }
    | prepend $extra_paths
    | uniq
)

let mise_path = $nu.default-config-dir | path join "mise.nu"
let mise_bin = (
    which mise --all
    | where type == external
    | get path
    | first 1
    | get -o 0
)

if ($mise_bin != null) and not ($mise_path | path exists) {
    ^$mise_bin activate nu | save $mise_path
}
