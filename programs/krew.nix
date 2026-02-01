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
      "cnpg"
      "ctx"
      "ns"
      "stern"
      "oidc-login"
    ];
  };
}
