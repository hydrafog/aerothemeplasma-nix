{
  stdenvNoCC,
  aeroshell-kwin-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aeroshell-smodpeekeffect";
  version = "2026-02-21";
  src = aeroshell-kwin-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/kwin/effects
    cp -r $src/kwin/effects/smodpeekeffect $out/share/kwin/effects
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "kwin/effects/smodpeekeffect" ];
  };
}