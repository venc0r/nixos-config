{ pkgs }:

pkgs.writeShellScriptBin "block-cpu" ''
  #!/bin/sh
  MPSTAT="${pkgs.sysstat}/bin/mpstat"
  AWK="${pkgs.gawk}/bin/awk"

  # Get idle percentage and calculate usage
  IDLE=$($MPSTAT 1 1 | tail -n 1 | $AWK '{print $NF}')
  USAGE=$($AWK -v idle="$IDLE" 'BEGIN {print 100 - idle}')

  # Format to 2 decimal places? mpstat usually gives 2.
  # Just print it.
  echo "$USAGE%"
''
