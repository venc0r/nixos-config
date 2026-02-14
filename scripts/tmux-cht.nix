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
  TMUX="${pkgs.tmux}/bin/tmux"
  BASENAME="${pkgs.coreutils}/bin/basename"
  COMPGEN="${pkgs.bash}/bin/bash"
  SORT="${pkgs.coreutils}/bin/sort"
  UNIQ="${pkgs.coreutils}/bin/uniq"

  TR="${pkgs.coreutils}/bin/tr"
  GREP="${pkgs.gnugrep}/bin/grep"

  # Get programming languages from config file
  languages=""
  if [[ -f ~/.tmux-cht-languages ]]; then
      languages=$($CAT ~/.tmux-cht-languages)
  fi

  # Generate list of available commands from $PATH + bash built-ins
  # Using bash's compgen to list all executables and built-ins
  commands=$($COMPGEN -c "compgen -c | $SORT -u")

  # Combine languages and commands, then use fzf to select
  selected=$(echo "$languages"$'\n'"$commands" | $FZF --header "Select language or command")

  if [[ -z $selected ]]; then
      exit 0
  fi

  read -p "Enter Query: " query

  if echo "$languages" | $GREP -qs "$selected"; then
      query=$(echo "$query" | $TR ' ' '+')
      $TMUX neww bash -c "echo \"curl cht.sh/$selected/$query/\" & $CURL cht.sh/$selected/$query | $LESS"
  else
      $TMUX neww bash -c "echo \"curl cht.sh/$selected~$query\" & $CURL cht.sh/$selected~$query | $LESS"
  fi
''
