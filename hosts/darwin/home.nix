# macOS home-manager configuration.
# Cross-platform content lives in hosts/home-common.nix.
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  scripts = import ../scripts.nix { inherit pkgs; };
  keylayoutBundle = pkgs.fetchFromGitHub {
    owner = "dnnspaul";
    repo  = "macos-us-intl-no-dead-keys";
    rev   = "f62d775d1b37761f24906498425effd24bd94cab";
    sha256 = "1lyqzry3mib77knpzhnp1bzlamksalsxa3gf6frwid1bincyx1gm";
  };
in
{
  home.username = "jmarkert";
  home.homeDirectory = "/Users/jmarkert";
  home.stateVersion = "25.11";

  home.packages =
    with pkgs;
    [
      # Custom scripts (cross-platform subset)
      scripts.tmux-cht
      scripts.tmux-cal
      scripts.tmux-sessionizer

    ];

  launchd.agents.stats = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Stats.app/Contents/MacOS/Stats" ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  launchd.agents.maccy = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Maccy.app/Contents/MacOS/Maccy" ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  home.file."Library/Keyboard Layouts/US Intl PC without dead keys.bundle" = {
    source = "${keylayoutBundle}/US Intl PC without dead keys.bundle";
    recursive = true;
  };

  home.activation.wireguardConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.secrets/wg-private-key" ] && [ -f "$HOME/.secrets/wg-preshared-key" ]; then
      mkdir -p "$HOME/.config/wireguard"
      chmod 700 "$HOME/.config/wireguard"
      PRIVATE_KEY=$(cat "$HOME/.secrets/wg-private-key")
      PRESHARED_KEY=$(cat "$HOME/.secrets/wg-preshared-key")
      cat > "$HOME/.config/wireguard/vpn.conf" << EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.30.1.5/24
DNS = 192.168.188.1

[Peer]
PublicKey = 0cP+tBMurBKJYbEEUJxt8eQwQpkSG45xZ9y+VXgzMFU=
PresharedKey = $PRESHARED_KEY
Endpoint = vpn.v3nc.org:51819
AllowedIPs = 0.0.0.0/0
EOF
      chmod 600 "$HOME/.config/wireguard/vpn.conf"
    else
      echo "WireGuard: secrets not found, skipping config generation"
    fi
  '';

  home.activation.zenProfileApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Applications"
    rm -rf "$HOME/Applications/Zen Profile Manager.app"
    $DRY_RUN_CMD /usr/bin/osacompile -o "$HOME/Applications/Zen Profile Manager.app" \
      -e 'do shell script "\"$HOME/Applications/Home Manager Apps/Zen Browser (Beta).app/Contents/MacOS/zen\" -no-remote --ProfileManager &> /dev/null &"'
  '';

  home.activation.zenProfilesIniPreClean = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    ini="$HOME/Library/Application Support/Zen/profiles.ini"
    rm -f "$ini.hm-backup"
    if [ -f "$ini" ] && [ ! -L "$ini" ]; then
      rm -f "$ini"
    fi
  '';

  home.activation.zenProfilesIniWritable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ini="$HOME/Library/Application Support/Zen/profiles.ini"
    if [ -L "$ini" ]; then
      target=$(readlink "$ini")
      rm "$ini"
      install -m 644 "$target" "$ini"
    fi
  '';

  home.activation.disableInputSourceHotkeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    plist="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
    disable_hotkey() {
      local key=$1 keycode=$2 modifiers=$3
      if /usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys:$key" "$plist" > /dev/null 2>&1; then
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:$key:enabled false" "$plist"
      else
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key dict" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:enabled bool false" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value dict" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value:type string standard" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value:parameters array" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value:parameters:0 integer 65535" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value:parameters:1 integer $keycode" "$plist"
        $DRY_RUN_CMD /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:$key:value:parameters:2 integer $modifiers" "$plist"
      fi
    }
    disable_hotkey 60  49 786432   # Ctrl+Space (input source prev)
    disable_hotkey 61  49 917504   # Ctrl+Option+Space (input source next)
    disable_hotkey 79 123 8650752  # Ctrl+Left (move space left)
    disable_hotkey 81 124 8650752  # Ctrl+Right (move space right)
    $DRY_RUN_CMD /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
  '';

  imports = [
    ../home-common.nix
    ../../programs/zen-browser.nix
  ];
}
