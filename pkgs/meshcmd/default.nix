# meshcmd is not packaged in nixpkgs and upstream ships no standalone release: a MeshCentral
# server builds it on demand from the pieces in its agents/ directory. This derivation does the
# same merge offline, so the version tracks whatever nixpkgs' meshcentral provides.
{
  lib,
  stdenvNoCC,
  meshcentral,
  nodejs,
}:

let
  agentBinaryByPlatform = {
    aarch64-darwin = "meshagent_osx-arm-64";
    x86_64-darwin = "meshagent_osx-x86-64";
    x86_64-linux = "meshagent_x86-64";
    aarch64-linux = "meshagent_aarch64";
  };
in
stdenvNoCC.mkDerivation {
  pname = "meshcmd";
  inherit (meshcentral) version;

  dontUnpack = true;

  # The merged JavaScript payload sits past the end of the macOS code signature, which keeps
  # upstream's signature valid. Any re-sign or strip during fixup would append bytes after the
  # trailing GUID and meshcmd would no longer find its own payload.
  dontFixup = true;

  nativeBuildInputs = [ nodejs ];

  buildPhase = ''
    runHook preBuild
    node ${./merge.js} \
      "${meshcentral}/lib/node_modules/meshcentral/agents" \
      "${
        agentBinaryByPlatform.${stdenvNoCC.hostPlatform.system}
          or (throw "meshcmd: no meshagent binary known for ${stdenvNoCC.hostPlatform.system}")
      }" \
      "${meshcentral.version}" \
      meshcmd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 meshcmd $out/bin/meshcmd
    runHook postInstall
  '';

  meta = {
    description = "MeshCentral command line tool";
    homepage = "https://github.com/Ylianst/MeshCentral";
    license = lib.licenses.asl20;
    platforms = lib.attrNames agentBinaryByPlatform;
    mainProgram = "meshcmd";
  };
}
