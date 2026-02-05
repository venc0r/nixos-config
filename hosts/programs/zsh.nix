{ lib, config, pkgs, ... }:
let

in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "podman"
        "fzf"
        "git"
        "git-auto-fetch"
        "helm"
        "history-substring-search"
        "kubectl"
        "ssh-agent"
        "sudo"
        "terraform"
        "vi-mode"
        "history"
      ];
      custom = "$HOME/.oh-my-zsh/custom/";
    };
    historySubstringSearch.enable = true;
    prezto.ssh.identities = [
      "id_rsa"
      "id_rsa_venc"
    ];
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent =
      let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source $HOME/.p10k.zsh
          if [[ -r "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-''$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi '';
        zshConfig = lib.mkOrder 1000 "# create my custom configs";
      in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
      ];
  };
}
