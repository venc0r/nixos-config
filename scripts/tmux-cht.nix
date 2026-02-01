{ pkgs }:

pkgs.writeShellScriptBin "tmux-cht" ''
  #!/usr/bin/env bash
  # Tmux cheat sheet lookup using cht.sh
  # Dynamically discovers available commands from $PATH
  # Uses ~/.tmux-cht-languages for programming languages

  FZF="${pkgs.fzf}/bin/fzf"
  CAT="${pkgs.coreutils}/bin/cat"
  CURL="${pkgs.curl}/bin/curl"
  LESS="${pkgs.less}/bin/less"
  TMUX_BIN="${pkgs.tmux}/bin/tmux"
  BASENAME="${pkgs.coreutils}/bin/basename"
  SORT="${pkgs.coreutils}/bin/sort"
  UNIQ="${pkgs.coreutils}/bin/uniq"
  TR="${pkgs.coreutils}/bin/tr"
  GREP="${pkgs.gnugrep}/bin/grep"
  FIND="${pkgs.findutils}/bin/find"

  # Only run inside tmux
  if [[ -z $TMUX ]]; then
      echo "This script must be run inside tmux."
      exit 1
  fi

  # Get programming languages from config file
  languages=""
  if [[ -f ~/.tmux-cht-languages ]]; then
      languages=$($CAT ~/.tmux-cht-languages)
  fi

  # Generate list of available commands from $PATH
  # Using find to list executable files in PATH directories (replaces compgen which is missing in minimal bash)
  commands=$(
      IFS=: read -ra DIRS <<< "$PATH"
      for dir in "''${DIRS[@]}"; do
          [[ -d "$dir" ]] || continue
          $FIND "$dir" -maxdepth 1 -executable \( -type f -o -type l \) -printf "%f\n" 2>/dev/null
      done | $SORT -u
  )

  # Combine languages and commands, then use fzf to select
  selected=$(echo "$languages"$'\n'"$commands" | $FZF --header "Select language or command")

  if [[ -z $selected ]]; then
      exit 0
  fi

  read -p "Enter Query: " query

  # Construct the query URL and open in new tmux window
  if echo "$languages" | $GREP -qs "$selected"; then
      query=$(echo "$query" | $TR ' ' '+')
      $TMUX_BIN neww bash -c "echo \"curl cht.sh/$selected/$query/\" & $CURL cht.sh/$selected/$query | $LESS"
  else
      $TMUX_BIN neww bash -c "echo \"curl cht.sh/$selected~$query\" & $CURL cht.sh/$selected~$query | $LESS"
  fi
''
