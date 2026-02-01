{ pkgs }:

pkgs.buildGoModule rec {
  pname = "tetra";
  version = "1.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "cilium";
    repo = "tetragon";
    rev = "v${version}";
    hash = "sha256-A6a7yjxenB/7sfdfoIaJAxdkw0ouNinZtahNMRAytwA=";
  };

  vendorHash = null;
  proxyVendor = true;

  subPackages = [ "cmd/tetra" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cilium/tetragon/pkg/version.Version=${version}"
  ];

  doCheck = false;

  meta = {
    description = "Tetragon CLI for interacting with the tetragon runtime security engine";
    homepage = "https://github.com/cilium/tetragon";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "tetra";
    platforms = pkgs.lib.platforms.unix;
  };
}
