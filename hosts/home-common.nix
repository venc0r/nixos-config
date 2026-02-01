# Shared home-manager configuration for all platforms (Linux + macOS).
# Platform-specific content lives in hosts/home.nix (Linux) and
# hosts/darwin/home.nix (macOS).
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = { };
    extraConfig = builtins.readFile "${inputs.nixos-config-private}/ssh_config";
  };


  home.packages =
    with pkgs;
    [
      nerd-fonts.meslo-lg

      # Password manager
      rbw

      # Development tools
      checkov
      j2cli
      cargo
      argocd
      hcloud
      k0sctl
      talosctl
      opentofu
      terraform
      terraform-docs
      vault
      kubernetes-helm
      kubectl
      kubelogin
      kubeconform
      kyverno
      velero
      go
      gopls
      s3cmd
      kubelogin-oidc
      tektoncd-cli
      stern
      gh
      glab
      forgejo-cli
      ansible
      (azure-cli.withExtensions [ azure-cli.extensions.redisenterprise ])
      restic
      difftastic
      mtr
      shellcheck
      bats
      goss
      yamllint
      lefthook
      claude-code

      # System utilities
      fd
      ripgrep
      gnused
      gnugrep
      coreutils
      gawk
      findutils
      gnutar
      gettext
      skopeo
      crane
      hubble
      cilium-cli
      cosign
      trivy
      renovate
      xz
      zstd
      watch
      wireguard-tools
      duf
      eza
      rclone
      rsync
      socat
      gnupg
      jq
      yq-go
      dyff

      # Media
      mpv
      supersonic
      imagemagick

      # File management
      ranger

      # Markdown viewer
      inlyne

      # Kubernetes schema generation
      (import ./scripts.nix { inherit pkgs; }).kube-schema-gen
      (import ./scripts.nix { inherit pkgs; }).tetra

      # Python + Node (globally available for Mason/tooling)
      (python3.withPackages (ps: with ps; [ pip setuptools wheel pynvim ]))
      nodejs

      openstackclient
      python3Packages.python-neutronclient
      qemu-utils
      podman
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      # Linux-specific pinentry for rbw
      pinentry-gnome3
      gcr
    ]
    ++ lib.optionals (pkgs.stdenv.isLinux && !pkgs.stdenv.hostPlatform.isAarch64) [
      glances
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      pinentry-curses
      mas
      ice-bar
      zoom-us
    ];

  home.file = {
    ".p10k.zsh".source = ../dotfiles/.p10k.zsh;
    ".tmux-cht-languages".source = ../dotfiles/.tmux-cht-languages;

    # Stable agent-socket paths so ssh_config is cross-platform.
    ".1password-agent.sock".source = config.lib.file.mkOutOfStoreSymlink (
      if pkgs.stdenv.isDarwin then
        "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      else
        "${config.home.homeDirectory}/.1password/agent.sock"
    );
    ".bitwarden-agent.sock".source = config.lib.file.mkOutOfStoreSymlink (
      if pkgs.stdenv.isDarwin then
        "${config.home.homeDirectory}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
      else
        "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock"
    );
  } // (if pkgs.stdenv.isDarwin then {
    "Library/Fonts/MesloLG" = {
      source = "${pkgs.nerd-fonts.meslo-lg}/share/fonts/truetype/NerdFonts/MesloLG";
      recursive = true;
    };
  } else {});

  # Alacritty colour themes (shared, referenced by programs/alacritty.nix)
  xdg.configFile."alacritty/gruvbox-dark.toml".text = ''
    # Colors (Gruvbox dark)
    [colors.cursor]
    cursor = '#FF9800'

    # Default colors
    [colors.primary]
    background = '#282828'
    foreground = "#839496"

    # Normal colors
    [colors.normal]
    black   = '#282828'
    red     = '#cc241d'
    green   = '#98971a'
    yellow  = '#d79921'
    blue    = '#458588'
    magenta = '#b16286'
    cyan    = '#689d6a'
    white   = '#a89984'

    # Bright colors
    [colors.bright]
    black   = '#928374'
    red     = '#fb4934'
    green   = '#b8bb26'
    yellow  = '#fabd2f'
    blue    = '#83a598'
    magenta = '#d3869b'
    cyan    = '#8ec07c'
    white   = '#ebdbb2'
  '';

  xdg.configFile."alacritty/gruvbox-light.toml".text = ''
    # Colors (Gruvbox light)

    # Default colors
    [colors.primary]
    # hard contrast background = = '#f9f5d7'
    background = '#fbf1c7'
    # soft contrast background = = '#f2e5bc'
    foreground = '#3c3836'

    # Normal colors
    [colors.normal]
    black   = '#fbf1c7'
    red     = '#cc241d'
    green   = '#98971a'
    yellow  = '#d79921'
    blue    = '#458588'
    magenta = '#b16286'
    cyan    = '#689d6a'
    white   = '#7c6f64'

    # Bright colors
    [colors.bright]
    black   = '#928374'
    red     = '#9d0006'
    green   = '#79740e'
    yellow  = '#b57614'
    blue    = '#076678'
    magenta = '#8f3f71'
    cyan    = '#427b58'
    white   = '#3c3836'
  '';

  xdg.configFile."yamllint/config".text = ''
    extends: default
    rules:
      key-ordering: disable
      document-start: disable
      line-length:
        max: 120
        level: warning
  '';

  # rbw (Bitwarden CLI) — pinentry differs per platform
  xdg.configFile."rbw/config.json".force = true;
  xdg.configFile."rbw/config.json".text = builtins.toJSON {
    email = "joerg.markert+b2onv5cv@posteo.de";
    base_url = "https://vaultwarden.v3nc.org";
    lock_timeout = 14400;
    sync_interval = 3600;
    pinentry = if pkgs.stdenv.isDarwin
      then "${pkgs.pinentry-curses}/bin/pinentry-curses"
      else "${pkgs.pinentry-gnome3}/bin/pinentry-gnome3";
  };

  home.activation.helmUnittest = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    HELM_UNITTEST_DIR="$HOME/Library/helm/plugins/helm-unittest"
    if ! ${pkgs.kubernetes-helm}/bin/helm plugin list 2>/dev/null | grep -q "^unittest"; then
      export PATH="${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
      ${pkgs.kubernetes-helm}/bin/helm plugin install --verify=false https://github.com/helm-unittest/helm-unittest
    elif [ -d "$HELM_UNITTEST_DIR" ] && ! ls "$HELM_UNITTEST_DIR"/untt-* >/dev/null 2>&1; then
      export PATH="${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:$PATH"
      HELM_PLUGIN_DIR="$HELM_UNITTEST_DIR" bash "$HELM_UNITTEST_DIR/install-binary.sh"
    fi
  '';

  imports = [
    ../programs/alacritty.nix
    ../programs/fastfetch.nix
    ../programs/git.nix
    ../programs/krew.nix
    ../programs/nvim.nix
    ../programs/tmux.nix
    ../programs/vim.nix
    ../programs/zsh-v2.nix
  ];

  programs.home-manager.enable = true;
}
