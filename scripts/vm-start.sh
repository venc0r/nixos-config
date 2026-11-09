#!/bin/zsh
set -e

VM_ID="AB16E921-C877-459C-98D0-CDD73531790A"
SERIAL_LOG=/tmp/nixos-dev-serial.log
KEYCHAIN_SERVICE=nixos-vm-luks
UNLOCK_TIMEOUT_SECONDS=120

vm_status() {
  osascript -e "tell application \"UTM\" to get status of virtual machine id \"$VM_ID\""
}

already_running=0
if [[ "$(vm_status)" == "started" ]]; then
  echo "nixos-dev already running - attaching for LUKS unlock"
  already_running=1
else
  osascript -e "tell application \"UTM\" to start virtual machine id \"$VM_ID\""
  sleep 3
fi

serial_pty=$(osascript -e "tell application \"UTM\" to get address of first serial port of virtual machine id \"$VM_ID\"")
/bin/stty -f "$serial_pty" raw -echo
: > "$SERIAL_LOG"
( cat "$serial_pty" > "$SERIAL_LOG" 2>&1 ) &
serial_reader_pid=$!

cleanup() { kill "$serial_reader_pid" 2>/dev/null || true }

# if the prompt was printed before we attached, an empty passphrase attempt
# makes systemd-cryptsetup print it again so the wait loop can see it
if (( already_running )); then
  printf '\n' > "$serial_pty"
fi

elapsed=0
provoked=$already_running
while (( elapsed < UNLOCK_TIMEOUT_SECONDS )); do
  if grep -qai 'emergency mode' "$SERIAL_LOG"; then
    cleanup
    echo "nixos-dev: boot dropped to emergency mode (LUKS tries exhausted) - restart VM" >&2
    exit 1
  fi
  if grep -qai 'enter passphrase' "$SERIAL_LOG"; then
    security find-generic-password -w -s "$KEYCHAIN_SERVICE" | tr -d '\n' > "$serial_pty"
    printf '\n' > "$serial_pty"
    cleanup
    echo "nixos-dev: LUKS unlocked from keychain"
    exit 0
  fi
  if (( elapsed >= 10 && ! provoked )); then
    printf '\n' > "$serial_pty"
    provoked=1
  fi
  sleep 2
  (( elapsed += 2 ))
done

cleanup
echo "nixos-dev: no LUKS prompt within ${UNLOCK_TIMEOUT_SECONDS}s - check UTM window" >&2
exit 1
