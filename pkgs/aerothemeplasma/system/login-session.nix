{
  stdenv,
  lib,
  aerothemeplasma-repo,
  xdg,
  kdePackages,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-login-session";
  version = "2026-10-12";
  src = aerothemeplasma-repo;

  installPhase = ''
    cd plasma/sddm/login-sessions

    substituteInPlace startatp-wayland.cmake \
      --replace-fail "@CMAKE_INSTALL_FULL_LIBEXECDIR@/plasma-dbus-run-session-if-needed" "${kdePackages.plasma-workspace}/libexec/plasma-dbus-run-session-if-needed" \
      --replace-fail "\''${CMAKE_INSTALL_FULL_BINDIR}/startplasma-wayland" "${kdePackages.plasma-workspace}/bin/startplasma-wayland" \
      --replace-fail "/etc/xdg/aerothemeplasma:/etc/xdg:" "${xdg}/etc/xdg:"

    substituteInPlace aerothemeplasma.desktop.cmake \
      --replace-fail "\''${CMAKE_INSTALL_FULL_BINDIR}/startatp-wayland" "$out/bin/startatp-wayland" \
      --replace-fail "\''${PROJECT_VERSION}" "$(grep -m 1 "PROJECT_VERSION" ../../../CMakeLists.txt | sed "s/.*\([0-9]\.[0-9]\.[0-9]\).*/\1/")"

    install -Dm555 startatp-wayland.cmake $out/bin/startatp-wayland
    install -Dm444 aerothemeplasma.desktop.cmake $out/share/wayland-sessions/aerothemeplasma.desktop
  '';

  passthru = {
    providedSessions = [ "aerothemeplasma" ];
    updateScript = nyakisato {
      subpaths = [ "plasma/sddm/login-sessions" ];
    };
  };
}
