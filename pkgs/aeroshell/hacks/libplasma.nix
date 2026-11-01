{
  kdePackages,
  fetchFromGitLab,
  fetchzip,
  runCommand,
  diffutils,
}:
let
  patch-source = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "libplasma";
    rev = "d1c5ad5a1122514996f98ac746681650a8978f8f";
    hash = "sha256-78pc7EJ37J2+lmcbKyE1ePwqJ7jbDSuvUcC0N9rmBWc=";
  };
  patch-target = fetchzip {
    url = "mirror://kde/stable/plasma/6.7.0/libplasma-6.7.0.tar.xz";
    hash = "sha256-YIFhiymeaYv0cJvM/8eSJw95J0L7nAq2HZou2IscznQ=";
  };
in
kdePackages.libplasma.overrideAttrs (_oldAttrs: {
  pname = "aeroshell-libplasma";
  patches = [
    (runCommand "aeroshell-libplasma-patches" { nativeBuildInputs = [ diffutils ]; } ''
      cd ${patch-source}
      diff -ru ${patch-target}/src ./src > $out || test $? -eq 1
    '')
  ];
  postPatch = ''
    shopt -s globstar

    substituteInPlace src/**/CMakeLists.txt \
      --replace-warn 'URI "org.kde.plasma.' 'URI "io.gitgud.wackyideas.plasma.' \
      --replace-warn "EXPORT_NAME Plasma" "OUTPUT_NAME ATPlasma"
    substituteInPlace src/**/*.qml --replace-quiet "import org.kde.plasma." "import io.gitgud.wackyideas.plasma."

    substituteInPlace src/declarativeimports/core/tooltipdialog.cpp --replace-fail \
      'SourceFromModule("org.kde.plasma.' 'SourceFromModule("io.gitgud.wackyideas.plasma.'

    substituteInPlace src/declarativeimports/CMakeLists.txt --replace-fail "add_subdirectory(kirigamiplasmastyle)" ""
    substituteInPlace src/plasma/CMakeLists.txt --replace-fail "add_subdirectory(packagestructure)" ""
  '';
  ninjaFlags = [ "corebindingsplugin" ];
  postFixup = "rm -rf $out/share";
})
