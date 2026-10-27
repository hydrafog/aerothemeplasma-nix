{
  stdenvNoCC,
  vistathemeplasma-repo,
  vistathemeplasma,
  kdePackages,
}:
stdenvNoCC.mkDerivation {
  pname = "vistathemeplasma-x11-session";
  version = "6.7.2";
  src = vistathemeplasma-repo;

  dontUnpack = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    install -Dm555 $src/plasma/sddm/login-sessions/startvtp.cmake $out/bin/startvtp
    substituteInPlace $out/bin/startvtp \
      --replace-fail "/etc/xdg/vistathemeplasma:/etc/xdg:" \
        "${vistathemeplasma}/etc/xdg/vistathemeplasma:${vistathemeplasma}/etc/xdg:/etc/xdg:" \
      --replace-fail "startplasma-x11" "${kdePackages.plasma-workspace}/bin/startplasma-x11"

    mkdir -p $out/share/xsessions
    cat > $out/share/xsessions/vistathemeplasmax11.desktop << EOF
[Desktop Entry]
Exec=$out/bin/startvtp
TryExec=$out/bin/startvtp
DesktopNames=KDE
Name=VistaThemePlasma (X11)
Comment=KDE Plasma running VistaThemePlasma on X11
X-KDE-PluginInfo-Version=6.7.2
EOF

    runHook postInstall
  '';

  passthru.providedSessions = [ "vistathemeplasmax11" ];
}
