# server config.nu
source common_config.nu
$env.config.abbreviations.zd = 'zellij action detach'

def report-remote-command [command: string] {
    let encoded = ($command | encode base64)
    print -n $"(ansi osc)1337;SetUserVar=WEZTERM_PROG=($encoded)(char bel)"
}

# Attach SSH terminals once; child shells inside Zellij must not attach again.
if $nu.is-interactive and ($env.SSH_TTY? | is-not-empty) and (is-terminal --stdin) and ($env.ZELLIJ? | is-empty) {
    let hooks = ($env.config.hooks? | default {})
    $env.config.hooks = ($hooks
        | upsert pre_execution (($hooks.pre_execution? | default []) | append {|| report-remote-command (commandline) })
        | upsert pre_prompt (($hooks.pre_prompt? | default []) | append {|| report-remote-command '' }))

    if (which zellij | is-not-empty) {
        report-remote-command 'zellij'
        ^zellij attach --create main
        report-remote-command ''
    }
}
