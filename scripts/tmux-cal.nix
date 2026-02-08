{ pkgs }:

pkgs.writeShellScriptBin "tmux-cal" ''
  #!/usr/bin/env bash
  # Tmux calendar viewer using fzf year selector

  FZF="${pkgs.fzf}/bin/fzf"
  ECHO="${pkgs.coreutils}/bin/echo"
  TR="${pkgs.coreutils}/bin/tr"
  CAL="${pkgs.util-linux}/bin/cal"
  SLEEP="${pkgs.coreutils}/bin/sleep"
  TMUX="${pkgs.tmux}/bin/tmux"

  yy=$($ECHO {24..37} | $TR ' ' '\n' | $FZF)
  $TMUX neww bash -c "$CAL -wy 20$yy; $SLEEP 300"
''
