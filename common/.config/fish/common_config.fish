# common fish configuration migrated from nushell common_config.nu
# Abbreviations ported from nushell `abbreviations` (used by menus)
if type -q abbr
    abbr --add cat  'bat'
    abbr --add ps   'procs'
    abbr --add du   'dust'
    abbr --add df   'duf'
    abbr --add grep 'rg -i'
    abbr --add find 'fd'

    abbr --add ls  'eza --icons'
    abbr --add ll  'eza -l --icons'
    abbr --add la  'eza -la --icons'
    abbr --add lt  'eza --tree --level=2 --icons'
end

# --- starship prompt initialization ---
if type -q starship
    eval (starship init fish)
end

# --- zoxide initialization ---
if type -q zoxide
    eval (zoxide init fish)
end

# --- carapace initialization for enhanced completions ---
if type -q carapace
    # eval the generated fish init script
    eval (carapace init fish)
end

# End of common fish config
