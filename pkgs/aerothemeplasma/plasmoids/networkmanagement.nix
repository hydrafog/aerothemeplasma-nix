{
  stdenvNoCC,
  aerothemeplasma-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-networkmanagement";
  version = "2026-02-27";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.networkmanagement $out/share/plasma/plasmoids
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/plasmoids/io.gitgud.wackyideas.networkmanagement" ];
  };
}