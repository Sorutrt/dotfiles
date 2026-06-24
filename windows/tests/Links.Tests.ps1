$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "TestAssertions.ps1")
. (Join-Path $here "..\lib\Links.ps1")

Invoke-Test "Get-ManagedLinkType uses hard links for files on the same volume" {
    param($TestRoot)

    $sourcePath = Join-Path $TestRoot "source.txt"
    $targetPath = Join-Path $TestRoot "target.txt"

    Set-Content -Path $sourcePath -Value "content"

    Assert-Equal `
        -Actual (Get-ManagedLinkType -SourcePath $sourcePath -TargetPath $targetPath) `
        -Expected "HardLink"
}

Invoke-Test "Get-ManagedLinkType uses junctions for directories" {
    param($TestRoot)

    $sourcePath = Join-Path $TestRoot "source-dir"
    $targetPath = Join-Path $TestRoot "target-dir"

    New-Item -ItemType Directory -Path $sourcePath -Force | Out-Null

    Assert-Equal `
        -Actual (Get-ManagedLinkType -SourcePath $sourcePath -TargetPath $targetPath) `
        -Expected "Junction"
}

Invoke-Test "New-ManagedLink creates hard links for files" {
    param($TestRoot)

    $sourcePath = Join-Path $TestRoot "source.txt"
    $targetPath = Join-Path (Join-Path $TestRoot "nested") "target.txt"

    Set-Content -Path $sourcePath -Value "content"

    $result = New-ManagedLink -SourcePath $sourcePath -TargetPath $targetPath

    Assert-Equal -Actual $result.LinkType -Expected "HardLink"
    Assert-Equal -Actual (Get-Content -Path $targetPath) -Expected "content"

    Set-Content -Path $targetPath -Value "changed"
    Assert-Equal -Actual (Get-Content -Path $sourcePath) -Expected "changed"
}

if ($IsWindows) {
    Invoke-Test "New-ManagedLink creates junctions for directories" {
        param($TestRoot)

        $sourcePath = Join-Path $TestRoot "source-dir"
        $targetPath = Join-Path (Join-Path $TestRoot "nested") "target-dir"

        New-Item -ItemType Directory -Path $sourcePath -Force | Out-Null
        Set-Content -Path (Join-Path $sourcePath "file.txt") -Value "content"

        $result = New-ManagedLink -SourcePath $sourcePath -TargetPath $targetPath

        Assert-Equal -Actual $result.LinkType -Expected "Junction"
        Assert-True `
            -Condition (Test-Path -LiteralPath (Join-Path $targetPath "file.txt")) `
            -Message "Expected target junction to expose source directory contents."
        Assert-True `
            -Condition (((Get-Item -LiteralPath $targetPath).Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) `
            -Message "Expected target directory to be a reparse point."
    }
} else {
    Invoke-SkippedTest `
        -Name "New-ManagedLink creates junctions for directories" `
        -Reason "junction creation is Windows-specific"
}

Complete-TestRun
