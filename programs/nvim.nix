{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
    extraPackages = with pkgs; [
      # Build tools
      gcc
      gnumake
      unzip
      wget
      curl
      gzip

      # Search and utilities
      ripgrep
      fd
      xclip

      # Treesitter
      tree-sitter # Includes both library and CLI tool

      # Lua
      luajitPackages.luarocks
      lua5_1 # Required by luarocks for some plugins

      # Language runtimes for Mason tools
      go
    ];
  };

  xdg.configFile."nvim".source = ../dotfiles/nvim;
}
