{ pkgs }:

let
  # util-linux (cal) is Linux-only; macOS ships cal in /usr/bin
  cal = if pkgs.stdenv.isLinux then "${pkgs.util-linux}/bin/cal" else "/usr/bin/cal";
in
pkgs.writeShellScriptBin "tmux-cal" ''
  #!/usr/bin/env bash
  # Tmux calendar viewer using fzf year selector

  FZF="${pkgs.fzf}/bin/fzf"
  ECHO="${pkgs.coreutils}/bin/echo"
  TR="${pkgs.coreutils}/bin/tr"
  CAL="${cal}"
  SLEEP="${pkgs.coreutils}/bin/sleep"
  TMUX_BIN="${pkgs.tmux}/bin/tmux"

  # Only run inside tmux
  if [[ -z $TMUX ]]; then
      echo "This script must be run inside tmux."
      exit 1
  fi

  yy=$($ECHO {24..37} | $TR ' ' '\n' | $FZF)
  if [[ -n "$yy" ]]; then
      $TMUX_BIN neww bash -c "$CAL -wy 20$yy; $SLEEP 300"
  fi
''
