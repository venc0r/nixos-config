{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.krewfile.homeManagerModules.krewfile ];

  programs.krewfile = {
    enable = true;
    indexes = { };
    plugins = [
      "ctx"
      "ns"
      "stern"
      "oidc-login"
    ];
  };
}
