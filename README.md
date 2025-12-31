# Dotfiles

Configuration files for my Unix environments (WSL2, RPi, OCI).
Managed by Ansible (Hybrid setup: Apt for system, Homebrew for tools).

## 🛠 Modern Unix Tools & Aliases

We use modern replacements for classic Unix commands to enhance productivity.
**Note**: Aliases are guarded by `if [[ -o interactive ]]` to ensure AI/Scripts see standard behavior.

| Command | Replacement | Alias | Description |
| :--- | :--- | :--- | :--- |
| `ls` | **eza** | `ls` | Modern listing with icons, git status, and headers. |
| `cat` | **bat** | `cat` | Syntax highlighting and git integration for file reading. |
| `ps` | **procs** | `ps` | Process viewer with syntax highlighting and tree view. |
| `du` | **dust** | `du` | Disk usage visualization (tree graph). |
| `df` | **duf** | `df` | Disk usage/free space utility (better layout). |
| `grep` | **ripgrep** | `grep` | Extremely fast search tool (recursively searches files). |
| `find` | **fd** | `find` | User-friendly alternative to find. |

### 💡 Alias Details per Command

#### 1. `ls` -> `eza`
- **Alias**: `alias ls='eza -h --icons --git'`
- **Extra Aliases**:
    - `ll`: `eza -lh --icons --git` (Long list, no hidden files)
    - `lt`: `eza --tree --level=2 --icons` (Tree view)
- **Usage**: Just run `ls` or `ll`. It shows file icons and git status usage automatically.

#### 2. `cat` -> `bat`
- **Alias**: `alias cat='bat'`
- **Usage**: `cat filename.py`
- **Features**: Syntax highlighting, line numbers, and git integration (shows added/modified lines).

#### 3. `ps` -> `procs`
- **Alias**: `alias ps='procs'`
- **Usage**: `ps`
- **Features**: Human-readable output, shows Docker container names, highlights PID/User.

#### 4. `du` -> `dust`
- **Alias**: `alias du='dust'`
- **Usage**: `du` (Wait a moment for calculation)
- **Features**: Graphical bar chart of directory sizes. Ascends from smallest to largest.

#### 5. `df` -> `duf`
- **Alias**: `alias df='duf'`
- **Usage**: `df`
- **Features**: Colorful table showing mount points, types, and usage.

#### 6. `grep` -> `rg` (ripgrep)
- **Alias**: `alias grep='rg'`
- **Usage**: `grep "search_term"`
- **Features**: Ignores `.git` and `.gitignore` files by default. Very fast.

#### 7. `find` -> `fd`
- **Alias**: `alias find='fd'`
- **Usage**: `find pattern` (No need for `-name`)
- **Features**: Simple syntax, ignores git files, colored output.

## 🚀 Deployment
This repository is deployed via Ansible.
- **Local**: Edited directly.
- **Remote (Pi/OCI)**: `ansible-playbook site.yml --tags dotfiles` triggers a `git pull`.

