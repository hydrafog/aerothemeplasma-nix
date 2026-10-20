{
  kdePackages,
  fetchFromGitLab,
  fetchzip,
  runCommand,
  diffutils
}:
let
  patch-source = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "libplasma";
    rev = "bc48942bbd5aa7fc6d62b050701eabbe2b31e054";
    hash = "sha256-MWbTvNlpat8eP3S158kdDMIR0N5MerpCPS7z2uyRGTc=";
  };
  patch-target = fetchzip {
    url = "mirror://kde/stable/plasma/6.8.0/libplasma-6.8.0.tar.xz";
    hash = "sha256-zcBF1eObm0hir04ayFpx8v0HsZAE6zgKB05qN8/hvu4=";
  };
in
kdePackages.libplasma.overrideAttrs (oldAttrs: {
  pname = "aeroshell-libplasma";
  patches = [(
    runCommand "aeroshell-libplasma-patches" { nativeBuildInputs = [diffutils]; } ''
      cd ${patch-source}
      diff -ru ${patch-target}/src ./src > $out || test $? -eq 1
    ''
  )];
  postPatch = ''
    shopt -s globstar

    substituteInPlace src/**/CMakeLists.txt \
      --replace-warn 'URI "org.kde.plasma.' 'URI "io.gitgud.wackyideas.plasma.' \
      --replace-warn "EXPORT_NAME Plasma" "OUTPUT_NAME ATPlasma"
    substituteInPlace src/**/*.qml --replace-quiet "import org.kde.plasma." "import io.gitgud.wackyideas.plasma."

    substituteInPlace src/declarativeimports/core/tooltipdialog.cpp --replace-fail \
      'component(m_engine.get(), "org.kde.plasma.' 'component(m_engine.get(), "io.gitgud.wackyideas.plasma.'

    substituteInPlace src/declarativeimports/CMakeLists.txt --replace-fail "add_subdirectory(kirigamiplasmastyle)" ""
    substituteInPlace src/plasma/CMakeLists.txt --replace-fail "add_subdirectory(packagestructure)" ""
  '';
  ninjaFlags = ["corebindingsplugin"];
  postFixup = "rm -rf $out/share";
})
