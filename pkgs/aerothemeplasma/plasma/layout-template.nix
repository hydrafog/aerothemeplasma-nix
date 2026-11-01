{
  stdenvNoCC,
  aerothemeplasma-repo,
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-layout-template";
  version = "2025-10-24";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/layout-templates
    cp -r $src/plasma/layout-templates/io.gitgud.wackyideas.taskbar $out/share/plasma/layout-templates
    runHook postInstall
  '';
}
