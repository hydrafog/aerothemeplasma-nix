{
  stdenv,
  aeroshell-smod-repo,
  kdePackages,
  pkg-config,
  smod,
  cmake,
  lib,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-smodglow";
  version = "2026-10-03";
  src = aeroshell-smod-repo;

  buildInputs = [ smod kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "BUILD_EFFECT" true) ];

  passthru.updateScript = nyakisato {
    subpaths = [ "gloweffect" ];
  };
}
