{
  lib,
  stdenvNoCC,
  aerothemeplasma-icons-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-icons";
  version = "2026-08-31";
  src = aerothemeplasma-icons-repo;

  installPhase = ''
    runHook preUnpack
    mkdir -p $out/share/icons
    cp -r 'Windows 7 Aero' $out/share/icons
    runHook postUnpack
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "Windows 7 Aero" ];
  };
}