{ lib, config, pkgs, ... }:

{
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "jma";
    home.homeDirectory = "/home/jma";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
        meslo-lgs-nf
        # # Adds the 'hello' command to your environment. It prints a friendly
        # # "Hello, world!" when run.
        # pkgs.hello

        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #   echo "Hello, ${config.home.username}!"
        # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
        # # Building this configuration will create a copy of 'dotfiles/screenrc' in
        # # the Nix store. Activating the configuration will then make '~/.screenrc' a
        # # symlink to the Nix store copy.
        # ".screenrc".source = dotfiles/screenrc;

        ".p10k.zsh".source = dotfiles/.p10k.zsh;
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/jma/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
        EDITOR = "nvim";
    };

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
            enable = true;
            plugins = [
                "podman" "fzf" "git" "git-auto-fetch" "helm"
                "history-substring-search" "kubectl" "ssh-agent"
                "sudo" "terraform" "vi-mode" "history"
            ];
            custom = "$HOME/.oh-my-zsh/custom/";
        };
        historySubstringSearch.enable = true;
        prezto.ssh.identities = [ "id_rsa" "id_rsa_venc" ];
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
            lib.mkMerge [ zshConfigEarlyInit zshConfig ];
    };

    programs.git = {
        enable = true;
        settings.user = {
            Email = "venc0r@live.com";
            Name = "Jörg Markert";
        };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

}
