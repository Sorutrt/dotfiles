function Test-IsReparsePoint {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    $item = Get-Item -LiteralPath $Path -Force
    return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

function Ensure-DirectoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        if (Test-IsReparsePoint -Path $Path) {
            Remove-Item -LiteralPath $Path -Recurse -Force
        } else {
            $item = Get-Item -LiteralPath $Path -Force
            if (-not $item.PSIsContainer) {
                throw "Expected directory path but found file: $Path"
            }

            return
        }
    }

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
}

function Get-ManagedLinkType {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $sourceItem = Get-Item -LiteralPath $SourcePath -Force
    if ($sourceItem.PSIsContainer) {
        return "Junction"
    }

    $sourceRoot = [IO.Path]::GetPathRoot([IO.Path]::GetFullPath($SourcePath))
    $targetRoot = [IO.Path]::GetPathRoot([IO.Path]::GetFullPath($TargetPath))

    if ($sourceRoot -eq $targetRoot) {
        return "HardLink"
    }

    return "SymbolicLink"
}

function New-ManagedLink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $linkType = Get-ManagedLinkType -SourcePath $SourcePath -TargetPath $TargetPath
    $targetParentPath = Split-Path -Path $TargetPath -Parent

    if ($targetParentPath) {
        Ensure-DirectoryPath -Path $targetParentPath
    }

    New-Item -ItemType $linkType -Path $TargetPath -Value $SourcePath -ErrorAction Stop | Out-Null

    return [pscustomobject]@{
        LinkType   = $linkType
        SourcePath = $SourcePath
        TargetPath = $TargetPath
    }
}
