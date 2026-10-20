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
  pname = "aeroshell-aeroglide";
  version = "2026-10-03";
  src = aeroshell-kwin-repo;

  buildInputs = [ kdePackages.qttools wayland-protocols kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "aeroglide" ];
  installTargets = "effects_cpp/aeroglide/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "effects_cpp/aeroglide" ];
  };
}
