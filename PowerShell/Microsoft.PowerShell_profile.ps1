# PowerToys CommandNotFound module
#f45873b3-b655-43a6-b217-97c00aa0db58
Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

# Starshipの起動 (コマンドがある場合のみ実行)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })

# エイリアス設定 (コマンドがある場合のみ設定)
if (Get-Command bat -ErrorAction SilentlyContinue) { Set-Alias cat bat }
if (Get-Command rg -ErrorAction SilentlyContinue)  { Set-Alias grep rg }
if (Get-Command fd -ErrorAction SilentlyContinue)  { Set-Alias find fd }

# ls を eza に置き換える関数 (ezaがある場合のみ)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l { eza -lh --icons --git $args }
    Set-Alias ls eza
}
