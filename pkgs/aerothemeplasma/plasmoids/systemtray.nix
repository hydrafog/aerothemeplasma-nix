{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  pkg-config,
  cmake,
  ninja,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-systemtray";
  version = "2026-10-12";
  src = aerothemeplasma-repo;

  preConfigure = ''
    shopt -s globstar
    substituteInPlace plasma/plasmoids/src/systemtray_src/systemtray/package/contents/**/*.qml --replace-quiet \
      "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core"
  '';
  buildInputs = with kdePackages; [
    plasma-workspace
    knotifyconfig
    plasma5support
  ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "io.gitgud.wackyideas.systemtray" ];
  installTargets = "plasma/plasmoids/src/systemtray_src/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/plasmoids/src/systemtray_src" ];
  };
}
