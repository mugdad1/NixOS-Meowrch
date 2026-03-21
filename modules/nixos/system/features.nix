# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                    Optional Features Configuration Module                 ║
# ╚════════════════════════════════════════════════════════════════════════════╝
# This module provides a centralized way to enable/disable optional software
# features across the system. Define feature flags in your configuration, then
# enable them selectively without cluttering the main NixOS configuration.
#
# Usage in your configuration:
#   meowrch.features = {
#     steam = true;
#     discord = true;
#     docker = true;
#   };

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
  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Feature Option Definitions                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  options.meowrch.features = {
    # ──────────────────────────────────────────────────────────────────────────
    # Gaming & Performance
    # ──────────────────────────────────────────────────────────────────────────
    steam = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Steam gaming platform with network features";
    };

    gamemode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable GameMode daemon for automatic performance optimization during gaming";
    };

    mangohud = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MangoHUD overlay for FPS counter, CPU/GPU monitoring, and performance metrics";
    };

    # ──────────────────────────────────────────────────────────────────────────
    # Communication & Productivity
    # ──────────────────────────────────────────────────────────────────────────
    telegram = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Telegram Desktop messaging application";
    };

    discord = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Discord voice/text chat application";
    };

    obsidian = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Obsidian note-taking and knowledge management application";
    };

    # ──────────────────────────────────────────────────────────────────────────
    # Office & Documents
    # ──────────────────────────────────────────────────────────────────────────
    libreoffice = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable LibreOffice office suite (Writer, Calc, Impress)";
    };

    thunderbird = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Thunderbird email client and calendar application";
    };

    # ──────────────────────────────────────────────────────────────────────────
    # Development & Containerization
    # ──────────────────────────────────────────────────────────────────────────
    docker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker container runtime and CLI tools";
    };

    vscode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Visual Studio Code editor (proprietary build with telemetry)";
    };

    zed = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Zed editor (high-performance Rust-based editor)";
    };

    # ──────────────────────────────────────────────────────────────────────────
    # System & Compatibility
    # ──────────────────────────────────────────────────────────────────────────
    flatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Flatpak runtime for sandboxed application distribution";
    };

    wine = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Wine (64-bit) for running Windows applications on Linux";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                      Feature Implementation & Activation                  ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  config = {
    # ──────────────────────────────────────────────────────────────────────────
    # Program-level configurations (enable/disable entire subsystems)
    # ──────────────────────────────────────────────────────────────────────────
    programs.steam.enable = lib.mkForce cfg.steam;
    programs.gamemode.enable = lib.mkForce cfg.gamemode;
    virtualisation.docker.enable = lib.mkForce cfg.docker;
    services.flatpak.enable = lib.mkForce cfg.flatpak;

    # ──────────────────────────────────────────────────────────────────────────
    # System packages (conditionally installed based on feature flags)
    # Use mkIf to prevent null entries in the package list
    # ──────────────────────────────────────────────────────────────────────────
    environment.systemPackages = with pkgs; [
      # Gaming & Performance monitoring
      (lib.mkIf cfg.mangohud mangohud)

      # Communication & Productivity
      (lib.mkIf cfg.telegram telegram-desktop)
      (lib.mkIf cfg.discord discord)
      (lib.mkIf cfg.obsidian obsidian)

      # Office & Documents
      (lib.mkIf cfg.libreoffice libreoffice-fresh)
      (lib.mkIf cfg.thunderbird thunderbird)

      # Development & Editors
      (lib.mkIf cfg.vscode vscode)
      (lib.mkIf cfg.zed zed-editor)

      # System & Compatibility
      (lib.mkIf cfg.wine wine-wow64)
    ];
  };
}
