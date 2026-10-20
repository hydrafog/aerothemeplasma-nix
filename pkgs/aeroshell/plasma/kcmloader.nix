{
  stdenv,
  aeroshell-workspace-repo,
  kdePackages,
  pkg-config,
  cmake,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-kcmloader";
  version = "2026-02-21";
  src = aeroshell-workspace-repo;

  preConfigure = "cd aeroshell-kcmloader";
  buildInputs = with kdePackages; [ kcmutils ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];

  passthru.updateScript = nyakisato {
    subpaths = [ "aeroshell-kcmloader" ];
  };
}