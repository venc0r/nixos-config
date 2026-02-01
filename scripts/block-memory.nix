{ pkgs }:

pkgs.writeShellScriptBin "block-memory" ''
  #!/bin/sh
  FREE="${pkgs.procps}/bin/free"
  AWK="${pkgs.gawk}/bin/awk"
  # Print used percentage
  $FREE -m | $AWK '/^Mem:/ {printf "%.1f%%\n", $3/$2 * 100}'
''
