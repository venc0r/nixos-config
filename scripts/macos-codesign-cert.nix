{ pkgs }:

# One-time setup for the code-signing identity that hosts/darwin/home.nix re-signs
# nix app bundles with. macOS keys its Local Network privacy grant to an app's
# code-signing identity; nix ad-hoc-signs bundles, so that identity is a bare cdhash
# that changes on every rebuild and the grant dies with it. Signing with a real
# certificate makes the identity `identifier + certificate leaf`, which survives.
#
# Adds a self-signed root to the System keychain, trusted for code signing only.

pkgs.writeShellScriptBin "macos-codesign-cert" ''
  set -euo pipefail

  OPENSSL="${pkgs.openssl}/bin/openssl"
  CERT_NAME="Nix Local Code Signing"
  LOGIN_KEYCHAIN="$HOME/Library/Keychains/login.keychain-db"

  if /usr/bin/security find-certificate -c "$CERT_NAME" >/dev/null 2>&1; then
    echo "Certificate '$CERT_NAME' already exists — nothing to do."
    exit 0
  fi

  cat <<EOF
This adds a self-signed root certificate to the System keychain, trusted for
code signing only (-p codeSign). It lets you sign local app bundles so macOS
gives them a stable identity across nix rebuilds. It grants no network, disk,
or system access by itself, and nothing else is signed with it.

Requires an admin password for the System keychain.
EOF
  read -r -p "Continue? [y/N] " reply
  [ "$reply" = "y" ] || [ "$reply" = "Y" ] || { echo "Aborted."; exit 1; }

  workdir=$(mktemp -d)
  trap 'rm -rf "$workdir"' EXIT

  "$OPENSSL" req -x509 -newkey rsa:2048 -nodes -days 7300 \
    -keyout "$workdir/key.pem" -out "$workdir/cert.pem" \
    -subj "/CN=$CERT_NAME" \
    -addext "basicConstraints=critical,CA:false" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning"

  # security(1) rejects an empty PKCS#12 password and only understands a SHA-1
  # MAC, while OpenSSL 3 defaults to SHA-256. The transfer password is discarded
  # with the workdir — the imported key is protected by the login keychain.
  transferPassword=$("$OPENSSL" rand -hex 16)

  "$OPENSSL" pkcs12 -export -legacy -macalg sha1 \
    -inkey "$workdir/key.pem" -in "$workdir/cert.pem" \
    -out "$workdir/cert.p12" -passout "pass:$transferPassword"

  /usr/bin/security import "$workdir/cert.p12" \
    -k "$LOGIN_KEYCHAIN" -P "$transferPassword" -T /usr/bin/codesign

  sudo /usr/bin/security add-trusted-cert -d -r trustRoot -p codeSign \
    -k /Library/Keychains/System.keychain "$workdir/cert.pem"

  cat <<EOF

Done. Next steps:

  1. darwin-rebuild switch --flake '.#MacBook-Pro-von-Jorg'
     The first signing pops a keychain dialog — choose "Always Allow".
  2. System Settings > Privacy & Security > Local Network — enable the apps.
  3. Restart Zen. For tmux, its Local Network grant belongs to Alacritty, so a
     running tmux server keeps the old attribution until you restart it yourself.
EOF
''
