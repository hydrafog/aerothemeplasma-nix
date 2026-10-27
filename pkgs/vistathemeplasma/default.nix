{
  stdenv,
  vistathemeplasma-repo,
  kdePackages,
  cmake,
  ninja,
  pkg-config,
  gettext,
  wayland,
  wayland-protocols,
  libdrm,
  vulkan-headers,
  libepoxy,
}:
stdenv.mkDerivation {
  pname = "vistathemeplasma";
  version = "6.7.2";
  src = vistathemeplasma-repo;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtdeclarative
    qtsvg
    qtwayland
    qt5compat
    qtmultimedia
    kcoreaddons
    kconfig
    ki18n
    kio
    kguiaddons
    kwindowsystem
    kiconthemes
    kcmutils
    kpackage
    ksvg
    kdecoration
    knotifications
    kservice
    kxmlgui
    kjobwidgets
    kitemviews
    kstatusnotifieritem
    kdbusaddons
    kauth
    kcrash
    karchive
    kcolorscheme
    knewstuff
    knotifyconfig
    attica
    krunner
    sonnet
    kcodecs
    kitemmodels
    kglobalaccel
    plasma5support
    libplasma
    plasma-workspace
    plasma-activities
    plasma-activities-stats
    libksysguard
    kwin
    layer-shell-qt
    plasma-wayland-protocols
    kirigami
    kirigami-addons
    qqc2-desktop-style
    libkscreen
    kpipewire
  ] ++ [
    wayland
    wayland-protocols
    libdrm
    vulkan-headers
    libepoxy
  ];

  # The VTP CMake build expects the KWin effect interface XML at the install
  # prefix, which does not exist yet while the derivation is being built.
  postPatch = ''
    substituteInPlace plasma/vtpootb/src/CMakeLists.txt \
      --replace-fail "\''${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml" \
        '${kdePackages.kwin}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml'

    # vtpootb opens its bundled assets through this compile-time path.
    substituteInPlace plasma/vtpootb/src/app.h \
      --replace-fail '/usr/share/vistathemeplasma' "$out/share/vistathemeplasma"
  '';

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
  ];

  postInstall = ''
    # Make the generated session script use the Nix store versions of
    # startplasma-wayland and plasma-dbus-run-session-if-needed, and point
    # XDG_CONFIG_DIRS at this package's session configuration.
    substituteInPlace $out/bin/startvtp-wayland \
      --replace-fail "$out/libexec/plasma-dbus-run-session-if-needed" \
        "${kdePackages.plasma-workspace}/libexec/plasma-dbus-run-session-if-needed" \
      --replace-fail "$out/bin/startplasma-wayland" \
        "${kdePackages.plasma-workspace}/bin/startplasma-wayland" \
      --replace-fail 'export XDG_CONFIG_DIRS="/etc/xdg/vistathemeplasma:/etc/xdg:$XDG_CONFIG_DIRS"' \
        "export XDG_CONFIG_DIRS=\"$out/etc/xdg/vistathemeplasma:$out/etc/xdg:/etc/xdg:\$XDG_CONFIG_DIRS\""

    substituteInPlace $out/etc/xdg/autostart/x-vtpootb.desktop \
      --replace-fail '/usr/bin/vtpootb' "$out/bin/vtpootb"

    substituteInPlace $out/etc/xdg/vistathemeplasma/kwinrc \
      --replace-fail '/usr/share/vistathemeplasma' "$out/share/vistathemeplasma"

    substituteInPlace $out/etc/xdg/vistathemeplasma/kcm-about-distrorc \
      --replace-fail '/usr/share/vistathemeplasma' "$out/share/vistathemeplasma"

    # Upstream refers to a bgtexture.jpg that is not shipped; the theme's
    # actual background image is the "background" file next to Main.qml.
    substituteInPlace $out/etc/xdg/vistathemeplasma/kscreenlockerrc \
      --replace-fail '/usr/share/sddm/themes/vista-theme-mod/bgtexture.jpg' \
        "$out/share/sddm/themes/vista-theme-mod/background"

    find $out/share -name '*.qml' -exec \
      substituteInPlace {} \
        --replace-fail '/usr/share/vistathemeplasma' "$out/share/vistathemeplasma" \;
  '';

  passthru.providedSessions = [ "vistathemeplasma" ];

  meta = {
    description = "Windows Vista style shell and theme for KDE Plasma";
    mainProgram = "vtpootb";
  };
}
