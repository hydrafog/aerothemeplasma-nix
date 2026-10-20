{
  stdenvNoCC,
  aerothemeplasma-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-keyboardlayout";
  version = "2025-01-24";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.keyboardlayout $out/share/plasma/plasmoids
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/plasmoids/io.gitgud.wackyideas.keyboardlayout" ];
  };
}