{
  stdenvNoCC,
  vistathemeplasma-sounds-repo,
}:
stdenvNoCC.mkDerivation {
  pname = "vistathemeplasma-sounds";
  version = "2026-02-22";
  src = vistathemeplasma-sounds-repo;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sounds
    cp -r Windows\ Vista* $out/share/sounds
    runHook postInstall
  '';
  dontFixup = true;

}
