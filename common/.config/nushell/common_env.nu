# common env.nu

$env.EDITOR = "micro"
$env.FD_DIRS_IGNORE = ".cache node_modules target vendor .git"

# Ensure cache directory exists
let cache_dir = ($env.HOME | path join ".cache" "nushell")
if not ($cache_dir | path exists) {
    mkdir $cache_dir
}

# Tool Initializations
# We generate these files in env.nu so they can be sourced in config.nu

# Mise
if not (which mise | is-empty) {
    ^mise activate nu | save -f ($cache_dir | path join "mise.nu")
} else {
    "" | save -f ($cache_dir | path join "mise.nu")
}

# Zoxide
if not (which zoxide | is-empty) {
    ^zoxide init nushell --cmd cd | save -f ($cache_dir | path join "zoxide.nu")
} else {
    "" | save -f ($cache_dir | path join "zoxide.nu")
}

# Carapace
if not (which carapace | is-empty) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    ^carapace _carapace nushell | save -f ($cache_dir | path join "carapace.nu")
} else {
    "" | save -f ($cache_dir | path join "carapace.nu")
}

# Starship
if not (which starship | is-empty) {
    ^starship init nu | save -f ($cache_dir | path join "starship.nu")
} else {
    "" | save -f ($cache_dir | path join "starship.nu")
}

# Navi
if not (which navi | is-empty) {
    ^navi widget nushell | save -f ($cache_dir | path join "navi.nu")
} else {
    "" | save -f ($cache_dir | path join "navi.nu")
}
