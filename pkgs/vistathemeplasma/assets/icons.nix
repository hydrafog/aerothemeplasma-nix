{
  stdenvNoCC,
  vistathemeplasma-icons-repo,
  nyakisato,
}:
stdenvNoCC.mkDerivation {
  pname = "vistathemeplasma-icons";
  version = "2026-07-05";
  src = vistathemeplasma-icons-repo;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r 'Windows Vista Aero' $out/share/icons
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "Windows Vista Aero" ];
  };
}
