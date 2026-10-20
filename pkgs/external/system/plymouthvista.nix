{
  stdenvNoCC,
  fetchFromGitHub,
  imagemagick,
  segoe-ui,
  makeFontsConf,
  settings ? {},
  lib,
  nyakisato
}:
let
  pvizeAttrs = attrs: lib.mapAttrs (name: value: 
    if (lib.isString value) then value
    else if (lib.isInt value) then (lib.toString value)
    else if (lib.isBool value) then (if value then "1" else "0") 
    # https://github.com/NixOS/nixpkgs/blob/56c315f08829fa61c48320e4e4371ef4177d1e5a/lib/types.nix#L891
    else throw "plymouthvista: setting `${name}' is not of type `string or boolean or signed integer'."
  ) attrs;

  mkPvConfs = attrs: lib.concatMapAttrsStringSep "\n" (name: value:
    "./pv_conf.sh -s ${lib.escapeShellArg name} -v ${lib.escapeShellArg value}"
  ) (pvizeAttrs attrs);
in 
stdenvNoCC.mkDerivation {
  pname = "plymouthvista";
  version = "2026-07-26";
  src = fetchFromGitHub {
    owner = "furkrn";
    repo = "PlymouthVista";
    rev = "e2b9605a7b4d649bb0e314cce8bbe9912633cfef";
    hash = "sha256-bB4fXkyeKo9Ykzw18xM2BZGjJMPF6NGA84d502FDEWc=";
  };

  env = {
    # https://discourse.nixos.org/t/fontconfig-error-no-writable-cache-directories/34447/2
    XDG_CACHE_HOME = "$(mktemp -d)";
    # https://discourse.nixos.org/t/imagemagicks-convert-command-fails-due-to-fontconfig-error/20518/5
    FONTCONFIG_FILE = makeFontsConf {
      fontDirectories = [ segoe-ui ];
    };
  };
  nativeBuildInputs = [ imagemagick ];
  buildPhase = ''
    runHook preBuild
    patchShebangs ./compile.sh ./pv_conf.sh ./gen_blur.sh

    ./compile.sh
    ${mkPvConfs settings}
    ./gen_blur.sh

    substituteInPlace PlymouthVista.plymouth \
      --replace-fail "/usr/share" "$out/share"

    mkdir -p $out/share/plymouth/themes/PlymouthVista
    cp -r images PlymouthVista.plymouth PlymouthVista.script \
      $out/share/plymouth/themes/PlymouthVista

    runHook postBuild
  '';

  passthru.updateScript = nyakisato { };
}