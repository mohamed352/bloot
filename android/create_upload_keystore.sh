#!/usr/bin/env bash
# Creates the Android upload keystore for Bloot release builds.
# Run from the android/ directory:
#   bash create_upload_keystore.sh
# Then copy key.properties.template to key.properties and fill in your passwords.
set -e

KEYSTORE_FILE="app/upload-keystore.jks"
ALIAS="upload"

if [ -f "$KEYSTORE_FILE" ]; then
  echo "Keystore already exists at $KEYSTORE_FILE. Aborting to avoid overwriting."
  exit 1
fi

if ! command -v keytool &> /dev/null; then
  echo "keytool not found. Ensure the Android SDK or JDK is installed and on PATH."
  exit 1
fi

keytool -genkey -v \
  -keystore "$KEYSTORE_FILE" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias "$ALIAS" \
  -dname "CN=Bloot, OU=Mobile, O=Bloot, L=Riyadh, C=SA"

echo ""
echo "Keystore created: $KEYSTORE_FILE"
echo "Next steps:"
echo "  1. Copy key.properties.template to key.properties"
echo "  2. Fill in storePassword and keyPassword with the passwords you just set"
echo "  3. Keep upload-keystore.jks private and back it up securely"
