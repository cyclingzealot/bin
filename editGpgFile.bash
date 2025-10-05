#!/usr/bin/env bash
set -euo pipefail

file="${1:?Usage: $0 <encrypted-file>}"

# Backup
cp -a "$file" "$file.bak"

# Decrypt to temp file
temp=$(mktemp)
chmod 600 "$temp"
trap "rm -f '$temp'" EXIT

gpg -d "$file" > "$temp"

# Edit
"${EDITOR:-vi}" "$temp"

# Re-encrypt
gpg -c -o "$file" "$temp"

echo "✓ Updated $file"
