{
  stdenv,
  aeroshell-kwin-repo,
  kdePackages,
  wayland-protocols,
  pkg-config,
  cmake,
  ninja,
  lib,
  session ? "wayland",
}:
stdenv.mkDerivation {
  pname = "aeroshell-launchfeedback-${session}";
  version = if session == "wayland" then "2026-06-18" else "2026-06-21";
  src = aeroshell-kwin-repo;

  buildInputs = [
    kdePackages.qttools
    wayland-protocols
  ]
  ++ lib.optionals (session == "x11") [ kdePackages.kwin-x11 ]
  ++ lib.optionals (session == "wayland") [ kdePackages.kwin ];
  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    kdePackages.wrapQtAppsHook
  ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_BUILD_WAYLAND" (session == "wayland")) ];
  ninjaFlags = [ "launchfeedback${lib.optionalString (session == "x11") "-x11"}" ];
  installTargets = "effects_cpp/${session}/startupfeedback/install";
}
