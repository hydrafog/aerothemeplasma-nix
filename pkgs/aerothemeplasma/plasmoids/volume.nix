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
  pname = "aerothemeplasma-volume";
  version = "2026-10-12";
  src = aerothemeplasma-repo;

  buildInputs = with kdePackages; [ plasma-workspace knotifyconfig plasma5support ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "io.gitgud.wackyideas.volume" ];
  installTargets = "plasma/plasmoids/src/volume_src/install";
  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids
    cp -r $src/plasma/plasmoids/io.gitgud.wackyideas.volume $out/share/plasma/plasmoids
    substituteInPlace $out/share/plasma/plasmoids/io.gitgud.wackyideas.volume/contents/ui/*.qml \
      --replace-quiet "import org.kde.plasma.core" "import io.gitgud.wackyideas.plasma.core"
  '';

  passthru.updateScript = nyakisato {
    subpaths = [ 
      "plasma/plasmoids/src/volume_src"
      "plasma/plasmoids/io.gitgud.wackyideas.volume"
    ];
  };
}
