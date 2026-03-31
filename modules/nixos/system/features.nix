{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.meowrch.features;
in
{
  options.meowrch.features = {
    steam = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Steam gaming platform";
    };

    gamemode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GameMode performance optimization";
    };

    mangohud = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MangoHUD overlay (FPS counter, monitoring)";
    };

    telegram = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Telegram Desktop";
    };

    discord = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Discord";
    };

    obsidian = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Obsidian note-taking application";
    };

    libreoffice = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable LibreOffice office suite";
    };

    thunderbird = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Thunderbird email client";
    };

    docker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker container runtime";
    };

    vscode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Visual Studio Code (proprietary)";
    };

    zed = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zed editor (Rust-based)";
    };

    flatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Flatpak runtime";
    };

    wine = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Wine (64-bit) for Windows applications";
    };
  };

  config = {
    # Program configurations
    programs.steam.enable = cfg.steam;
    programs.gamemode.enable = cfg.gamemode;
    virtualisation.docker.enable = cfg.docker;
    services.flatpak.enable = cfg.flatpak;

    # System packages
    environment.systemPackages =
      with pkgs;
      lib.optionals cfg.mangohud [ mangohud ]
      ++ lib.optionals cfg.telegram [ telegram-desktop ]
      ++ lib.optionals cfg.discord [ discord ]
      ++ lib.optionals cfg.obsidian [ obsidian ]
      ++ lib.optionals cfg.libreoffice [ libreoffice-fresh ]
      ++ lib.optionals cfg.thunderbird [ thunderbird ]
      ++ lib.optionals cfg.vscode [ vscode ]
      ++ lib.optionals cfg.zed [ zed-editor ]
      ++ lib.optionals cfg.wine [ wine-wine64 ];
  };
}
