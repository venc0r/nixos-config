{ pkgs }:

pkgs.writeShellScriptBin "tmux-sessionizer" ''
  #!/usr/bin/env bash
  # Tmux session manager for git projects
  # Usage: tmux-sessionizer [path]
  # If no path provided, uses fzf to select from ~/Documents/git/

  FIND="${pkgs.findutils}/bin/find"
  FZF="${pkgs.fzf}/bin/fzf"
  BASENAME="${pkgs.coreutils}/bin/basename"
  TR="${pkgs.coreutils}/bin/tr"
  PGREP="${pkgs.procps}/bin/pgrep"
  TMUX="${pkgs.tmux}/bin/tmux"

  if [[ $# -eq 1 ]]; then
      selected=$1
  else
      selected=$($FIND ~/Documents/git/ -mindepth 2 -maxdepth 3 -type d,l | $FZF)
  fi

  if [[ -z $selected ]]; then
      exit 0
  fi

  selected_name=$($BASENAME "$selected" | $TR . _)
  tmux_running=$($PGREP tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      $TMUX new-session -s $selected_name -c $selected
      exit 0
  fi

  if ! $TMUX has-session -t=$selected_name 2> /dev/null; then
      $TMUX new-session -ds $selected_name -c $selected
  fi

  $TMUX switch-client -t $selected_name
''
