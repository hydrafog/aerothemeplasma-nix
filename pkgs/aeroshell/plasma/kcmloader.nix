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

  postPatch = ''
    substituteInPlace aeroshell-kcmloader/main.cpp \
      --replace-fail 'a.setApplicationName("aeroshell-kcmloader");' \
        'QCoreApplication::addLibraryPath(QStringLiteral("/run/current-system/sw/lib/qt-6/plugins")); a.setApplicationName("aeroshell-kcmloader");'
  '';

  preConfigure = "cd aeroshell-kcmloader";
  buildInputs = with kdePackages; [ kcmutils ];
  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];
  qtWrapperArgs = [
    "--prefix"
    "QT_PLUGIN_PATH"
    ":"
    "/run/current-system/sw/lib/qt-6/plugins"
  ];
}
