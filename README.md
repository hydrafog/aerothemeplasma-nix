# AeroThemePlasma and VistaThemePlasma on NixOS
This [flake](https://wiki.nixos.org/wiki/Flakes) can be used to install [AeroThemePlasma](https://gitgud.io/aeroshell/atp/aerothemeplasma) (Windows 7) or [VistaThemePlasma](https://github.com/aeroshell-desktop/vistathemeplasma) (Windows Vista) on a NixOS unstable system. For 26.05 systems, use the [26.05 branch](https://github.com/nyakase/aerothemeplasma-nix/tree/26.05).

![Demo of AeroThemePlasma on a running NixOS system](demo.png)

## Installation

### Modules
Add aerothemeplasma-nix as a flake input and NixOS module. 

<details>
<summary>Example flake.nix</summary>

```nix
# ./flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ nixpkgs, aerothemeplasma-nix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
      ];
    };
  }
}
```

</details>

### Configuration
To install a theme, enable AeroShell and exactly one of the two theme modules.
Both themes use a Wayland session.

AeroThemePlasma (Windows 7):

```nix
boot.plymouth.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
services.displayManager.defaultSession = "aerothemeplasma";

programs.aeroshell = {
  enable = true;
  fonts.segoe.enable = true;
  polkit.enable = true;
  aerothemeplasma = {
    enable = true;
    sddm.enable = true;
    plymouth.enable = true;
  };
};
```

VistaThemePlasma (Windows Vista):

```nix
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
services.displayManager.defaultSession = "vistathemeplasma";

programs.aeroshell = {
  enable = true;
  fonts.segoe.enable = true;
  polkit.enable = true;
  vistathemeplasma = {
    enable = true;
    sddm.enable = true;
  };
};
```

The two themes can be enabled together if you want both sessions, but only
one SDDM theme and one Plymouth style can be selected at a time.

### Package overrides
Every package installed by the module can be replaced through
`programs.aeroshell.packages`.  Keys are the package names exposed by this
flake:

```nix
programs.aeroshell.packages = {
  lucida-console = pkgs.lucida-console.overrideAttrs (old: {
    src = ./lucon.ttf;
  });
  vistathemeplasma = pkgs.vistathemeplasma.overrideAttrs (old: {
    # ...
  });
};
```

Convenience options exist for the most commonly replaced packages:

```nix
programs.aeroshell.fonts.lucida.package = lucida-console;
programs.aeroshell.vistathemeplasma.package = my-vtp;
programs.aeroshell.vistathemeplasma.icons.package = my-icons;
programs.aeroshell.aerothemeplasma.sddm.package = my-sddm-theme;
```

### Prebuilt binary cache
VistaThemePlasma is expensive to compile on low-power machines.  The fork's
[`build-vista` workflow](.github/workflows/build-vista.yml) builds the VTP
packages on GitHub Actions and uploads them as an unsigned Nix binary cache.

Download the latest artifact from the repository's **Actions** tab, or with
GitHub CLI:

```bash
gh run download --repo hydrafog/aerothemeplasma-nix \
  --name vista-nix-cache -D vista-cache
```

Then import the paths into your local store:

```bash
sudo nix copy --no-check-sigs --from "file://$PWD/vista-cache" \
  '.#packages.x86_64-linux.vistathemeplasma' \
  '.#packages.x86_64-linux.vistathemeplasma-icons' \
  '.#packages.x86_64-linux.vistathemeplasma-cursors' \
  '.#packages.x86_64-linux.vistathemeplasma-sounds'
```

The tiny `aeroshell-vista-session` package is not included in the cache because
it only copies a service file and builds in seconds against the already
installed `plasma-workspace`.

Your normal `nixos-rebuild switch` will then reuse those store paths instead of
recompiling VTP.  The cache is unsigned and intentionally only contains the
custom packages; their ordinary dependencies still come from the official Nix
cache.

### Upstream packaging
An AeroThemePlasma package and NixOS module have been proposed for nixpkgs
(see [nixpkgs#560156](https://github.com/NixOS/nixpkgs/pull/560156)).  This
flake does not depend on that work, and it will continue to build its own
packages.  If the nixpkgs packages become available, they can be substituted
through `programs.aeroshell.packages` just like any other override.

#### Lucida Console font
If you use full disk encryption, Plymouth shows a password screen [(though NixOS doesn't support that by default)](https://github.com/NixOS/nixpkgs/issues/26722#issuecomment-1693500074). The Lucida Console font is used for the screen, which can be enabled with `programs.aeroshell.fonts.lucida.enable = true;` but you must obtain a copy from Windows 7 yourself.

Grab it from `C:\Windows\Fonts\lucon.ttf`. Its version should be 327680, which you can check with `fc-query -f "%{fontversion}" lucon.ttf`. Then add it to your Nix store with `nix store add-file lucon.ttf`.

### Go to town
Rebuild and reboot your system. You can open the session list with the bottom-left button if using the SDDM theme. Select the AeroThemePlasma or VistaThemePlasma session if it is not pre-selected.

When booting into the session for the first time, a setup wizard will launch and help you finish applying the Plasma theme. Have fun!

## Uninstallation
Remove the [NixOS module](#modules) and [associated options](#configuration) from your configuration. You can switch back to your old theme in [System Settings](https://userbase.kde.org/System_Settings):

1. Under "Colors & Themes", pick your old Global Theme (the default is Breeze).
2. Under "Text & Fonts", choose your old fonts (the default is Noto Sans).

Lastly, delete the `~/.config/aerothemeplasmarc` or `~/.config/vistathemeplasmarc` file, depending on the theme. Not doing so prevents the setup wizard from launching on reinstallation.

## Potential questions

### Why did tooltips break after restarting `plasmashell`?
Under the AeroThemePlasma and VistaThemePlasma sessions it's called `aeroshell`, so you should restart that instead. If you use `plasmashell`, it will start without the tooltip patch.

### Why did some parts of the theme reset when I rebuilt?
Do you use [plasma-manager](https://github.com/nix-community/plasma-manager)? If settings in plasma-manager conflict with what was set by the AeroThemePlasma setup wizard, or you are using `programs.plasma.overrideConfig`, the theme settings may be overridden.

### Why is this section called "Potential questions"?
I can't call them frequently asked questions when I haven't been asked them a single time yet!

## Special thanks
* [WackyIdeas](https://github.com/WackyIdeas) and contributors for developing [AeroThemePlasma](https://gitgud.io/aeroshell/atp/aerothemeplasma)
* [catpswin56](https://github.com/catpswin56) and contributors for developing [VistaThemePlasma](https://github.com/aeroshell-desktop/vistathemeplasma)
* [aean0x](https://github.com/aean0x/.dotfiles/tree/20a3dd32b3ddbd752c93c9f38e03e76dbbd3ce87/aerotheme) and [Rotlug](https://github.com/Rotlug/aerothemeplasma-nixos) for prior art in packaging AeroThemePlasma, though this flake deviates significantly
* [ech0devv](https://github.com/ech0devv) and [Rotlug](https://github.com/Rotlug) for writing derivations for [the Sevulet suite](https://github.com/nyakase/aerothemeplasma-nix/pull/14) and [`atpootb`](pkgs/aerothemeplasma/plasma/atpootb.nix) respectively
* [DuCanhGH](<https://github.com/DuCanhGH/snowflakes/tree/main/modules/nixos/aero>) for additional prior art in packaging AeroThemePlasma, and being friendly about it
* Chris Lejman of [brokenTONE](https://brokentone.net) for creating the ["Not so ordinary life"](https://brokentone.net/wall/147-not-so-ordinary-life/) wallpaper, used in the demo screenshot

### [It's fun to stay at the](https://music.youtube.com/watch?v=RN8Li7kYNnw&t=57) C.E.L.A.
THIS PROJECT IS IN NO WAY AFFILIATED WITH THE MICROSOFT GROUP OF COMPANIES. Windows® and Segoe® are registered trademarks of the Microsoft Corporation in the United States. This project does not aim to, and does not, distribute copies of the Microsoft Corporation's famous Windows® 7 operating system and associated fonts. The version of Segoe® used in the [`segoe-ui`](pkgs/external/fonts/segoe-ui.nix) package is retrieved from [a Microsoft repository under the MIT license](https://github.com/microsoft/MixedReality-AzureCommunicationServices-Sample/blob/0be22d2d10aa8172053206fa3d3a29799817313a/LICENSE).
