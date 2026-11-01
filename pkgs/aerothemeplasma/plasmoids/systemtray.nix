{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  pkg-config,
  cmake,
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-systemtray";
  version = "2026-02-28";
  src = aerothemeplasma-repo;

  preConfigure = ''
    cd plasma/plasmoids/src/systemtray_src
    shopt -s globstar
    substituteInPlace systemtray/package/contents/**/*.qml --replace-quiet \
      "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core"
  '';
  buildInputs = with kdePackages; [
    libplasma
    qtwayland
    knotifyconfig
    kitemmodels
    kstatusnotifieritem
  ];
  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];
}
