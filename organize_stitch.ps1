# Bloot Stitch Output Organizer
# Copies Stitch-generated HTML files from the flat output folder
# into the organized ui/ directory structure.
#
# Usage: Run this script after generating screens with Stitch.
# It will look for folders in the stitch output directory and
# copy them to the corresponding ui/ subdirectory.
#
# The Stitch design.md file should be at the root level.
# When prompting Stitch, reference this design.md + the relevant
# ai_prompts .md file for each screen.

$StitchSource = ".\stitch_bloot_screens"
$UiTarget = ".\ui"

# Map of Stitch output folder names to our ui/ subdirectories
# Format: "Stitch folder name" = "ui/ subdirectory"
$FolderMap = @{
    "splash_screen" = "01_onboarding"
    "welcome_screen" = "01_onboarding"
    "login" = "02_authentication"
    "otp_verification" = "02_authentication"
    "complete_profile" = "02_authentication"
    "home" = "03_home"
    "discover_streams" = "04_discover_streams"
    "watch_stream" = "05_watch_stream"
    "private_room" = "06_private_room"
    "game_play" = "07_game_play"
    "create_room" = "08_create_room"
    "tournaments" = "09_tournaments"
    "tournament_detail" = "09_tournaments"
    "profile" = "10_profile"
    "edit_profile" = "10_profile"
    "chat" = "11_chat"
    "messages" = "11_chat"
    "room_invitation" = "11_chat"
    "settings" = "12_settings"
    "privacy_policy" = "12_settings"
    "terms" = "12_settings"
    "support" = "12_settings"
    "about" = "12_settings"
    "error_state" = "13_edge_cases"
    "offline_state" = "13_edge_cases"
    "loading_state" = "13_edge_cases"
    "success_state" = "13_edge_cases"
}

Write-Host "=== Bloot Stitch Organizer ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path -LiteralPath $StitchSource)) {
    Write-Host "Stitch source directory not found: $StitchSource" -ForegroundColor Yellow
    Write-Host "Create it and populate with Stitch-generated screen folders." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Expected structure:" -ForegroundColor White
    Write-Host "  $StitchSource\" -ForegroundColor White
    Write-Host "    splash_screen_1\" -ForegroundColor Gray
    Write-Host "      screen.png" -ForegroundColor Gray
    Write-Host "      code.html" -ForegroundColor Gray
    Write-Host "    welcome_screen_1\" -ForegroundColor Gray
    Write-Host "      ..." -ForegroundColor Gray
    exit 0
}

$copiedCount = 0
$skippedCount = 0

foreach ($folder in (Get-ChildItem -LiteralPath $StitchSource -Directory)) {
    $folderName = $folder.Name
    $targetDir = $null

    # Check exact match first
    if ($FolderMap.ContainsKey($folderName)) {
        $targetDir = $FolderMap[$folderName]
    } else {
        # Check partial match (e.g., "splash_screen_1" matches "splash_screen")
        foreach ($key in $FolderMap.Keys) {
            if ($folderName -like "$key*") {
                $targetDir = $FolderMap[$key]
                break
            }
        }
    }

    if ($null -ne $targetDir) {
        $destPath = Join-Path $UiTarget $targetDir
        if (-not (Test-Path -LiteralPath $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }

        # Copy the entire folder
        $destFolderPath = Join-Path $destPath $folderName
        if (Test-Path -LiteralPath $destFolderPath) {
            Write-Host "  [SKIP] $folderName -> already exists in $targetDir" -ForegroundColor Yellow
            $skippedCount++
        } else {
            Copy-Item -LiteralPath $folder.FullName -Destination $destPath -Recurse
            Write-Host "  [COPIED] $folderName -> $targetDir" -ForegroundColor Green
            $copiedCount++
        }
    } else {
        Write-Host "  [UNKNOWN] $folderName - no mapping found" -ForegroundColor Red
        $skippedCount++
    }
}

Write-Host ""
Write-Host "Done! Copied: $copiedCount, Skipped: $skippedCount" -ForegroundColor Cyan