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
  tmuxLocalNetwork = pkgs.callPackage ../../pkgs/tmux-localnetwork { };
  signedTmux = "${config.home.homeDirectory}/.local/bin/tmux";
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

  # marp-cli shells out to a Chromium to render pdf/pptx/png; html export needs none.
  # Brave comes from the homebrew cask, so no second browser has to be built.
  home.sessionVariables.CHROME_PATH = "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser";

  home.packages =
    with pkgs;
    [
      # Custom scripts (cross-platform subset)
      scripts.tmux-cht
      scripts.tmux-cal
      scripts.tmux-sessionizer

      # One-time setup for the identity used by signAppsForLocalNetwork below
      scripts.macos-codesign-cert

      # MeshCentral CLI, built from the meshcentral package (see pkgs/meshcmd)
      (callPackage ../../pkgs/meshcmd { })

      # MikroTik RouterOS GUI (unfree). Auto-linked to ~/Applications/Home Manager Apps/
      winbox
    ];

  launchd.agents.stats = {
    enable = true;
    config = {
      ProgramArguments = [ "/Applications/Stats.app/Contents/MacOS/Stats" ];
      RunAtLoad = true;
      KeepAlive = false;
    };
  };

  # launchd spawns the tmux server, which makes it its own responsible process for
  # macOS Local Network privacy - a terminal-spawned server is only ever attributed to
  # that terminal's pid and loses LAN access the moment it exits. -D keeps the server in
  # the foreground so launchd can supervise it, and turns exit-empty off.
  #
  # KeepAlive matters: without it a dead server is silently replaced by one the next
  # tmux client forks off the terminal, which is exactly the broken arrangement again.
  launchd.agents.tmux-server = {
    enable = true;
    config = {
      ProgramArguments = [
        signedTmux
        "-D"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      # launchd starts with no locale, and panes inherit it. Under LC_CTYPE=C zsh
      # miscounts the width of the prompt's multi-byte glyphs and misplaces the cursor.
      EnvironmentVariables.LANG = "en_US.UTF-8";
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

  # Nix owns the binary and ~/.vscode/extensions, so in-app extension installs and
  # self-updates would be reverted on the next rebuild. Extensions belong here.
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
    };
  };

  # macOS ties its Local Network privacy grant to an app's code-signing identity.
  # Nix ad-hoc-signs every bundle, so that identity is a bare cdhash which changes
  # on each rebuild and takes the grant with it. Zen additionally ships no
  # NSLocalNetworkUsageDescription, so it never even appears in the permission list
  # (zen-browser/desktop#13860). Patch the key in and re-sign with a stable identity
  # after copyApps has restored the pristine bundles from the store.
  # Create the certificate once: `macos-codesign-cert`.
  home.activation.signAppsForLocalNetwork = lib.hm.dag.entryAfter [ "copyApps" ] ''
    signingIdentity="Nix Local Code Signing"

    if ! /usr/bin/security find-certificate -c "$signingIdentity" > /dev/null 2>&1; then
      echo "local network signing: no '$signingIdentity' certificate, run macos-codesign-cert" >&2
    else
      signBundleForLocalNetwork() {
        local bundle="$HOME/Applications/Home Manager Apps/$1"
        local plist="$bundle/Contents/Info.plist"
        [ -d "$bundle" ] || return 0

        local bundleId
        bundleId=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$plist")

        /usr/libexec/PlistBuddy -c \
          "Add :NSLocalNetworkUsageDescription string Reach hosts on the local network." \
          "$plist" > /dev/null 2>&1 || true

        $DRY_RUN_CMD /usr/bin/codesign --force --deep --timestamp=none \
          --identifier "$bundleId" --sign "$signingIdentity" "$bundle"
      }

      # Alacritty carries the grant for everything it starts, tmux included.
      signBundleForLocalNetwork "Zen Browser (Beta).app"
      signBundleForLocalNetwork "Alacritty.app"
    fi
  '';

  # The tmux server outlives the terminal that started it, but macOS records that
  # terminal's pid as the responsible process for every pane and denies Local Network
  # access once it exits. A tmux carrying its own identity (pkgs/tmux-localnetwork) and
  # a stable signature is responsible for itself, so the grant survives.
  #
  # The store binary cannot be signed in place, so the signed copy lives in ~/.local/bin,
  # which already precedes the nix profile in PATH. Copying it replaces the inode and
  # would strand the running server, so it only happens when the store path really changed.
  programs.tmux.package = tmuxLocalNetwork;

  home.activation.signTmuxForLocalNetwork = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    signingIdentity="Nix Local Code Signing"
    storeTmux="${tmuxLocalNetwork}/bin/tmux"
    stamp="${config.home.homeDirectory}/.local/state/tmux-localnetwork/signed-store-path"

    if ! /usr/bin/security find-certificate -c "$signingIdentity" > /dev/null 2>&1; then
      echo "local network signing: no '$signingIdentity' certificate, run macos-codesign-cert" >&2
    elif [ "$(cat "$stamp" 2> /dev/null)" = "$storeTmux" ] \
      && /usr/bin/codesign --verify "${signedTmux}" > /dev/null 2>&1; then
      $VERBOSE_ECHO "tmux already signed for local network access"
    else
      $DRY_RUN_CMD mkdir -p "$(dirname "${signedTmux}")" "$(dirname "$stamp")"
      $DRY_RUN_CMD install -m 755 "$storeTmux" "${signedTmux}"
      $DRY_RUN_CMD /usr/bin/codesign --force --timestamp=none \
        --identifier "${tmuxLocalNetwork.bundleIdentifier}" \
        --sign "$signingIdentity" "${signedTmux}"
      $DRY_RUN_CMD sh -c "echo '$storeTmux' > '$stamp'"
      echo "tmux signed for local network access - run 'tmux kill-server' to pick it up" >&2
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
