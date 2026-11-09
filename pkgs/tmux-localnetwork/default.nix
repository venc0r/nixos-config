# tmux with an Info.plist embedded in its Mach-O binary, so macOS can identify the
# server as something other than "unknown binary" for Local Network privacy.
#
# Without this the grant is attributed to whichever terminal spawned the server, and
# dies with it - see "Local Network access" in agent.md. The embedded plist only
# supplies the identity; hosts/darwin/home.nix signs the binary with a stable
# certificate and puts the result in ~/.local/bin.
{
  lib,
  tmux,
  writeText,
  bundleIdentifier ? "org.venc0r.tmux",
}:

let
  infoPlist = writeText "tmux-info.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleIdentifier</key>
      <string>${bundleIdentifier}</string>
      <key>CFBundleName</key>
      <string>tmux</string>
      <key>CFBundleVersion</key>
      <string>${tmux.version}</string>
      <key>NSLocalNetworkUsageDescription</key>
      <string>Programs running in tmux panes reach hosts on the local network.</string>
    </dict>
    </plist>
  '';
in
tmux.overrideAttrs (old: {
  pname = "tmux-localnetwork";

  # NIX_LDFLAGS reaches ld directly, so this is ld syntax rather than -Wl,.
  env = (old.env or { }) // {
    NIX_LDFLAGS = lib.concatStringsSep " " [
      (old.env.NIX_LDFLAGS or "")
      "-sectcreate __TEXT __info_plist ${infoPlist}"
    ];
  };

  passthru = (old.passthru or { }) // { inherit bundleIdentifier; };
})
