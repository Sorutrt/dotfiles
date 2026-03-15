# repo root
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
. (Join-Path $PSScriptRoot "lib\CodexSkills.ps1")
. (Join-Path $PSScriptRoot "lib\Links.ps1")

function New-RepoLink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetPath,

        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $result = New-ManagedLink -SourcePath $SourcePath -TargetPath $TargetPath
    Write-Host "$Label created:"
    Write-Host "  [$($result.LinkType)] $TargetPath -> $SourcePath"
}

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
$sourceInitLua = Join-Path $repoRoot "nvim-win\init.lua"
$sourceCocSettings = Join-Path $repoRoot "nvim-win\coc-settings.json"

# remove existing files if they exist (file or symlink)
if (Test-Path $initLua) {
    Remove-Item $initLua -Force
}
if (Test-Path $cocSettings) {
    Remove-Item $cocSettings -Force
}

# create symbolic links
New-RepoLink -TargetPath $initLua -SourcePath $sourceInitLua -Label "Link"
New-RepoLink -TargetPath $cocSettings -SourcePath $sourceCocSettings -Label "Link"

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
New-RepoLink -TargetPath $psProfile -SourcePath $sourcePsProfile -Label "Link"

# ------------------- end of PowerShell ----------------------

# --------------------------------------------------
#
#                  Nushell
#
# --------------------------------------------------
# Nu config directory
$nuConfigDir = Join-Path $env:APPDATA "nushell"

if (-not (Test-Path $nuConfigDir)) {
    New-Item -ItemType Directory -Path $nuConfigDir | Out-Null
}

# path to target config
$nuConfig = Join-Path $nuConfigDir "config.nu"

# source file (your repo)
$sourceNuConfig = Join-Path $repoRoot "nushell\config.nu"

# remove existing config if it exists (file or symlink)
if (Test-Path $nuConfig) {
    Remove-Item $nuConfig -Force
}

# create symbolic link
New-RepoLink -TargetPath $nuConfig -SourcePath $sourceNuConfig -Label "Link"

# ------------------- end of Nushell ----------------------

# --------------------------------------------------
#
#                  Codex Skills
#
# --------------------------------------------------
$codexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"

if (-not (Test-Path $codexSkillsDir)) {
    New-Item -ItemType Directory -Path $codexSkillsDir | Out-Null
}

$sourceSkillRoot = Join-Path $repoRoot "codex\skills"

if (Test-Path $sourceSkillRoot) {
    $skillMappings = Get-CodexManagedSkillMappings -SourceRoot $sourceSkillRoot -TargetRoot $codexSkillsDir

    if ($skillMappings.Count -eq 0) {
        Write-Host "No repo-managed Codex skills found at $sourceSkillRoot"
    } else {
        foreach ($skillMapping in $skillMappings) {
            $targetSkillDir = $skillMapping.TargetPath
            $targetParentDir = Split-Path -Path $targetSkillDir -Parent

            Ensure-DirectoryPath -Path $targetParentDir

            if (Test-Path -LiteralPath $targetSkillDir) {
                if (Test-IsReparsePoint -Path $targetSkillDir) {
                    Remove-Item -LiteralPath $targetSkillDir -Recurse -Force
                } elseif (Test-DirectoryContentMatches -ExpectedPath $skillMapping.SourcePath -ActualPath $targetSkillDir) {
                    Remove-Item -LiteralPath $targetSkillDir -Recurse -Force
                } else {
                    Write-Warning "Skipping existing unmanaged Codex skill: $targetSkillDir"
                    continue
                }
            }

            New-RepoLink -TargetPath $targetSkillDir -SourcePath $skillMapping.SourcePath -Label "Link"
        }
    }
} else {
    Write-Host "No repo-managed Codex skills found at $sourceSkillRoot"
}

# ------------------- end of Codex Skills ----------------------
