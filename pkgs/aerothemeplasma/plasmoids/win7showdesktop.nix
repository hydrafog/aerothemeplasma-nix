{
  stdenvNoCC,
  aerothemeplasma-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-win7showdesktop";
  version = "2026-02-21";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.win7showdesktop $out/share/plasma/plasmoids
    runHook postInstall
  '';

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/plasmoids/io.gitgud.wackyideas.win7showdesktop" ];
  };
}