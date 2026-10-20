{
  lib,
  writeShellApplication,
  coreutils,
  git,
  gnused,
  jq,
  nix-prefetch-git
}:

{
  subpaths ? []
}:

let 
  updateScript = writeShellApplication {
    name = "nyakisato";
    runtimeInputs = [
      coreutils
      git
      gnused
      jq
      nix-prefetch-git
    ];
    text = ''
      pkgAttr() {
        nix eval --raw ".#$UPDATE_NIX_ATTR_PATH.$1" --option warn-dirty false
      }
      senpaiPkgAttr() {
        nix eval --raw "git+file://$PWD?ref=senpai&shallow=1#$UPDATE_NIX_ATTR_PATH.$1" --option warn-dirty false
      }

      subpaths=()
      moddedFiles=()

      while (( $# > 0 )); do
        case $1 in
          --subpaths) 
            shift
            while [[ $# -gt 0 && $1 != -* ]]; do
              subpaths+=("$1")
              shift
            done
            ;;
          *)
            echo "nyakisato: unrecognized argument $1" >&2
            exit 1
        esac
      done

      pkgLoc=$(pkgAttr "meta.position" | sed "s/.*\(pkgs[^:]*\).*/\1/")

      if (( !NYAKISATO_CLONEPHOBIC )); then
        oldRev=$(pkgAttr "src.rev")
        oldHash=$(pkgAttr "src.hash")
        gitRepoUrl=$(pkgAttr "src.gitRepoUrl")

        remoteRev=$(git ls-remote "$gitRepoUrl" HEAD | cut -f1)
        if [[ "$remoteRev" = "$oldRev" ]]; then
          echo "itsupdatedidc"
          exit 0
        fi

        if [ -d "$NYAKISATO_DIRECTORY" ]; then
          git -C "$NYAKISATO_DIRECTORY" pull >&2
        else
          git clone "$gitRepoUrl" "$NYAKISATO_DIRECTORY" >&2
        fi

        newRev=$(git -C "$NYAKISATO_DIRECTORY" log -1 --format="%H")
        newHash=$(nix-prefetch-git "$gitRepoUrl" "$newRev" --quiet | jq -r ".hash")

        if [[ "$NYAKISATO_DIRECTORY" = *-repo ]]; then
          sed -i "s/$oldRev/$newRev/" flake.nix
          sed -i "s|$oldHash|$newHash|" flake.nix
          moddedFiles+=("flake.nix")
        else
          sed -i "s/$oldRev/$newRev/" "$pkgLoc"
          sed -i "s|$oldHash|$newHash|" "$pkgLoc"
        fi
      fi

      newVer=$(git -C "$NYAKISATO_DIRECTORY" log -1 --format="%cs" -- "''${subpaths[@]}")

      sed -i "s/$UPDATE_NIX_OLD_VERSION/$newVer/" "$pkgLoc"
      moddedFiles+=("$pkgLoc")

      commitMessage=""
      commitBody=""
      if (( !NYAKISATO_CLONEPHOBIC )); then
        originalRev=$(senpaiPkgAttr "src.rev")

        if [[ "$NYAKISATO_DIRECTORY" = *-repo ]]; then
          oldRepoVer=$(git -C "$NYAKISATO_DIRECTORY" log -1 "$originalRev" --format="%cs")
          newRepoVer=$(git -C "$NYAKISATO_DIRECTORY" log -1 --format="%cs")
          commitMessage="$NYAKISATO_TARGET: $oldRepoVer -> $newRepoVer"
        else
          commitMessage="$UPDATE_NIX_ATTR_PATH: $UPDATE_NIX_OLD_VERSION -> $newVer"
        fi

        if [[ "$gitRepoUrl" = *github.com* || "$gitRepoUrl" == *gitgud.io* ]]; then
          commitBody="Compare changes: ''${gitRepoUrl%.git}/compare/$originalRev...$newRev"
        fi
      fi

      jq -n \
        --arg attrPath "$UPDATE_NIX_ATTR_PATH" \
        --arg oldVersion "$UPDATE_NIX_OLD_VERSION" \
        --arg newVersion "$newVer" \
        --arg commitMessage "$commitMessage" \
        --arg commitBody "$commitBody" \
        '[{$attrPath, $oldVersion, $newVersion, $commitMessage, $commitBody, files: $ARGS.positional} | with_entries(select(.value != ""))] ' \
        --args "''${moddedFiles[@]}"
    '';
  };
in
{
  command = [
    (lib.getExe updateScript)
  ] ++ lib.optionals (subpaths != []) [ "--subpaths" ]
    ++ subpaths;
  supportedFeatures = [
    "commit"
  ];
}