$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "..\lib\Links.ps1")

Describe "Get-ManagedLinkType" {
    It "uses hard links for files on the same volume" {
        $sourcePath = Join-Path $TestDrive "source.txt"
        $targetPath = Join-Path $TestDrive "target.txt"

        Set-Content -Path $sourcePath -Value "content"

        Get-ManagedLinkType -SourcePath $sourcePath -TargetPath $targetPath | Should Be "HardLink"
    }

    It "uses junctions for directories" {
        $sourcePath = Join-Path $TestDrive "source-dir"
        $targetPath = Join-Path $TestDrive "target-dir"

        New-Item -ItemType Directory -Path $sourcePath -Force | Out-Null

        Get-ManagedLinkType -SourcePath $sourcePath -TargetPath $targetPath | Should Be "Junction"
    }
}

Describe "New-ManagedLink" {
    It "creates hard links for files" {
        $sourcePath = Join-Path $TestDrive "source.txt"
        $targetPath = Join-Path $TestDrive "nested\target.txt"

        Set-Content -Path $sourcePath -Value "content"

        $result = New-ManagedLink -SourcePath $sourcePath -TargetPath $targetPath

        $result.LinkType | Should Be "HardLink"
        (Get-Content -Path $targetPath) | Should Be "content"

        Set-Content -Path $targetPath -Value "changed"
        (Get-Content -Path $sourcePath) | Should Be "changed"
    }

    It "creates junctions for directories" {
        $sourcePath = Join-Path $TestDrive "source-dir"
        $targetPath = Join-Path $TestDrive "nested\target-dir"

        New-Item -ItemType Directory -Path $sourcePath -Force | Out-Null
        Set-Content -Path (Join-Path $sourcePath "file.txt") -Value "content"

        $result = New-ManagedLink -SourcePath $sourcePath -TargetPath $targetPath

        $result.LinkType | Should Be "Junction"
        (Test-Path -LiteralPath (Join-Path $targetPath "file.txt")) | Should Be $true
        ((Get-Item -LiteralPath $targetPath).Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 | Should Be $true
    }
}
