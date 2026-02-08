{ pkgs }:

pkgs.writeShellScriptBin "blurlock" ''
  #!/bin/sh
  # Take a screenshot and blur it
  RADIUS=0x''${1:-2}

  IMPORT="${pkgs.imagemagick}/bin/import"
  CONVERT="${pkgs.imagemagick}/bin/convert"
  I3LOCK="${pkgs.i3lock}/bin/i3lock"

  $IMPORT -silent -window root png:- | \
      $CONVERT - -scale 20% -blur $RADIUS -resize 500% /tmp/screenshot.png

  $I3LOCK -i /tmp/screenshot.png
  rm /tmp/screenshot.png
''
