#!/bin/zsh
set -e

VM_ID="613DA2AF-645A-4FAD-B3C3-A62BDADAD8FE"
SERIAL_LOG=/tmp/nixos-dev-serial.log
KEYCHAIN_SERVICE=nixos-vm-luks
UNLOCK_TIMEOUT_SECONDS=120

vm_status() {
  osascript -e "tell application \"UTM\" to get status of virtual machine id \"$VM_ID\""
}

if [[ "$(vm_status)" == "started" ]]; then
  echo "nixos-dev already running"
  exit 0
fi

osascript -e "tell application \"UTM\" to start virtual machine id \"$VM_ID\""
sleep 3

serial_pty=$(osascript -e "tell application \"UTM\" to get address of first serial port of virtual machine id \"$VM_ID\"")
/bin/stty -f "$serial_pty" raw -echo
: > "$SERIAL_LOG"
( cat "$serial_pty" > "$SERIAL_LOG" 2>&1 ) &
serial_reader_pid=$!

elapsed=0
while (( elapsed < UNLOCK_TIMEOUT_SECONDS )); do
  if grep -qai 'enter passphrase' "$SERIAL_LOG"; then
    security find-generic-password -w -s "$KEYCHAIN_SERVICE" | tr -d '\n' > "$serial_pty"
    printf '\n' > "$serial_pty"
    kill "$serial_reader_pid" 2>/dev/null || true
    echo "nixos-dev: LUKS unlocked from keychain"
    exit 0
  fi
  sleep 2
  (( elapsed += 2 ))
done

kill "$serial_reader_pid" 2>/dev/null || true
echo "nixos-dev: no LUKS prompt within ${UNLOCK_TIMEOUT_SECONDS}s - check UTM window" >&2
exit 1
