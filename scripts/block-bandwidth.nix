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

  # Measure bandwidth and convert to Mb/s
  # sar outputs rxkB/s and txkB/s (kilobytes per second)
  # Convert to Mb/s (megabits per second): kB/s * 8 / 1000 = Mb/s
  $SAR -n DEV 1 1 | $GREP "Average.*$IF" | $AWK '{
    rx_kbps = $5
    tx_kbps = $6
    rx_mbps = (rx_kbps * 8) / 1000
    tx_mbps = (tx_kbps * 8) / 1000
    printf "↓%.1f ↑%.1f Mb/s\n", rx_mbps, tx_mbps
  }'
''
