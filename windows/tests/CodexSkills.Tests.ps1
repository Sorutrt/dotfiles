$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $here "TestAssertions.ps1")
. (Join-Path $here "..\lib\CodexSkills.ps1")

Invoke-Test "Get-CodexManagedSkillMappings finds managed skills at the root and under public namespaces" {
    param($TestRoot)

    $sourceRoot = Join-Path $TestRoot "skills"
    $targetRoot = Join-Path $TestRoot "published"
    $publicRoot = Join-Path $sourceRoot "public"
    $publicSkillPath = Join-Path $publicRoot "aivoice-editor-api"
    $ignoredPublicPath = Join-Path $publicRoot "ignored-parent"
    $dotfilesSkillPath = Join-Path $sourceRoot "dotfiles-maintainer"
    $publicSkillRelativePath = Join-Path "public" "aivoice-editor-api"
    $ignoredPublicRelativePath = Join-Path "public" "ignored-parent"

    New-Item -ItemType Directory -Path $dotfilesSkillPath -Force | Out-Null
    New-Item -ItemType Directory -Path $publicSkillPath -Force | Out-Null
    New-Item -ItemType Directory -Path $ignoredPublicPath -Force | Out-Null

    Set-Content -Path (Join-Path $dotfilesSkillPath "SKILL.md") -Value "# skill"
    Set-Content -Path (Join-Path $publicSkillPath "SKILL.md") -Value "# skill"

    $mappings = Get-CodexManagedSkillMappings -SourceRoot $sourceRoot -TargetRoot $targetRoot
    $relativePaths = $mappings | Select-Object -ExpandProperty RelativePath

    Assert-Equal -Actual $mappings.Count -Expected 2
    Assert-True `
        -Condition ($relativePaths -contains "dotfiles-maintainer") `
        -Message "Expected root skill to be mapped."
    Assert-True `
        -Condition ($relativePaths -contains $publicSkillRelativePath) `
        -Message "Expected public skill to be mapped."
    Assert-True `
        -Condition (-not ($relativePaths -contains $ignoredPublicRelativePath)) `
        -Message "Expected directory without SKILL.md to be ignored."
}

Invoke-Test "Test-DirectoryContentMatches returns true for identical directory trees" {
    param($TestRoot)

    $expectedPath = Join-Path $TestRoot "expected"
    $actualPath = Join-Path $TestRoot "actual"
    $expectedReferencesPath = Join-Path $expectedPath "references"
    $actualReferencesPath = Join-Path $actualPath "references"

    New-Item -ItemType Directory -Path $expectedReferencesPath -Force | Out-Null
    New-Item -ItemType Directory -Path $actualReferencesPath -Force | Out-Null

    Set-Content -Path (Join-Path $expectedPath "SKILL.md") -Value "skill"
    Set-Content -Path (Join-Path $expectedReferencesPath "api.md") -Value "reference"
    Set-Content -Path (Join-Path $actualPath "SKILL.md") -Value "skill"
    Set-Content -Path (Join-Path $actualReferencesPath "api.md") -Value "reference"

    Assert-True `
        -Condition (Test-DirectoryContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath) `
        -Message "Expected matching directories to compare equal."
}

Invoke-Test "Test-DirectoryContentMatches returns false when file content differs" {
    param($TestRoot)

    $expectedPath = Join-Path $TestRoot "expected"
    $actualPath = Join-Path $TestRoot "actual"

    New-Item -ItemType Directory -Path $expectedPath -Force | Out-Null
    New-Item -ItemType Directory -Path $actualPath -Force | Out-Null

    Set-Content -Path (Join-Path $expectedPath "SKILL.md") -Value "skill"
    Set-Content -Path (Join-Path $actualPath "SKILL.md") -Value "different"

    Assert-True `
        -Condition (-not (Test-DirectoryContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath)) `
        -Message "Expected directories with different file content to compare unequal."
}

Invoke-Test "Test-FileContentMatches returns true for identical files" {
    param($TestRoot)

    $expectedPath = Join-Path $TestRoot "expected.md"
    $actualPath = Join-Path $TestRoot "actual.md"

    Set-Content -Path $expectedPath -Value "same"
    Set-Content -Path $actualPath -Value "same"

    Assert-True `
        -Condition (Test-FileContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath) `
        -Message "Expected matching files to compare equal."
}

Invoke-Test "Test-FileContentMatches returns false when file content differs" {
    param($TestRoot)

    $expectedPath = Join-Path $TestRoot "expected.md"
    $actualPath = Join-Path $TestRoot "actual.md"

    Set-Content -Path $expectedPath -Value "same"
    Set-Content -Path $actualPath -Value "different"

    Assert-True `
        -Condition (-not (Test-FileContentMatches -ExpectedPath $expectedPath -ActualPath $actualPath)) `
        -Message "Expected files with different content to compare unequal."
}

Complete-TestRun
