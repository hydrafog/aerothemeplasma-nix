{
  stdenv,
  aeroshell-workspace-repo,
  kdePackages,
  cmake,
  ninja,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroshell-components";
  version = "2026-10-13";
  src = aeroshell-workspace-repo;

  ninjaFlags = [ "aeroshell_components" "aeroshell_components_private" ];
  buildInputs = with kdePackages; [
    extra-cmake-modules kconfig ki18n
    kio knotifications kservice kwindowsystem
    libksysguard plasma-workspace
  ];
  nativeBuildInputs = [ cmake ninja ];
  dontWrapQtApps = true;
  installPhase = ''
    runHook preInstall
    ninja components/install
    runHook postInstall
  '';

  passthru.updateScript = nyakisato {
    subpaths = [ "components" ];
  };
}
