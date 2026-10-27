{
  stdenvNoCC,
  libplasma,
}:
stdenvNoCC.mkDerivation {
  pname = "aeroshell-libplasma-compat";
  version = libplasma.version;

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    shopt -s nullglob
    for f in ${libplasma}/lib/libATPlasma.so* ${libplasma}/lib/libATPlasmaQuick.so*; do
      name=$(basename "$f")
      ln -s "$f" "$out/lib/$name"
      ln -s "$f" "$out/lib/''${name/libATPlasma/libPlasma}"
    done
    runHook postInstall
  '';

  meta = {
    description = "libPlasma-compatible symlinks for AeroShell's patched libplasma";
  };
}
