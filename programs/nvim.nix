{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
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
      go # Go toolchain (gopls, delve, etc.)
      python3 # Python toolchain (pyright, debugpy, etc.)
      python3Packages.pip # Pip for installing Python tools
    ];
  };

  # Symlink the nvim configuration directory
  # This makes the config read-only in ~/.config/nvim
  # Updates to lazy-lock.json will fail unless the path is changed in lazy setup
  # or the file is updated in the git repo.
  xdg.configFile."nvim".source = ../dotfiles/nvim;
}
