{
  stdenvNoCC,
  plasma-workspace,
}:
stdenvNoCC.mkDerivation {
  pname = "aeroshell-vista-session";
  version = "1";

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p \
      $out/share/systemd/user/plasma-core.target.d \
      $out/share/systemd/user/plasma-plasmashell.service.d \
      $out/share/systemd/user/plasma-vistathemeplasma.service.d

    # Reuse the AeroShell service unit from the patched plasma-workspace,
    # but give VistaThemePlasma its own name and condition.  Keeping this out
    # of plasma-workspace means switching themes does not rebuild it.
    install -Dm444 \
      ${plasma-workspace}/share/systemd/user/plasma-aeroshell.service \
      $out/share/systemd/user/plasma-vistathemeplasma.service
    substituteInPlace $out/share/systemd/user/plasma-vistathemeplasma.service \
      --replace-fail "Description=AeroShell Workspace" \
        "Description=VistaThemePlasma Workspace"

    cat > $out/share/systemd/user/plasma-core.target.d/vistathemeplasma.conf << EOF
[Unit]
Wants=plasma-vistathemeplasma.service
EOF

    cat > $out/share/systemd/user/plasma-plasmashell.service.d/vistathemeplasma.conf << EOF
[Unit]
ConditionEnvironment=!PLASMA_DEFAULT_SHELL=io.gitgud.catpswin56.desktop
EOF

    cat > $out/share/systemd/user/plasma-vistathemeplasma.service.d/vistathemeplasma.conf << EOF
[Unit]
ConditionEnvironment=PLASMA_DEFAULT_SHELL=io.gitgud.catpswin56.desktop
EOF
  '';
}
