{
  stdenv,
  aeroshell-kwin-repo,
  kdePackages,
  wayland-protocols,
  pkg-config,
  cmake,
  ninja,
  lib,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-launchfeedback";
  version = "2026-10-03";
  src = aeroshell-kwin-repo;

  buildInputs = [ kdePackages.qttools wayland-protocols kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "launchfeedback" ];
  installTargets = "effects_cpp/startupfeedback/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "effects_cpp/startupfeedback" ];
  };
}
