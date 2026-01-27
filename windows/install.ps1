# --------------------------------------------------
#
#                  NeoVim
#
# --------------------------------------------------
# create directory for init.lua if it doesn't exist
$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"

if (-not (Test-Path $nvimDir)) {
    New-Item -ItemType Directory -Path $nvimDir | Out-Null
}

# paths to target files
$initLua = "$nvimDir\init.lua"
$cocSettings = "$nvimDir\coc-settings.json"

# source files (your repo or working directory)
$sourceInitLua = Join-Path $PSScriptRoot "nvim\init.lua"
$sourceCocSettings = Join-Path $PSScriptRoot "nvim\coc-settings.json"

# remove existing files if they exist (file or symlink)
if (Test-Path $initLua) {
    Remove-Item $initLua -Force
}
if (Test-Path $cocSettings) {
    Remove-Item $cocSettings -Force
}

# create symbolic links
New-Item -ItemType SymbolicLink -Path $initLua -Value $sourceInitLua | Out-Null
New-Item -ItemType SymbolicLink -Path $cocSettings -Value $sourceCocSettings | Out-Null

Write-Host "Symlinks created:"
Write-Host "  init.lua -> $sourceInitLua"
Write-Host "  coc-settings.json -> $sourceCocSettings"

# jetpack-nvim pack
$jetpackpack = "$nvimDir\pack\jetpack\opt"
if (-not (Test-Path $jetpackpack)) {
    git clone https://github.com/tani/vim-jetpack "$env:LOCALAPPDATA\nvim\pack\jetpack\opt\vim-jetpack"
}

# ------------------- end of NeoVim ----------------------


# --------------------------------------------------
#
#                  PowerShell
#
# --------------------------------------------------
# Check if Oh My Posh is installed, if not install it
$ohMyPoshInstalled = Get-Command oh-my-posh -ErrorAction SilentlyContinue

if (-not $ohMyPoshInstalled) {
    Write-Host "Oh My Posh not found. Installing via winget..."
    winget install JanDeDobbeleer.OhMyPosh --source winget
    Write-Host "Oh My Posh installed successfully."
} else {
    Write-Host "Oh My Posh is already installed."
}

# PowerShell profile directory
$psProfileDir = Split-Path $PROFILE -Parent

if (-not (Test-Path $psProfileDir)) {
    New-Item -ItemType Directory -Path $psProfileDir | Out-Null
}

# path to target profile
$psProfile = $PROFILE

# source file (your repo)
$sourcePsProfile = Join-Path $PSScriptRoot "powershell\Microsoft.PowerShell_profile.ps1"

# remove existing profile if it exists (file or symlink)
if (Test-Path $psProfile) {
    Remove-Item $psProfile -Force
}

# create symbolic link
New-Item -ItemType SymbolicLink -Path $psProfile -Value $sourcePsProfile | Out-Null

Write-Host "Symlink created:"
Write-Host "  PowerShell Profile -> $sourcePsProfile"

# ------------------- end of PowerShell ----------------------

