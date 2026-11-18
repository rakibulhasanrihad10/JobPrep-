#!/usr/bin/env bash
# Generates a standard PKCS12 release keystore for JobPrep Android signing.
# DO NOT commit the generated keystore or passwords to git!
set -euo pipefail

KEYSTORE_FILE="${1:-android/app/upload-keystore.jks}"
ALIAS="${2:-jobprep-release-key}"

if [ -f "$KEYSTORE_FILE" ]; then
  echo "Keystore already exists at: $KEYSTORE_FILE"
  exit 0
fi

mkdir -p "$(dirname "$KEYSTORE_FILE")"

echo "Generating release keystore at $KEYSTORE_FILE with alias '$ALIAS'..."
keytool -genkeypair -v \
  -keystore "$KEYSTORE_FILE" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype PKCS12

echo "✅ Keystore generated successfully at $KEYSTORE_FILE."
echo "Extract SHA-1 fingerprint for Google OAuth via:"
echo "  keytool -list -v -keystore $KEYSTORE_FILE -alias $ALIAS"
