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
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-smodsnap";
  version = "2026-10-11";
  src = aeroshell-kwin-repo;

  buildInputs = [ kdePackages.qttools wayland-protocols smod kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "kwin_effect_smodsnap" ];
  installTargets = "effects_cpp/kwin-effect-smodsnap-v2/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "effects_cpp/kwin-effect-smodsnap-v2" ];
  };
}
