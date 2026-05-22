# PC config.nu
source common_config.nu

# Zellij Auto-start logic
if (not ("ZELLIJ" in ($env | columns))) and (not (which zellij | is-empty)) and ($nu.is-interactive) {
    # 1. Session name and directory determination
    let repo_root = (do { git rev-parse --show-toplevel } | complete | get stdout | str trim)
    
    let is_git = ($repo_root | (is-not-empty))
    
    mut session_name = if $is_git {
        $repo_root | path basename
    } else {
        $env.PWD | path basename
    }

    # Replace dots and spaces with underscores
    $session_name = ($session_name | str replace --all "." "_" | str replace --all " " "_")

    # 2. VS Code check and layout setting
    mut layout_arg = []
    if ($env.TERM_PROGRAM? == "vscode") {
        $session_name = $"($session_name)-vscode"
    } else {
        let layouts_dir = ($env.HOME | path join ".config" "zellij" "layouts")
        let project_layout = ($layouts_dir | path join $"($session_name).kdl")
        
        if ($project_layout | path exists) {
            $layout_arg = ["--layout" $project_layout]
        } else if $is_git {
            $layout_arg = ["--layout" ($layouts_dir | path join "template_git.kdl")]
        } else {
            $layout_arg = ["--layout" ($layouts_dir | path join "template_default.kdl")]
        }
    }

    # 3. Launch Zellij
    # Check for exited sessions
    let list_sessions = (do { ^zellij list-sessions } | complete)
    if $list_sessions.exit_code == 0 {
        let current_session = $session_name
        let has_exited = ($list_sessions.stdout | lines | any { |it| $it has $"($current_session) \(EXITED\)" })
        if $has_exited {
            ^zellij delete-session $session_name
        }
    }
    
    # Launch Zellij
    ^zellij ...$layout_arg attach --create $session_name -f
}
