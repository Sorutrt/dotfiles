function Get-CodexManagedSkillMappings {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRoot,

        [Parameter(Mandatory = $true)]
        [string]$TargetRoot
    )

    if (-not (Test-Path -LiteralPath $SourceRoot)) {
        return @()
    }

    $resolvedSourceRoot = [IO.Path]::GetFullPath($SourceRoot)
    $resolvedTargetRoot = [IO.Path]::GetFullPath($TargetRoot)

    $mappings = @{}
    $skillFiles = Get-ChildItem -LiteralPath $resolvedSourceRoot -Filter "SKILL.md" -File -Recurse |
        Sort-Object -Property FullName

    foreach ($skillFile in $skillFiles) {
        $skillDir = Split-Path -Path $skillFile.FullName -Parent
        $relativePath = [IO.Path]::GetRelativePath($resolvedSourceRoot, $skillDir)

        $mappings[$relativePath] = [pscustomobject]@{
            RelativePath = $relativePath
            SourcePath   = $skillDir
            TargetPath   = Join-Path $resolvedTargetRoot $relativePath
        }
    }

    return $mappings.Keys |
        Sort-Object |
        ForEach-Object { $mappings[$_] }
}

function Test-DirectoryContentMatches {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExpectedPath,

        [Parameter(Mandatory = $true)]
        [string]$ActualPath
    )

    if (-not (Test-Path -LiteralPath $ExpectedPath -PathType Container)) {
        return $false
    }

    if (-not (Test-Path -LiteralPath $ActualPath -PathType Container)) {
        return $false
    }

    $resolvedExpectedPath = [IO.Path]::GetFullPath($ExpectedPath)
    $resolvedActualPath = [IO.Path]::GetFullPath($ActualPath)

    $expectedFiles = Get-ChildItem -LiteralPath $resolvedExpectedPath -File -Recurse -Force
    $actualFiles = Get-ChildItem -LiteralPath $resolvedActualPath -File -Recurse -Force

    if ($expectedFiles.Count -ne $actualFiles.Count) {
        return $false
    }

    $expectedHashes = @{}
    foreach ($file in $expectedFiles) {
        $relativePath = [IO.Path]::GetRelativePath($resolvedExpectedPath, $file.FullName)
        $expectedHashes[$relativePath] = (Get-FileHash -LiteralPath $file.FullName).Hash
    }

    $actualHashes = @{}
    foreach ($file in $actualFiles) {
        $relativePath = [IO.Path]::GetRelativePath($resolvedActualPath, $file.FullName)
        $actualHashes[$relativePath] = (Get-FileHash -LiteralPath $file.FullName).Hash
    }

    foreach ($relativePath in $expectedHashes.Keys) {
        if (-not $actualHashes.ContainsKey($relativePath)) {
            return $false
        }

        if ($expectedHashes[$relativePath] -ne $actualHashes[$relativePath]) {
            return $false
        }
    }

    return $true
}
