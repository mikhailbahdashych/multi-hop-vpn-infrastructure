#!/usr/bin/env bash
# Generate a self-contained .ovpn client config file.
# Usage: generate-client-config.sh <client-name>
set -euo pipefail

CLIENT_NAME="${1:?Usage: $0 <client-name>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKI_DIR="$PROJECT_ROOT/pki"
TF_DIR="$PROJECT_ROOT/terraform"
OUTPUT_DIR="$PROJECT_ROOT/clients"

# Get entry node IP from Terraform output
ENTRY_IP=$(cd "$TF_DIR" && terraform output -raw entry_node_ip 2>/dev/null)
if [ -z "$ENTRY_IP" ]; then
    echo "Error: Could not determine entry node IP. Run 'make apply' first."
    exit 1
fi

# Verify required files exist
for f in "$PKI_DIR/ca.crt" "$PKI_DIR/issued/${CLIENT_NAME}.crt" "$PKI_DIR/private/${CLIENT_NAME}.key" "$PKI_DIR/ta.key"; do
    if [ ! -f "$f" ]; then
        echo "Error: Missing file: $f"
        echo "Ensure PKI is set up and Ansible has been run (to fetch ta.key)."
        exit 1
    fi
done

mkdir -p "$OUTPUT_DIR"
OVPN_FILE="$OUTPUT_DIR/${CLIENT_NAME}.ovpn"

cat > "$OVPN_FILE" <<EOF
client
dev tun
proto udp
remote ${ENTRY_IP} 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
key-direction 1
verb 3

<ca>
$(cat "$PKI_DIR/ca.crt")
</ca>

<cert>
$(cat "$PKI_DIR/issued/${CLIENT_NAME}.crt")
</cert>

<key>
$(cat "$PKI_DIR/private/${CLIENT_NAME}.key")
</key>

<tls-auth>
$(cat "$PKI_DIR/ta.key")
</tls-auth>
EOF

chmod 600 "$OVPN_FILE"

echo ""
echo "Client config generated: $OVPN_FILE"
echo "Import this file into your OpenVPN client to connect."
