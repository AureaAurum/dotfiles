# インタラクティブシェルとして起動した場合のみNushellに移行
if [[ $- == *i* ]] && [[ -x "$(command -v nu)" ]]; then
    exec nu
fi