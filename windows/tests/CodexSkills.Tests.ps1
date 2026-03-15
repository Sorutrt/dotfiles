$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "..\lib\CodexSkills.ps1")

Describe "Get-CodexManagedSkillMappings" {
    It "finds managed skills at the root and under public namespaces" {
        $sourceRoot = Join-Path $TestDrive "skills"
        $targetRoot = Join-Path $TestDrive "published"

        New-Item -ItemType Directory -Path (Join-Path $sourceRoot "dotfiles-maintainer") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $sourceRoot "public\aivoice-editor-api") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $sourceRoot "public\ignored-parent") -Force | Out-Null

        Set-Content -Path (Join-Path $sourceRoot "dotfiles-maintainer\SKILL.md") -Value "# skill"
        Set-Content -Path (Join-Path $sourceRoot "public\aivoice-editor-api\SKILL.md") -Value "# skill"

        $mappings = Get-CodexManagedSkillMappings -SourceRoot $sourceRoot -TargetRoot $targetRoot
        $relativePaths = $mappings | Select-Object -ExpandProperty RelativePath

        $mappings.Count | Should Be 2
        ($relativePaths -contains "dotfiles-maintainer") | Should Be $true
        ($relativePaths -contains "public\aivoice-editor-api") | Should Be $true
        ($relativePaths -contains "public\ignored-parent") | Should Be $false
    }
}

Describe "Test-DirectoryContentMatches" {
    It "returns true for identical directory trees" {
        $expectedPath = Join-Path $TestDrive "expected"
        $actualPath = Join-Path $TestDrive "actual"

        New-Item -ItemType Directory -Path (Join-Path $expectedPath "references") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $actualPath "references") -Force | Out-Null

        Set-Content -Path (Join-Path $expectedPath "SKILL.md") -Value "skill"
        Set-Content -Path (Join-Path $expectedPath "references\api.md") -Value "reference"
        Set-Content -Path (Join-Path $actualPath "SKILL.md") -Value "skill"
        Set-Content -Path (Join-Path $actualPath "references\api.md") -Value "reference"

        Test-DirectoryContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath | Should Be $true
    }

    It "returns false when file content differs" {
        $expectedPath = Join-Path $TestDrive "expected"
        $actualPath = Join-Path $TestDrive "actual"

        New-Item -ItemType Directory -Path $expectedPath -Force | Out-Null
        New-Item -ItemType Directory -Path $actualPath -Force | Out-Null

        Set-Content -Path (Join-Path $expectedPath "SKILL.md") -Value "skill"
        Set-Content -Path (Join-Path $actualPath "SKILL.md") -Value "different"

        Test-DirectoryContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath | Should Be $false
    }
}
