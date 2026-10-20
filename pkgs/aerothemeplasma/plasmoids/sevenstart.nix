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
  pname = "aerothemeplasma-sevenstart";
  version = "2026-10-12";
  src = aerothemeplasma-repo;

  preConfigure = ''
    # ??? it works i guess ???
    substituteInPlace plasma/plasmoids/src/sevenstart_src/CMakeLists.txt --replace-fail "add_subdirectory(src)" ""
    echo -e "find_package(PlasmaQuick)\nadd_subdirectory(src)" >> plasma/plasmoids/src/sevenstart_src/CMakeLists.txt
    substituteInPlace plasma/plasmoids/src/sevenstart_src/src/CMakeLists.txt --replace-fail "Plasma" "Plasma::Plasma"
    substituteInPlace plasma/plasmoids/src/sevenstart_src/src/CMakeLists.txt --replace-fail "/usr/include/Plasma::Plasma" "Plasma"
  '';
  buildInputs = with kdePackages; [ plasma-workspace knotifyconfig plasma5support ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "io.gitgud.wackyideas.SevenStart" ];
  installTargets = "plasma/plasmoids/src/sevenstart_src/install";
  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.SevenStart $out/share/plasma/plasmoids
    substituteInPlace $out/share/plasma/plasmoids/io.gitgud.wackyideas.SevenStart/contents/ui/*.qml \
      --replace-quiet "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core"
  '';

  passthru.updateScript = nyakisato {
    subpaths = [ 
      "plasma/plasmoids/src/sevenstart_src"
      "plasma/plasmoids/io.gitgud.wackyideas.SevenStart"
    ];
  };
}
