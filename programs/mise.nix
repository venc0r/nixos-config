# mise dev tool version manager, for all platforms.
# Imported from hosts/home-common.nix; the zsh hook lands in programs/zsh-v2.nix's shell init.
{ ... }:

{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
}
