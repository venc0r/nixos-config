# skhd hotkey daemon — macOS only.
# Mimics the i3/aerospace workspace bindings: cmd+N jumps straight to the app
# that lived on workspace N. macOS switches to the app's fullscreen space.
{ pkgs, ... }:

let
  zenFocusProfile = pkgs.writeShellScript "zen-focus-profile" ''
    profile="$1"
    for pid in $(pgrep -f 'MacOS/zen( |$)'); do
      if pgrep -f "parentPid $pid" | head -1 | xargs -I{} ps -o command= -p {} | grep -q "Profiles/$profile "; then
        /usr/bin/osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $pid) to true" \
          || open -a "Zen Browser (Beta)"
        exit 0
      fi
    done
    open -na "Zen Browser (Beta)" --args --profile "$HOME/Library/Application Support/zen/Profiles/$profile"
  '';

  # A Citrix Viewer left over from a closed session stays alive as a windowless
  # accessory process. Both `open -b` and System Events resolve the bundle id to that
  # stale instance, so the hotkey would steal focus and show nothing. Activate by pid
  # via NSRunningApplication, which bypasses the bundle lookup: the Viewer owning a
  # session is the one with a regular activation policy. Fall back to LaunchServices
  # only when none is running.
  citrixFocusViewer = pkgs.writeShellScript "citrix-focus-viewer" ''
    raised=$(/usr/bin/osascript -l JavaScript -e '
      ObjC.import("AppKit");
      const apps = $.NSRunningApplication.runningApplicationsWithBundleIdentifier("com.citrix.receiver.icaviewer.mac");
      let raised = "no";
      for (let i = 0; i < apps.count && raised === "no"; i++) {
        const app = apps.objectAtIndex(i);
        if (app.activationPolicy === $.NSApplicationActivationPolicyRegular) {
          app.activateWithOptions($.NSApplicationActivateAllWindows);
          raised = "yes";
        }
      }
      raised;')
    [ "$raised" = "yes" ] || open -b com.citrix.receiver.icaviewer.mac
  '';
in
{
  services.skhd = {
    enable = true;
    skhdConfig = ''
      .blacklist [
          "utm"
      ]

      # Workspace-style app jumps (i3: workspace 1-9)
      cmd - 1 : open -a "Microsoft Outlook"
      cmd - 2 : ${zenFocusProfile} default-release
      cmd - 3 : open -a "Alacritty"
      # Citrix Viewer.app sits in a versioned framework path that moves on update, so the
      # fallback goes by bundle id. Stale-instance handling lives in citrixFocusViewer.
      cmd - 4 : ${citrixFocusViewer}
      cmd - 5 : open -a "Supersonic"
      cmd - 6 : open -a "Microsoft Teams"
      cmd - 8 : ${zenFocusProfile} private
      cmd - 9 : ${zenFocusProfile} clockodo

      # Launch new terminal window (i3: cmd+enter)
      cmd - return : open -na "Alacritty"
    '';
  };
}
