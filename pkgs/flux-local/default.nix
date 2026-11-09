# flux-local renders a Flux GitOps repo offline (kustomize + helm) for diffing and
# validation. Not in nixpkgs, and upstream sunset it at 8.4.0 in favour of
# home-operations/flate, so this derivation is a frozen build of the last release.
{
  lib,
  python3Packages,
  fetchPypi,
  makeBinaryWrapper,
  kustomize,
  kubernetes-helm,
  fluxcd,
  git,
}:

python3Packages.buildPythonApplication rec {
  pname = "flux-local";
  version = "8.4.0";
  pyproject = true;

  src = fetchPypi {
    pname = "flux_local";
    inherit version;
    hash = "sha256-aOSoVF4Gaib/oLbv+boGNuGdANc4+b/GVgaimjpviAs=";
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    gitpython
    pyyaml
    aiofiles
    mashumaro
    nest-asyncio
    oras
    pytest
    pytest-asyncio
    python-slugify
  ];

  nativeBuildInputs = [ makeBinaryWrapper ];

  # Shells out by bare name, see flux_local/kustomize.py and helm.py.
  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        kustomize
        kubernetes-helm
        fluxcd
        git
      ]
    }"
  ];

  # Tests need network access for helm repos and OCI registries.
  doCheck = false;

  pythonImportsCheck = [ "flux_local" ];

  meta = {
    description = "Offline renderer and validator for Flux GitOps repositories";
    homepage = "https://github.com/allenporter/flux-local";
    license = lib.licenses.asl20;
    mainProgram = "flux-local";
  };
}
