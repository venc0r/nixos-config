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

    # Check if acpi is installed, if not we can't run
    acpi_path = "${pkgs.acpi}/bin/acpi"

    config = dict(os.environ)
    
    try:
        status = subprocess.check_output([acpi_path], universal_newlines=True)
    except FileNotFoundError:
        print("No battery")
        sys.exit(0)
    except subprocess.CalledProcessError:
        # No battery found likely
        status = ""

    if not status:
        color = config.get("color_10", "red")
        fulltext = "<span color='{}'><span font='FontAwesome'>\uf00d \uf240</span></span>".format(color)
        percentleft = 100
    else:
        batteries = status.split("\n")
        state_batteries=[]
        percentleft_batteries=[]
        time = ""
        for battery in batteries:
            if battery!='':
                parts = battery.split(": ")
                if len(parts) > 1:
                    state_batteries.append(parts[1].split(", ")[0])
                    commasplitstatus = parts[1].split(", ")
                    
                    if not time and len(commasplitstatus) > 2:
                        time = commasplitstatus[-1].strip()
                        # check if it matches a time
                        time_match = re.match(r"(\d+):(\d+)", time)
                        if time_match:
                            time = ":".join(time_match.groups())
                            timeleft = " ({})".format(time)
                        else:
                            timeleft = ""
                    else:
                        timeleft = ""

                    if len(commasplitstatus) > 1:
                         p = int(commasplitstatus[1].rstrip("%\n"))
                         if p>0:
                             percentleft_batteries.append(p)

        if not state_batteries:
             print("")
             sys.exit(0)

        state = state_batteries[0]
        
        if percentleft_batteries:
            percentleft = int(sum(percentleft_batteries)/len(percentleft_batteries))
        else:
            percentleft = 0

        # stands for charging
        color = config.get("color_charging", "yellow")
        FA_LIGHTNING = "<span color='{}'><span font='FontAwesome'>\uf0e7</span></span>".format(color)

        # stands for plugged in
        FA_PLUG = "<span font='FontAwesome'>\uf1e6</span>"

        # stands for using battery
        FA_BATTERY = "<span font='FontAwesome'>\uf240</span>"

        # stands for unknown status of battery
        FA_QUESTION = "<span font='FontAwesome'>\uf128</span>"


        if state == "Discharging":
            fulltext = FA_BATTERY + " "
        elif state == "Full":
            fulltext = FA_PLUG + " "
            timeleft = ""
        elif state == "Unknown":
            fulltext = FA_QUESTION + " " + FA_BATTERY + " "
            timeleft = ""
        else:
            fulltext = FA_LIGHTNING + " " + FA_PLUG + " "

        def color(percent):
            if percent < 10:
                return config.get("color_10", "#FFFFFF")
            if percent < 20:
                return config.get("color_20", "#FF3300")
            if percent < 30:
                return config.get("color_30", "#FF6600")
            if percent < 40:
                return config.get("color_40", "#FF9900")
            if percent < 50:
                return config.get("color_50", "#FFCC00")
            if percent < 60:
                return config.get("color_60", "#FFFF00")
            if percent < 70:
                return config.get("color_70", "#FFFF33")
            if percent < 80:
                return config.get("color_80", "#FFFF66")
            return config.get("color_full", "#FFFFFF")

        form =  '<span color="{}">{}%</span>'
        fulltext += form.format(color(percentleft), percentleft)
        #fulltext += timeleft

    print(fulltext)
    print(fulltext)
    if percentleft < 10:
        sys.exit(33)
  '';

in
{
  inherit volume-brightness blurlock block-volume block-battery;
}
