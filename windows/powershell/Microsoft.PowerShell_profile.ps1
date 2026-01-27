# PowerShell Profile

# Set encoding to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Aliases
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim
Set-Alias lg lazygit.exe

# Functions
function lsa { Get-ChildItem -Force @args }
