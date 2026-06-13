# インタラクティブシェルとして起動した場合のみNushellに移行
if [[ $- == *i* ]] && [ -t 0 ] && [[ -x "$(command -v nu)" ]]; then
    exec nu
fi

# Added by Antigravity CLI installer
export PATH="/home/aurea/.local/bin:$PATH"
