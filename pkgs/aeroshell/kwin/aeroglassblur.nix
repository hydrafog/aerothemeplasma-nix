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
  pname = "aeroshell-aeroglassblur";
  version = "2026-10-13";
  src = aeroshell-kwin-repo;

  buildInputs = [ kdePackages.qttools wayland-protocols kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "aeroglassblur" ];
  installTargets = "effects_cpp/kde-effects-aeroglassblur/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "effects_cpp/glsl/outputmanagement.frag" "effects_cpp/kde-effects-aeroglassblur" ];
  };
}
