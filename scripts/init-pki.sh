#!/usr/bin/env bash
# Initialize local Easy-RSA CA for OpenVPN PKI.
# The CA private key stays on your local machine — never uploaded to cloud.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKI_DIR="$PROJECT_ROOT/pki"
EASYRSA_VERSION="3.1.7"
EASYRSA_DIR="$PKI_DIR/easyrsa"

if [ -d "$PKI_DIR/ca.crt" ] 2>/dev/null || [ -f "$PKI_DIR/ca.crt" ]; then
    echo "PKI already initialized at $PKI_DIR"
    echo "Remove $PKI_DIR to reinitialize."
    exit 1
fi

echo "==> Downloading Easy-RSA v${EASYRSA_VERSION}..."
mkdir -p "$EASYRSA_DIR"
curl -sSL "https://github.com/OpenVPN/easy-rsa/releases/download/v${EASYRSA_VERSION}/EasyRSA-${EASYRSA_VERSION}.tgz" \
    | tar xz --strip-components=1 -C "$EASYRSA_DIR"

cd "$EASYRSA_DIR"

echo "==> Initializing PKI..."
./easyrsa init-pki

echo "==> Building CA (you will be prompted for a passphrase)..."
./easyrsa build-ca

echo "==> Generating DH parameters (this may take a while)..."
./easyrsa gen-dh

# Copy key artifacts to expected locations
cp pki/ca.crt "$PKI_DIR/ca.crt"
cp pki/dh.pem "$PKI_DIR/dh.pem"
mkdir -p "$PKI_DIR/issued" "$PKI_DIR/private"

echo ""
echo "PKI initialized successfully."
echo "  CA certificate: $PKI_DIR/ca.crt"
echo "  DH parameters:  $PKI_DIR/dh.pem"
echo ""
echo "Next: run 'make server-cert' to generate the OpenVPN server certificate."
