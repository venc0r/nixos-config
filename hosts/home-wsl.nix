# WSL (Arch) home-manager configuration — CLI environment only.
# Cross-platform content lives in hosts/home-common.nix.
{
  ...
}:

{
  home.username = "jma";
  home.homeDirectory = "/home/jma";
  home.stateVersion = "25.11";

  # keepassxc comes from pacman: nix-built Qt apps break on WSLg (GL mismatch)
  services.ssh-agent.enable = true;

  imports = [
    ./home-common.nix
  ];
}
