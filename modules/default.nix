perSystem:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.aeroshell;
  atpkgs = perSystem.config.packages;

  # Every package the module installs can be overridden through
  # `programs.aeroshell.packages.<name>`.  The defaults come from this flake's
  # package set.
  pkg = name: cfg.packages.${name} or atpkgs.${name};

  pvcfg =
    if cfg.aerothemeplasma.plymouth.enable then
      cfg.aerothemeplasma.plymouth
    else
      cfg.vistathemeplasma.plymouth;
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "programs" "aeroshell" "sessions" ] ''
      `programs.aeroshell.sessions` no longer has any effect, as Wayland is now the only available session.
    '')
  ];

  options.programs = {
    aeroshell = rec {
      enable = lib.mkEnableOption "AeroShell";

      packages = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
        default = { };
        description = ''
          Overrides for the packages installed by this module.  Keys are the
          package names as exposed by this flake, for example
          `lucida-console`, `segoe-ui`, `vistathemeplasma`, or
          `vistathemeplasma-icons`.
        '';
        example = lib.literalExpression ''
          {
            lucida-console = pkgs.lucida-console.overrideAttrs (old: {
              src = ./lucon.ttf;
            });
          }
        '';
      };

      polkit = {
        enable = lib.mkEnableOption "the AeroShell Polkit agent replacement";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkg "uac-polkit-agent";
          description = "The UAC Polkit agent package.";
        };
      };

      fonts = {
        enable = lib.mkEnableOption "the Segoe UI and Lucida Console fonts";
        segoe = {
          enable = lib.mkEnableOption "the Segoe UI font";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "segoe-ui";
            description = "The Segoe UI font package.";
          };
        };
        lucida = {
          enable = lib.mkEnableOption "the Lucida Console font";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "lucida-console";
            description = "The Lucida Console font package.";
          };
        };
      };

      aerothemeplasma = {
        enable = lib.mkEnableOption "AeroThemePlasma, a set of Plasma theme packages";
        plymouth = {
          enable = lib.mkEnableOption "the PlymouthVista theme using the 7 style";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "plymouthvista";
            description = "The PlymouthVista package.";
          };
          settings = lib.mkOption {
            description = "Settings for the PlymouthVista theme. See [PlymouthVista's CONFIG.md](https://github.com/furkrn/PlymouthVista/blob/main/CONFIG.md#keys) for a full list, ones related to services are unsupported (except BootSlowdown).";
            # "Why are they unsupported anyways?" Because they edit the Plymouth script at runtime, and since it is in the Nix store that's not happening. Maybe there is a hacky solution, but for now, ehh..
            type = lib.types.submodule {
              freeformType = with lib.types; attrsOf (oneOf [ str bool int ]);
              options.BootSlowdown = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "Minimum duration of the PlymouthVista animation in seconds.";
              };
            };
          };
        };
        sddm = {
          enable = lib.mkEnableOption "the SDDM theme";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "sddm-theme-mod";
            description = "The AeroThemePlasma SDDM theme package.";
          };
        };
      };

      vistathemeplasma = {
        enable = lib.mkEnableOption "VistaThemePlasma, a set of Plasma theme packages";

        package = lib.mkOption {
          type = lib.types.package;
          default = pkg "vistathemeplasma";
          description = ''
            The main VistaThemePlasma package.  It contains the shell,
            plasmoids, theme, SDDM theme, and the `vistathemeplasma` session.
          '';
        };

        icons = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "vistathemeplasma-icons";
            description = "The Windows Vista Aero icon theme package.";
          };
        };

        cursors = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "vistathemeplasma-cursors";
            description = "The vista-aero-drop cursor theme package.";
          };
        };

        sounds = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "vistathemeplasma-sounds";
            description = "The Windows Vista sound theme package.";
          };
        };

        plymouth = {
          enable = lib.mkEnableOption "the PlymouthVista theme using the Vista style";
          package = lib.mkOption {
            type = lib.types.package;
            default = pkg "plymouthvista";
            description = "The PlymouthVista package.";
          };
          settings = aerothemeplasma.plymouth.settings;
        };

        sddm.enable = lib.mkEnableOption "the SDDM theme";
      };
    };

    linver = {
      enable = lib.mkEnableOption "the Linver application";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkg "linver";
        description = "The Linver package.";
      };
    };

    execbin = {
      enable = lib.mkEnableOption "the ExecBin application";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkg "execbin";
        description = "The ExecBin package.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pvcfg.enable -> cfg.fonts.segoe.enable;
        message = ''
          The Plymouth theme requires the Segoe font to be enabled.
          Like so: "programs.aeroshell.fonts.segoe.enable = true;"
        '';
      }
      {
        assertion = !(cfg.aerothemeplasma.plymouth.enable && cfg.vistathemeplasma.plymouth.enable);
        message = "Both Plymouth styles under programs.aeroshell are enabled. Choose one.";
      }
      {
        assertion = !(cfg.aerothemeplasma.sddm.enable && cfg.vistathemeplasma.sddm.enable);
        message = "Both SDDM themes under programs.aeroshell are enabled. Choose one.";
      }
    ];

    services.displayManager.sessionPackages =
      lib.optionals cfg.aerothemeplasma.enable [ (pkg "login-session") ]
      ++ lib.optionals cfg.vistathemeplasma.enable [ cfg.vistathemeplasma.package ];

    environment.systemPackages =
      [
        pkgs.kdePackages.qtmultimedia
        (pkg "libplasma")
        (pkg "plasma-workspace")
      ]
      ++ map pkg [
        "dimscreenaero"
        "fadingpopupsaero"
        "flip3d"
        "loginaero"
        "smod"
        "smodpeekeffect"
        "kwin-shared-data"
        "smodpeekscript"
        "squashaero"
        "thumbnail-aero"
        "thumbnails"
        "kcmloader"
        "libaeroshellutils"
        "libshowdesktop"
        "libtaskmanager"
        "aeroglassblur"
        "aeroglide"
        "launchfeedback"
        "smodglow"
        "smodsnap"
      ]
      ++ lib.optionals cfg.aerothemeplasma.enable (
        map pkg [
          "cursors"
          "icons"
          "sounds"
          "atpootb"
          "authui7"
          "color-scheme"
          "kvantum-windows7aero"
          "layout-template"
          "seven-black"
          "shell"
          "battery"
          "desktopcontainment"
          "digitalclocklite"
          "keyboardlayout"
          "networkmanagement"
          "notifications"
          "panel"
          "sevenstart"
          "seventasks"
          "systemtray"
          "volume"
          "win7showdesktop"
        ]
      )
      ++ lib.optionals cfg.vistathemeplasma.enable [
        cfg.vistathemeplasma.package
        cfg.vistathemeplasma.icons.package
        cfg.vistathemeplasma.cursors.package
        cfg.vistathemeplasma.sounds.package
      ]
      ++ lib.optionals (cfg.aerothemeplasma.enable || cfg.vistathemeplasma.enable) [
        pkgs.kdePackages.qtstyleplugin-kvantum
      ]
      ++ lib.optionals cfg.aerothemeplasma.sddm.enable [ cfg.aerothemeplasma.sddm.package ]
      ++ lib.optionals config.programs.linver.enable [ config.programs.linver.package ]
      ++ lib.optionals config.programs.execbin.enable [ config.programs.execbin.package ];

    # backward compat for users of "programs.aeroshell.fonts.enable"
    programs.aeroshell.fonts = lib.mkIf cfg.fonts.enable {
      segoe.enable = lib.mkDefault true;
      lucida.enable = lib.mkDefault true;
    };

    fonts.packages =
      lib.optionals cfg.fonts.segoe.enable [ cfg.fonts.segoe.package ]
      ++ lib.optionals cfg.fonts.lucida.enable [ cfg.fonts.lucida.package ];

    systemd.packages = lib.optionals cfg.polkit.enable [ cfg.polkit.package ];

    boot.plymouth = lib.mkIf pvcfg.enable {
      theme = "PlymouthVista";
      themePackages = [ (pvcfg.package.override { settings = pvcfg.settings; }) ];
    };
    # https://github.com/furkrn/PlymouthVista/blob/cc6592a29387462d003c2c95cb9cb5df3fea851f/systemd/slowdown/plymouth-vista-slow-boot-animation.service
    # https://wiki.archlinux.org/title/Plymouth#Slow_down_boot_to_show_the_full_animation
    systemd.services.plymouth-vista-slow-boot-animation = lib.mkIf (pvcfg.settings.BootSlowdown > 0) {
      description = "Waits for Plymouth animation to finish";
      wantedBy = [ "multi-user.target" ];
      after = [ "plymouth-start.service" ];
      before = [ "plymouth-quit.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.coreutils "sleep"} ${lib.toString pvcfg.settings.BootSlowdown}";
      };
    };
    programs.aeroshell.aerothemeplasma.plymouth.settings = {
      AuthuiStyle = "7";
      UseLegacyBootScreen = false;
      UseShadow = lib.mkDefault true;
    };
    programs.aeroshell.vistathemeplasma.plymouth.settings = {
      AuthuiStyle = "vista";
      UseLegacyBootScreen = false;
      UseShadow = lib.mkDefault true;
    };

    services.displayManager.sddm = lib.mkIf (cfg.aerothemeplasma.sddm.enable || cfg.vistathemeplasma.sddm.enable) {
      theme = if cfg.vistathemeplasma.sddm.enable then "vista-theme-mod" else "sddm-theme-mod";
      extraPackages = [ pkgs.kdePackages.kitemmodels ];
      settings = {
        Theme = {
          CursorTheme = if cfg.vistathemeplasma.sddm.enable then "vista-aero-drop" else "aero-drop";
          CursorSize = 30;
          Font = lib.mkIf cfg.fonts.segoe.enable "Segoe UI";
        };
      };
    };
  };
}
