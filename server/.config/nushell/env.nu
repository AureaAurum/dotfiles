# server env.nu
let brew_prefix = "/home/linuxbrew/.linuxbrew"
if ($brew_prefix | path exists) {
    $env.HOMEBREW_PREFIX = $brew_prefix
    $env.HOMEBREW_CELLAR = ($brew_prefix | path join "Cellar")
    $env.HOMEBREW_REPOSITORY = ($brew_prefix | path join "Homebrew")
    
    # Update PATH
    $env.PATH = ($env.PATH | prepend [($brew_prefix | path join "bin"), ($brew_prefix | path join "sbin")])
    
    # Update MANPATH
    if ("MANPATH" in $env) {
        if ($env.MANPATH | describe) == "string" {
            $env.MANPATH = ($env.MANPATH | split row (char esep) | prepend [($brew_prefix | path join "share" "man")])
        } else {
            $env.MANPATH = ($env.MANPATH | prepend [($brew_prefix | path join "share" "man")])
        }
    } else {
        $env.MANPATH = [($brew_prefix | path join "share" "man")]
    }
    
    # Update INFOPATH
    if ("INFOPATH" in $env) {
        if ($env.INFOPATH | describe) == "string" {
            $env.INFOPATH = ($env.INFOPATH | split row (char esep) | prepend [($brew_prefix | path join "share" "info")])
        } else {
            $env.INFOPATH = ($env.INFOPATH | prepend [($brew_prefix | path join "share" "info")])
        }
    } else {
        $env.INFOPATH = [($brew_prefix | path join "share" "info")]
    }
}

source common_env.nu
