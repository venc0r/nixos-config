{ pkgs, ... }:

{
  # Host-specific packages for cubi (Intel box / production machine)
  home.packages = with pkgs; [
    # Communication & collaboration tools
    teams-for-linux # Microsoft Teams client
    zoom-us # Zoom video conferencing
  ];
}
