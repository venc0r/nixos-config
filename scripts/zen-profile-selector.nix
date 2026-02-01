{ pkgs }:

pkgs.writeShellScriptBin "zen-profile-selector" ''
  #!/bin/sh
  # Zen Browser Profile Selector
  # Uses rofi to select a Zen Browser profile and launches it with -P flag

  set -euo pipefail

  ROFI="${pkgs.rofi}/bin/rofi"
  NOTIFY_SEND="${pkgs.libnotify}/bin/notify-send"
  GREP="${pkgs.gnugrep}/bin/grep"

  PROFILES_INI="''${HOME}/.config/zen/profiles.ini"

  # Check if profiles.ini exists
  if [[ ! -f "$PROFILES_INI" ]]; then
      $NOTIFY_SEND "Zen Browser" "profiles.ini not found at $PROFILES_INI" --urgency=critical
      exit 1
  fi

  # Extract profile names from profiles.ini
  # Format: Parse [ProfileN] sections and get Name= values
  profile_names=$($GREP "^Name=" "$PROFILES_INI" | cut -d'=' -f2)

  # Check if we found any profiles
  if [[ -z "$profile_names" ]]; then
      $NOTIFY_SEND "Zen Browser" "No profiles found in $PROFILES_INI" --urgency=critical
      exit 1
  fi

  # Use rofi to select a profile
  selected_profile=$(echo "$profile_names" | $ROFI -dmenu -i -p "Zen Browser Profile")

  # Exit if nothing selected (user cancelled)
  if [[ -z "$selected_profile" ]]; then
      exit 0
  fi

  # Launch Zen Browser with the selected profile
  # Use 'zen-beta' from PATH since it's installed via home-manager
  zen-beta -P "$selected_profile" &

  # Optional: notify user
  $NOTIFY_SEND "Zen Browser" "Launching with profile: $selected_profile"
''
