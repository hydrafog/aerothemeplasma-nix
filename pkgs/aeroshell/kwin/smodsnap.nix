{
  stdenv,
  aeroshell-kwin-repo,
  kdePackages,
  wayland-protocols,
  pkg-config,
  smod,
  cmake,
  ninja,
  lib,
  session ? "wayland",
}:
stdenv.mkDerivation {
  pname = "aeroshell-smodsnap-${session}";
  version = "2026-06-18";
  src = aeroshell-kwin-repo;

  buildInputs = [
    kdePackages.qttools
    wayland-protocols
    smod
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
  ninjaFlags = [ "kwin_effect_smodsnap" ];
  installTargets = "effects_cpp/${session}/kwin-effect-smodsnap-v2/install";
}
