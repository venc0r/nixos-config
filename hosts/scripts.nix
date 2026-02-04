{ pkgs }:

let
  volume-brightness = pkgs.writeShellScriptBin "volume-brightness" ''
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
            volume_icon=""
        elif [ "$volume" -lt 50 ]; then
            volume_icon=""
        else
            volume_icon=""
        fi
    }

    function get_brightness_icon {
        brightness_icon=""
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
  '';

  blurlock = pkgs.writeShellScriptBin "blurlock" ''
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
  '';

  block-volume = pkgs.writeShellScriptBin "block-volume" ''
    #!/bin/sh
    # i3blocks volume script

    AMIXER="${pkgs.alsa-utils}/bin/amixer"
    PERL="${pkgs.perl}/bin/perl"
    SED="${pkgs.gnused}/bin/sed"
    GREP="${pkgs.gnugrep}/bin/grep"

    # Auto-detect mixer
    if [[ -z "$MIXER" ]] ; then
        MIXER="default"
        if ${pkgs.pulseaudio}/bin/pulseaudio --check >/dev/null 2>&1 ; then
            MIXER="pulse"
        fi
        [ -n "$(lsmod | $GREP jack)" ] && MIXER="jackplug"
        MIXER="''${2:-$MIXER}"
    fi

    if [[ -z "$SCONTROL" ]] ; then
        SCONTROL="''${BLOCK_INSTANCE:-$($AMIXER -D $MIXER scontrols | $SED -n "s/Simple mixer control '\([^']*\)',0/\1/p" | head -n1)}"
    fi

    if [[ -z "$STEP" ]] ; then
        STEP="''${1:-5%}"
    fi

    NATURAL_MAPPING=''${NATURAL_MAPPING:-0}
    if [[ "$NATURAL_MAPPING" != "0" ]] ; then
        AMIXER_PARAMS="-M"
    fi

    capability() {
      $AMIXER $AMIXER_PARAMS -D $MIXER get "$SCONTROL" |
        $SED -n "s/  Capabilities:.*cvolume.*/Capture/p"
    }

    volume() {
      $AMIXER $AMIXER_PARAMS -D $MIXER get "$SCONTROL" $(capability)
    }

    format() {
      perl_filter='if (/.*\[(\d+%)\] (\[(-?\d+.\d+dB)\] )?\[(on|off)\]/)'
      perl_filter+='{CORE::say $4 eq "off" ? "MUTE" : "'
      perl_filter+=$([[ $STEP = *dB ]] && echo '$3' || echo '$1')
      perl_filter+='"; exit}'
      output=$($PERL -ne "$perl_filter")
      echo "$LABEL$output"
    }

    case $BLOCK_BUTTON in
      3) $AMIXER $AMIXER_PARAMS -q -D $MIXER sset "$SCONTROL" $(capability) toggle ;;
      4) $AMIXER $AMIXER_PARAMS -q -D $MIXER sset "$SCONTROL" $(capability) ''${STEP}+ unmute ;;
      5) $AMIXER $AMIXER_PARAMS -q -D $MIXER sset "$SCONTROL" $(capability) ''${STEP}- unmute ;;
    esac

    volume | format
  '';

  block-battery = pkgs.writeScriptBin "block-battery" ''
    #!${pkgs.python3}/bin/python3
    import os
    import re
    import subprocess
    import sys

    # Check if acpi is installed
    acpi_path = "${pkgs.acpi}/bin/acpi"

    config = dict(os.environ)

    try:
        status = subprocess.check_output([acpi_path], universal_newlines=True)
    except Exception:
        # No battery or acpi failed
        print("")
        sys.exit(0)

    if not status:
        sys.exit(0)

    # Simple parsing logic
    fulltext = ""
    percent = 0

    # Check for Discharging/Charging
    is_discharging = "Discharging" in status
    is_charging = "Charging" in status
    is_full = "Full" in status

    # Extract percentage
    match = re.search(r"(\d+)%", status)
    if match:
        percent = int(match.group(1))

    # Icons
    icon = ""
    if is_discharging:
        icon = "" # Battery
    elif is_charging:
        icon = "" # Lightning
    elif is_full:
        icon = "" # Plug
    else:
        icon = "" # Question

    # Color logic
    color = "#FFFFFF"
    if percent < 10:
        color = "#FF0000"
    elif percent < 20:
        color = "#FF3300"
    elif percent < 30:
        color = "#FF6600"
    elif percent < 50:
        color = "#FFCC00"
    elif percent < 80:
        color = "#FFFF00"

    # Format output
    print(f"<span color='{color}'>{icon} {percent}%</span>")

    if percent < 10 and is_discharging:
        sys.exit(33)
  '';

  block-cpu = pkgs.writeShellScriptBin "block-cpu" ''
    #!/bin/sh
    MPSTAT="${pkgs.sysstat}/bin/mpstat"
    AWK="${pkgs.gawk}/bin/awk"

    # Get idle percentage and calculate usage
    IDLE=$($MPSTAT 1 1 | tail -n 1 | $AWK '{print $NF}')
    USAGE=$($AWK -v idle="$IDLE" 'BEGIN {print 100 - idle}')

    # Format to 2 decimal places? mpstat usually gives 2.
    # Just print it.
    echo "$USAGE%"
  '';

  block-memory = pkgs.writeShellScriptBin "block-memory" ''
    #!/bin/sh
    FREE="${pkgs.procps}/bin/free"
    AWK="${pkgs.gawk}/bin/awk"
    # Print used percentage
    $FREE -m | $AWK '/^Mem:/ {printf "%.1f%%\n", $3/$2 * 100}'
  '';

  block-disk = pkgs.writeShellScriptBin "block-disk" ''
    #!/bin/sh
    DF="${pkgs.coreutils}/bin/df"
    AWK="${pkgs.gawk}/bin/awk"
    $DF -h / | $AWK '/\// {print $4}'
  '';

  block-temperature = pkgs.writeShellScriptBin "block-temperature" ''
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
  '';

  block-bandwidth = pkgs.writeShellScriptBin "block-bandwidth" ''
    #!/bin/sh
    export LC_ALL=C
    exec 2>>/tmp/i3blocks-error.log

    IP="${pkgs.iproute2}/bin/ip"
    SAR="${pkgs.sysstat}/bin/sar"
    AWK="${pkgs.gawk}/bin/awk"
    GREP="${pkgs.gnugrep}/bin/grep"

    # Get default interface
    IF=$($IP route get 1.1.1.1 | $AWK '{print $5}')

    echo "Interface: $IF" >> /tmp/i3blocks-bw-debug.log

    if [ -z "$IF" ]; then
        echo "No Net"
        exit 0
    fi

    # Measure
    # Log raw output
    $SAR -n DEV 1 1 > /tmp/i3blocks-sar.log

    # Process
    cat /tmp/i3blocks-sar.log | $GREP "Average.*$IF" | $AWK '{printf "%.0f/%.0f kB/s", $5, $6}'
  '';

in
{
  inherit
    volume-brightness
    blurlock
    block-volume
    block-battery
    block-cpu
    block-memory
    block-disk
    block-temperature
    block-bandwidth
    ;
}
