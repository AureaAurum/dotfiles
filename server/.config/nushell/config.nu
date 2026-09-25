# server config.nu
source common_config.nu
$env.config.abbreviations.zd = 'zellij action detach'

# Attach SSH terminals once; child shells inside Zellij must not attach again.
if $nu.is-interactive and ($env.SSH_TTY? | is-not-empty) and (is-terminal --stdin) and ($env.ZELLIJ? | is-empty) and (which zellij | is-not-empty) {
    ^zellij attach --create main
}
