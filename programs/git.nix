{ lib, config, pkgs, ... }:
let

in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "jmarkert@cloudpunks.de";
        name = "Jörg Markert";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+rbazDIe/KKcvewOonSS4xJu/a5JMmSrjNIsQ8su9R";
      };
      gpg = {
        format = "ssh";
        "ssh" = {
          program =
            if pkgs.stdenv.isDarwin then
              "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else
              "/run/current-system/sw/bin/op-ssh-sign";
        };
      };
      commit.gpgsign = true;
      init.defaultBranch = "main";
      rerere.enabled = true;
      feature.manyFiles = true;
      core.untrackedCache = true;
      diff.external = "${pkgs.difftastic}/bin/difft";
      pager.difftool = true;
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = ''${pkgs.difftastic}/bin/difft "$LOCAL" "$REMOTE"'';
      alias.dft = "difftool -t difftastic";
    };
  };
}
