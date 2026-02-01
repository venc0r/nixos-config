{ pkgs }:

pkgs.writeShellScriptBin "block-temperature" ''
  #!/bin/sh
  export LC_ALL=C
  # Debug logging
  exec 2>>/tmp/i3blocks-error.log
  # echo "Temp script running" >> /tmp/i3blocks-debug.log

  SENSORS="${pkgs.lm_sensors}/bin/sensors"
  GREP="${pkgs.gnugrep}/bin/grep"
  AWK="${pkgs.gawk}/bin/awk"
  HEAD="${pkgs.coreutils}/bin/head"
  TR="${pkgs.coreutils}/bin/tr"

  # Try common CPU temp labels
  TEMP=$($SENSORS 2>/dev/null | $GREP -E "^(Package id 0|Tdie|Tctl):" | $AWK '{print $4}' | $HEAD -n 1)

  # Fallback to anything with C if specific label not found
  if [ -z "$TEMP" ]; then
      TEMP=$($SENSORS 2>/dev/null | $GREP "°C" | $HEAD -n 1 | $AWK '{print $2}')
  fi

  if [ -z "$TEMP" ]; then
      echo "N/A"
  else
      echo "$TEMP" | $TR -d '+'
  fi
''
