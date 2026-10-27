{
  stdenv,
  wmp-toolbar-repo,
  kdePackages,
  cmake,
}:
stdenv.mkDerivation {
  pname = "vistathemeplasma-wmptoolbar";
  version = "1.0.0";
  src = wmp-toolbar-repo;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];
  buildInputs = [ kdePackages.libplasma ];
  dontWrapQtApps = true;

  meta = {
    description = "Windows Media Player toolbar plasmoid used by VistaThemePlasma";
  };
}
