#Requires -Version 5.1
<#
.SYNOPSIS
    Bloot QA pipeline: run tests, build APK, distribute via Firebase App Distribution.

.DESCRIPTION
    This script automates the full QA workflow:
    1. Run unit & widget tests (flutter test)
    2. Run integration tests on a connected emulator (optional)
    3. Build a release APK (flutter build apk --release)
    4. Distribute via Fastlane to Firebase App Distribution

.PARAMETER SkipIntegration
    Skip integration tests (useful when no emulator is connected).

.PARAMETER SkipDistribute
    Build the APK but do not distribute. The APK will be at
    build/app/outputs/flutter-apk/app-release.apk.

.PARAMETER ReleaseNotes
    Path to release notes file. Defaults to release_notes.txt in project root.
    If the file doesn't exist, a default message is generated.

.PARAMETER EmulatorId
    The emulator/device ID to use for integration tests.
    If not specified, the first connected Android device is used.

.EXAMPLE
    .\tools\qa_pipeline.ps1
    # Full pipeline: tests, integration tests, build, distribute

.EXAMPLE
    .\tools\qa_pipeline.ps1 -SkipIntegration
    # Skip integration tests, run unit tests, build, distribute

.EXAMPLE
    .\tools\qa_pipeline.ps1 -SkipDistribute
    # Run tests and build APK only, no distribution
#>

param(
    [switch]$SkipIntegration,
    [switch]$SkipDistribute,
    [string]$ReleaseNotes = "release_notes.txt",
    [string]$EmulatorId = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

function Write-Step($msg) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

function Write-Ok($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Fail($msg) {
    Write-Host "[FAIL] $msg" -ForegroundColor Red
}

function Invoke-Step($label, $scriptBlock) {
    Write-Step $label
    & $scriptBlock
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "$label failed with exit code $LASTEXITCODE"
        exit 1
    }
    Write-Ok "$label completed"
}

# ---------------------------------------------------------------------------
# Step 1: Unit & Widget Tests
# ---------------------------------------------------------------------------
Invoke-Step "Step 1/4: Unit & Widget Tests" {
    Push-Location $ProjectRoot
    flutter test --no-pub
    Pop-Location
}

# ---------------------------------------------------------------------------
# Step 2: Integration Tests (optional)
# ---------------------------------------------------------------------------
if (-not $SkipIntegration) {
    Write-Step "Step 2/4: Integration Tests"

    # Find a connected Android device if not specified
    if (-not $EmulatorId) {
        $devices = flutter devices --machine 2>$null | ConvertFrom-Json
        $android = $devices | Where-Object { $_.target -like "android*" } | Select-Object -First 1
        if ($android) {
            $EmulatorId = $android.id
            Write-Host "Using Android device: $EmulatorId"
        } else {
            Write-Host "[WARN] No Android emulator connected. Skipping integration tests." -ForegroundColor Yellow
            $SkipIntegration = $true
        }
    }

    if (-not $SkipIntegration) {
        Push-Location $ProjectRoot
        flutter test integration_test/full_game_flow_test.dart -d $EmulatorId
        Pop-Location
        if ($LASTEXITCODE -ne 0) {
            Write-Fail "Integration tests failed"
            exit 1
        }
        Write-Ok "Integration tests completed"
    }
} else {
    Write-Step "Step 2/4: Integration Tests (SKIPPED)"
}

# ---------------------------------------------------------------------------
# Step 3: Build Release APK
# ---------------------------------------------------------------------------
Invoke-Step "Step 3/4: Build Release APK" {
    Push-Location $ProjectRoot
    flutter clean
    flutter build apk --release
    Pop-Location
}

$apkPath = Join-Path $ProjectRoot "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Fail "APK not found at $apkPath"
    exit 1
}
$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
Write-Ok "APK built: $apkPath ($apkSize MB)"

# ---------------------------------------------------------------------------
# Step 4: Distribute via Firebase App Distribution (optional)
# ---------------------------------------------------------------------------
if (-not $SkipDistribute) {
    Write-Step "Step 4/4: Distribute via Firebase App Distribution"

    # Ensure release notes exist
    $notesPath = Join-Path $ProjectRoot $ReleaseNotes
    if (-not (Test-Path $notesPath)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        "QA build - $timestamp" | Out-File -FilePath $notesPath -Encoding UTF8
        Write-Host "Created default release notes at $notesPath"
    }

    Push-Location (Join-Path $ProjectRoot "android")
    bundle exec fastlane android distribute
    Pop-Location

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Distribution failed"
        exit 1
    }
    Write-Ok "APK distributed to Firebase App Distribution"
} else {
    Write-Step "Step 4/4: Distribution (SKIPPED)"
    Write-Host "APK is ready at: $apkPath"
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Step "Pipeline Complete"
Write-Host "  Unit/Widget Tests:  PASSED" -ForegroundColor Green
if (-not $SkipIntegration) {
    Write-Host "  Integration Tests:  PASSED" -ForegroundColor Green
} else {
    Write-Host "  Integration Tests:  SKIPPED" -ForegroundColor Yellow
}
Write-Host "  APK Build:          PASSED ($apkSize MB)" -ForegroundColor Green
if (-not $SkipDistribute) {
    Write-Host "  Distribution:       DONE" -ForegroundColor Green
} else {
    Write-Host "  Distribution:       SKIPPED" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "APK: $apkPath" -ForegroundColor White
