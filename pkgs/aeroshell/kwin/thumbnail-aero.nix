{
  stdenvNoCC,
  aeroshell-kwin-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aeroshell-thumbnail-aero";
  version = "2026-06-27";
  src = aeroshell-kwin-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/kwin/tabbox
    cp -r $src/kwin/tabbox/thumbnail_aero $out/share/kwin/tabbox
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "kwin/tabbox/thumbnail_aero" ];
  };
}