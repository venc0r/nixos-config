{ config, pkgs, inputs, lib, ... }:
{
  imports = [ inputs.mdatp.nixosModules.mdatp ];

  nixpkgs.overlays = [
    (final: prev: {
      mdatp = prev.mdatp.overrideAttrs (oldAttrs: {
        src = pkgs.fetchurl {
          url = oldAttrs.src.url or "https://packages.microsoft.com/debian/12/prod/pool/main/m/mdatp/mdatp_101.25012.0000_amd64.deb";
          hash = oldAttrs.src.outputHash or "sha256-EBnfz4z1t4jwGPKZIKTK1TFacV3UA3BAD1lS+ixs2TE=";
          curlOptsList = [ "--cacert" "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      });
    })
  ];

  services.mdatp = {
    enable = true;
  };
}
