#!/usr/bin/env bash
# Generate and sign a client certificate.
# Usage: generate-client-cert.sh <client-name>
set -euo pipefail

CLIENT_NAME="${1:?Usage: $0 <client-name>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKI_DIR="$PROJECT_ROOT/pki"
EASYRSA_DIR="$PKI_DIR/easyrsa"

if [ ! -f "$PKI_DIR/ca.crt" ]; then
    echo "Error: PKI not initialized. Run 'make pki-init' first."
    exit 1
fi

cd "$EASYRSA_DIR"

echo "==> Generating client certificate for '${CLIENT_NAME}'..."
./easyrsa gen-req "$CLIENT_NAME" nopass

echo "==> Signing client certificate..."
./easyrsa sign-req client "$CLIENT_NAME"

# Copy to expected locations
cp "pki/issued/${CLIENT_NAME}.crt" "$PKI_DIR/issued/${CLIENT_NAME}.crt"
cp "pki/private/${CLIENT_NAME}.key" "$PKI_DIR/private/${CLIENT_NAME}.key"

echo ""
echo "Client certificate generated for '${CLIENT_NAME}'."
echo "  Certificate: $PKI_DIR/issued/${CLIENT_NAME}.crt"
echo "  Private key: $PKI_DIR/private/${CLIENT_NAME}.key"
echo ""
echo "Next: run 'make client-config CLIENT=${CLIENT_NAME}' to generate .ovpn file."
