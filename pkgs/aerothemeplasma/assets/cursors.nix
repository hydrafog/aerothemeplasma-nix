{
  lib,
  stdenvNoCC,
  aerothemeplasma-icons-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-cursors";
  version = "2026-01-25";
  src = aerothemeplasma-icons-repo;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r aero-drop $out/share/icons
    runHook postInstall
  '';
  dontFixup = true;
  
  passthru.updateScript = nyakisato {
    subpaths = [ "aero-drop" ];
  };
}