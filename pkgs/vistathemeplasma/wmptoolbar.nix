{
  stdenvNoCC,
  wmp-toolbar-repo,
}:
stdenvNoCC.mkDerivation {
  pname = "vistathemeplasma-wmptoolbar";
  version = "1.0.0";
  src = wmp-toolbar-repo;

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/package $out/share/plasma/plasmoids/io.gitgud.catpswin56.wmptoolbar
    cp -r $src/styles $out/share/wmptoolbar
    runHook postInstall
  '';

  meta = {
    description = "Windows Media Player toolbar plasmoid used by VistaThemePlasma";
  };
}
