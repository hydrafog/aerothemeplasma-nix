{
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-sounds";
  version = "2026-01-29";
  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/aerothemeplasma-sounds";
    rev = "4926188adcfed7ee699b53d3fb88e1996d67543d";
    hash = "sha256-nGZtC0cC0hBWIX0zkwsdQ4klGhCy6KuEajvxtKH7Q0Q=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sounds
    cp -r Windows* $out/share/sounds
    runHook postInstall
  '';
  dontFixup = true;
}
