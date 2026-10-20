{
  stdenv,
  aeroshell-smod-repo,
  aeroshell-kwin-repo,
  kdePackages,
  pkg-config,
  cmake,
  lib,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-smod";
  version = "2026-10-11";
  src = aeroshell-smod-repo;

  buildInputs = with kdePackages; [
    extra-cmake-modules qtbase kcoreaddons 
    kcolorscheme kguiaddons ki18n kiconthemes 
    kwindowsystem kdecoration kcmutils
  ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
  postFixup = "rm -rf $out/share/locale && mkdir -p $out/share && cp -r ${aeroshell-kwin-repo}/smod $out/share";
  cmakeFlags = [ (lib.cmakeBool "BUILD_EFFECT" false) ];

  passthru.updateScript = nyakisato {
    subpaths = [ "kdecoration" "theme" ];
  };
}