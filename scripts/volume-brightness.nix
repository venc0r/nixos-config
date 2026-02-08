{ pkgs }:

pkgs.writeShellScriptBin "volume-brightness" ''
  #!/bin/sh
  # Original source: https://gitlab.com/Nmoleo/i3-volume-brightness-indicator

  bar_color="#7f7fff"
  volume_step=1
  brightness_step=2.5
  max_volume=100

  # Dependencies
  PACTL="${pkgs.pulseaudio}/bin/pactl"
  GREP="${pkgs.gnugrep}/bin/grep"
  HEAD="${pkgs.coreutils}/bin/head"
  XBACKLIGHT="${pkgs.xorg.xbacklight}/bin/xbacklight"
  DUNSTIFY="${pkgs.dunst}/bin/dunstify"

  function get_volume {
      $PACTL get-sink-volume @DEFAULT_SINK@ | $GREP -Po '[0-9]{1,3}(?=%)' | $HEAD -1
  }

  function get_mute {
      $PACTL get-sink-mute @DEFAULT_SINK@ | $GREP -Po '(?<=Mute: )(yes|no)'
  }

  function get_brightness {
      $XBACKLIGHT | $GREP -Po '[0-9]{1,3}' | $HEAD -n 1
  }

  function get_volume_icon {
      volume=$(get_volume)
      mute=$(get_mute)
      if [ "$volume" -eq 0 ] || [ "$mute" == "yes" ] ; then
          volume_icon=""
      elif [ "$volume" -lt 50 ]; then
          volume_icon=""
      else
          volume_icon=""
      fi
  }

  function get_brightness_icon {
      brightness_icon=""
  }

  function show_volume_notif {
      volume=$(get_mute)
      get_volume_icon
      $DUNSTIFY -i audio-volume-muted-blocking -t 1000 -r 2593 -u normal "$volume_icon $volume%" -h int:value:$volume -h string:hlcolor:$bar_color
  }

  function show_brightness_notif {
      brightness=$(get_brightness)
      get_brightness_icon
      $DUNSTIFY -t 1000 -r 2593 -u normal "$brightness_icon $brightness%" -h int:value:$brightness -h string:hlcolor:$bar_color
  }

  case $1 in
      volume_up)
      $PACTL set-sink-mute @DEFAULT_SINK@ 0
      volume=$(get_volume)
      if [ $(( "$volume" + "$volume_step" )) -gt $max_volume ]; then
          $PACTL set-sink-volume @DEFAULT_SINK@ $max_volume%
      else
          $PACTL set-sink-volume @DEFAULT_SINK@ +$volume_step%
      fi
      show_volume_notif
      ;;

      volume_down)
      $PACTL set-sink-volume @DEFAULT_SINK@ -$volume_step%
      show_volume_notif
      ;;

      volume_mute)
      $PACTL set-sink-mute @DEFAULT_SINK@ toggle
      show_volume_notif
      ;;

      brightness_up)
      $XBACKLIGHT -inc $brightness_step -time 0 
      show_brightness_notif
      ;;

      brightness_down)
      $XBACKLIGHT -dec $brightness_step -time 0
      show_brightness_notif
      ;;
  esac
''
