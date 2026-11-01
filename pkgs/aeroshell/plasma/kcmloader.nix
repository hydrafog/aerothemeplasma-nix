{
  stdenv,
  aeroshell-workspace-repo,
  kdePackages,
  pkg-config,
  cmake,
}:
stdenv.mkDerivation {
  pname = "aeroshell-kcmloader";
  version = "2026-02-21";
  src = aeroshell-workspace-repo;

  preConfigure = "cd aeroshell-kcmloader";
  buildInputs = with kdePackages; [ kcmutils ];
  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];
}
