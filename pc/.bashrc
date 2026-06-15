# インタラクティブシェルとして起動した場合のみNushellに移行
# ただし、VS CodeのCopilotなどのバックグラウンド流し込み（非通常の統合ターミナル）を弾く
if [[ $- == *i* ]] && [ -t 0 ] && [[ -x "$(command -v nu)" ]]; then
    # VS Code環境下での判定
    if [[ "$TERM_PROGRAM" == "vscode" ]]; then
        # VS Codeの通常の統合ターミナルは、環境変数に「静的なシェル（nu）」を要求することが多いです。
        # Copilot Chatの流し込み（バックグラウンドのpty）と通常のターミナルを区別するため、
        # VS Code内では明示的な起動（またはVS Code側のプロファイル設定）に任せるか、
        # もしくはCopilot固有の環境変数をここで弾きます。
        
        # Copilot Chat実行時は、特定の環境変数が欠落するか、あるいは
        # VS Codeの通常起動プロセス（VSCODE_SHELL_INTEGRATIONなど）と挙動が異なります。
        # 安全策として、VS Code内では自動 exec nu をスキップし、
        # VS Codeの設定（settings.json）側で直接 nu を指定するのが最も安全です。
        
        : # 何もしない（VS Code内ではBashのままにしておく）
    else
        # VS Code以外の「普通のターミナル」では確実にNushellへ移行
        exec nu
    fi
fi

# Added by Antigravity CLI installer
export PATH="/home/aurea/.local/bin:$PATH"