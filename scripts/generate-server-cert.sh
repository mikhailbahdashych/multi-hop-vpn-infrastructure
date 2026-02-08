#!/usr/bin/env bash
# Generate and sign an OpenVPN server certificate using the local CA.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKI_DIR="$PROJECT_ROOT/pki"
EASYRSA_DIR="$PKI_DIR/easyrsa"

if [ ! -f "$PKI_DIR/ca.crt" ]; then
    echo "Error: PKI not initialized. Run 'make pki-init' first."
    exit 1
fi

cd "$EASYRSA_DIR"

echo "==> Generating server certificate request..."
./easyrsa gen-req server nopass

echo "==> Signing server certificate..."
./easyrsa sign-req server server

# Copy to expected locations
cp pki/issued/server.crt "$PKI_DIR/issued/server.crt"
cp pki/private/server.key "$PKI_DIR/private/server.key"

echo ""
echo "Server certificate generated successfully."
echo "  Certificate: $PKI_DIR/issued/server.crt"
echo "  Private key: $PKI_DIR/private/server.key"
echo ""
echo "Next: run 'make apply' and 'make configure' to deploy."
