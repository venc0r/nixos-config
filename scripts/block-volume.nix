{ pkgs }:

pkgs.writeShellScriptBin "block-volume" ''
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
''
