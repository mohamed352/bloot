# Creates the Android upload keystore for Bloot release builds.
# Run from the android/ directory in PowerShell:
#   .\create_upload_keystore.ps1
# Then copy key.properties.template to key.properties and fill in your passwords.
$ErrorActionPreference = "Stop"

$KeystoreFile = "app/upload-keystore.jks"
$Alias = "upload"

if (Test-Path $KeystoreFile) {
    Write-Error "Keystore already exists at $KeystoreFile. Aborting to avoid overwriting."
    exit 1
}

$Keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $Keytool) {
    Write-Error "keytool not found. Ensure the Android SDK or JDK is installed and on PATH."
    exit 1
}

& keytool -genkey -v `
    -keystore "$KeystoreFile" `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -alias "$Alias" `
    -dname "CN=Bloot, OU=Mobile, O=Bloot, L=Riyadh, C=SA"

Write-Host ""
Write-Host "Keystore created: $KeystoreFile"
Write-Host "Next steps:"
Write-Host "  1. Copy key.properties.template to key.properties"
Write-Host "  2. Fill in storePassword and keyPassword with the passwords you just set"
Write-Host "  3. Keep upload-keystore.jks private and back it up securely"
