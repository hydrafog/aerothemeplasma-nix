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
  pname = "aerothemeplasma-atpootb";
  version = "2026-10-15";
  src = aerothemeplasma-repo;

  postPatch = ''
    substituteInPlace plasma/atpootb/src/CMakeLists.txt \
      --replace-fail "\''${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml" "${kdePackages.kwin}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml"
  '';

  buildInputs = with kdePackages; [ plasma-workspace knotifyconfig plasma5support ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];

  cmakeFlags = [
    "-DKAUTH_ACTIONS_QML=false"
  ];
  ninjaFlags = [ "atpootb" ];
  installTargets = "plasma/atpootb/install";

  postInstall = ''
    mkdir -p $out/etc/xdg/autostart
    cp $src/misc/xdg/autostart/x-atpootb.desktop $out/etc/xdg/autostart
    substituteInPlace $out/etc/xdg/autostart/x-atpootb.desktop \
      --replace-fail "/usr/bin/atpootb" "$out/bin/atpootb"
  '';

  meta = {
    mainProgram = "atpootb";
  };

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/atpootb" ];
  };
}
