{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  pkg-config,
  cmake,
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-volume";
  version = "2026-02-27";
  src = aerothemeplasma-repo;

  preConfigure = "cd plasma/plasmoids/src/volume_src";
  buildInputs = [ kdePackages.libplasma ];
  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];
  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.volume $out/share/plasma/plasmoids
    substituteInPlace $out/share/plasma/plasmoids/io.gitgud.wackyideas.volume/contents/ui/*.qml \
      --replace-quiet "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core"
  '';
}
