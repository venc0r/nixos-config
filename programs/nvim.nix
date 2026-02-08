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
      gcc
      gnumake
      unzip
      wget
      curl
      gzip
      ripgrep
      fd
      xclip
      tree-sitter
      luajitPackages.luarocks

      # Language servers for LSP
      lua-language-server
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.yaml-language-server
      gopls
      pyright
    ];
  };

  # Symlink the nvim configuration directory
  # This makes the config read-only in ~/.config/nvim
  # Updates to lazy-lock.json will fail unless the path is changed in lazy setup
  # or the file is updated in the git repo.
  xdg.configFile."nvim".source = ../dotfiles/nvim;
}
