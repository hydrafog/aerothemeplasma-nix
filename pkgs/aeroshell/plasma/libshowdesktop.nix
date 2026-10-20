{
  stdenv,
  aeroshell-workspace-repo,
  kdePackages,
  cmake,
  ninja,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-libshowdesktop";
  version = "2026-02-21";
  src = aeroshell-workspace-repo;

  ninjaFlags = [ "showdesktopplugin" ];
  buildInputs = with kdePackages; [
    extra-cmake-modules kconfig ki18n
    kio knotifications kservice kwindowsystem
    libksysguard plasma-workspace
  ];
  nativeBuildInputs = [ cmake ninja ];
  dontWrapQtApps = true;
  installPhase = ''
    runHook preInstall
    ninja libshowdesktop/install
    runHook postInstall
  '';

  passthru.updateScript = nyakisato {
    subpaths = [ "libshowdesktop" ];
  };
}