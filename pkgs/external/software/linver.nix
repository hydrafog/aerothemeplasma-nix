{
  stdenv,
  lib,
  fetchFromGitLab,
  qt6,
  lsb-release,
}:
stdenv.mkDerivation {
  pname = "linver";
  version = "2025-01-17";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "wackyideas";
    repo = "linver";
    rev = "c658184980a10c858180c333a8d4f6d3199d0137";
    sha256 = "sha256-Z0GtA9F2K4zwNryicVLrjLWCwMVr8UZH4DiiQW9yiOw=";
  };

  buildInputs = [ qt6.qtbase ];
  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    qt6.qmake
  ];
  qmakeFlags = [ "linver.pro" ];

  postPatch = "substituteInPlace linver.pro --replace-fail 'target.path = /usr/bin' \"target.path = $out/bin\"";
  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ lsb-release ]}" ];
}
