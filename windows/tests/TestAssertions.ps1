$script:TestFailureCount = 0

function New-TestRoot {
    $testRoot = Join-Path ([IO.Path]::GetTempPath()) "dotfiles-tests-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
    return $testRoot
}

function Remove-TestRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function Invoke-Test {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [scriptblock]$Body
    )

    $testRoot = New-TestRoot

    try {
        & $Body $testRoot
        Write-Host "ok - $Name"
    } catch {
        $script:TestFailureCount += 1
        Write-Host "not ok - $Name"
        Write-Host ($_ | Out-String)
    } finally {
        Remove-TestRoot -Path $testRoot
    }
}

function Invoke-SkippedTest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    Write-Host "skip - $Name ($Reason)"
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)]
        $Actual,

        [Parameter(Mandatory = $true)]
        $Expected
    )

    if ($Actual -ne $Expected) {
        throw "Expected <$Expected>, but got <$Actual>."
    }
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,

        [string]$Message = "Expected condition to be true."
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Complete-TestRun {
    if ($script:TestFailureCount -gt 0) {
        throw "$script:TestFailureCount test(s) failed."
    }
}
