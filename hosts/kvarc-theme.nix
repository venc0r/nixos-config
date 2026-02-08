{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "kvarc-theme";
  version = "2023-11-20";

  src = pkgs.fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvArc";
    rev = "e67c2815c68e9a8f3c4e35431bca077ec4d1bd44";
    sha256 = "sha256-0000000000000000000000000000000000000000000=";
  };

  installPhase = ''
    mkdir -p $out/share/Kvantum
    cp -r KvArc* $out/share/Kvantum/
  '';

  meta = with pkgs.lib; {
    description = "KvArc theme for Kvantum";
    homepage = "https://github.com/GabePoel/KvArc";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
