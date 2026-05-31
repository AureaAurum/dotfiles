# Dotfiles

Configuration files for my Unix environments (WSL2, RPi, OCI).
Managed by Ansible (Hybrid setup: Apt for system, Homebrew for tools).

## 🛠 Modern Unix Tools & Abbreviations

We use modern replacements for classic Unix commands to enhance productivity.
**Note**: We use Nushell abbreviations instead of traditional aliases, which expand inline when you press space or enter. This ensures clarity and avoids issues with AI or scripts.

| Command | Replacement | Abbreviation | Description |
| :--- | :--- | :--- | :--- |
| `ls` | **eza** | `ls` | Modern listing with icons, git status, and headers. |
| `cat` | **bat** | `cat` | Syntax highlighting and git integration for file reading. |
| `ps` | **procs** | `ps` | Process viewer with syntax highlighting and tree view. |
| `du` | **dust** | `du` | Disk usage visualization (tree graph). |
| `df` | **duf** | `df` | Disk usage/free space utility (better layout). |
| `grep` | **ripgrep** | `grep` | Extremely fast search tool (recursively searches files). |
| `find` | **fd** | `find` | User-friendly alternative to find. |

### 💡 Abbreviation Details per Command

#### 1. `ls` -> `eza`
- **Abbreviation**: `ls` -> `eza --icons --git`
- **Extra Abbreviations**:
    - `ll`: `eza -l --icons --git` (Long list)
    - `la`: `eza -la --icons --git` (Long list, all files)
    - `lt`: `eza --tree --level=2 --icons --git` (Tree view)
- **Usage**: Type `ls`, `ll`, `la`, or `lt` and press space/enter to expand. It shows file icons and git status usage automatically.

#### 2. `cat` -> `bat`
- **Abbreviation**: `cat` -> `bat`
- **Usage**: `cat filename.py`
- **Features**: Syntax highlighting, line numbers, and git integration (shows added/modified lines).

#### 3. `ps` -> `procs`
- **Abbreviation**: `ps` -> `procs`
- **Usage**: `ps`
- **Features**: Human-readable output, shows Docker container names, highlights PID/User.

#### 4. `du` -> `dust`
- **Abbreviation**: `du` -> `dust`
- **Usage**: `du` (Wait a moment for calculation)
- **Features**: Graphical bar chart of directory sizes. Ascends from smallest to largest.

#### 5. `df` -> `duf`
- **Abbreviation**: `df` -> `duf`
- **Usage**: `df`
- **Features**: Colorful table showing mount points, types, and usage.

#### 6. `grep` -> `rg` (ripgrep)
- **Abbreviation**: `grep` -> `rg -i`
- **Usage**: `grep "search_term"`
- **Features**: Ignores `.git` and `.gitignore` files by default. Very fast.

#### 7. `find` -> `fd`
- **Abbreviation**: `find` -> `fd`
- **Usage**: `find pattern` (No need for `-name`)
- **Features**: Simple syntax, ignores git files, colored output.

## 🚀 Deployment
This repository is deployed via Stow and Ansible.
- **Local**: Deployed via `stow` (e.g., `stow common pc`).
- **Remote (Pi/OCI)**: `ansible-playbook site.yml --tags dotfiles` triggers a `git pull`.

