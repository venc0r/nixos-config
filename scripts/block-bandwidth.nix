{ pkgs }:

pkgs.writeShellScriptBin "block-bandwidth" ''
  #!/bin/sh
  export LC_ALL=C

  IP="${pkgs.iproute2}/bin/ip"
  SAR="${pkgs.sysstat}/bin/sar"
  AWK="${pkgs.gawk}/bin/awk"
  GREP="${pkgs.gnugrep}/bin/grep"

  # Get default interface
  IF=$($IP route get 1.1.1.1 | $AWK '{print $5}')

  if [ -z "$IF" ]; then
      echo "No Net"
      exit 0
  fi

  # Measure
  $SAR -n DEV 1 1 | $GREP "Average.*$IF" | $AWK '{printf "%.0f/%.0f kB/s\n", $5, $6}'
''
