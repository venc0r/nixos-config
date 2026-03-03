{ config, pkgs, inputs, lib, ... }:
{
  imports = [ inputs.mdatp.nixosModules.mdatp ];

  nixpkgs.overlays = [
    (final: prev: {
      mdatp = prev.mdatp.overrideAttrs (oldAttrs: {
        src = pkgs.fetchurl {
          inherit (oldAttrs.src) url outputHash outputHashAlgo;
          curlOptsList = [ "--cacert" "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      });
    })
  ];

  services.mdatp = {
    enable = true;
  };
}
