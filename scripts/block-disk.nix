{ pkgs }:

pkgs.writeShellScriptBin "block-disk" ''
  #!/bin/sh
  DF="${pkgs.coreutils}/bin/df"
  AWK="${pkgs.gawk}/bin/awk"
  $DF -h / | $AWK '/\// {print $4}'
''
