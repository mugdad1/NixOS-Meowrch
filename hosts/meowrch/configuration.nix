{
  config,
  pkgs,
  inputs,
  lib,
  meowrchUser,
  meowrchHostname,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                         Module Imports                                    ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  # Imports are conditionally loaded based on file existence. Hardware configuration
  # is auto-detected; if missing, a fallback ext4 root filesystem is provided.
  # User-specific packages and features can be defined in optional local files.

  imports =
    let
      hardwareConfigPath = lib.findFirst (path: lib.pathExists path) null [
        ./hardware-configuration.nix
        /etc/nixos/hardware-configuration.nix
      ];
      userPackagesPath = ./user-packages.nix;
      userFeaturesPath = ./user-features.nix;
    in
    (
      [
        # Hardware and system-level modules
        ../../modules/nixos/system/audio.nix
        ../../modules/nixos/system/bluetooth.nix
        ../../modules/nixos/system/graphics.nix
        ../../modules/nixos/system/networking.nix
        ../../modules/nixos/system/security.nix
        ../../modules/nixos/system/services.nix
        ../../modules/nixos/system/fonts.nix
        ../../modules/nixos/system/features.nix

        # Desktop environment and theming
        ../../modules/nixos/desktop/sddm.nix
        ../../modules/nixos/desktop/theming.nix

        # Centralized package management
        ../../modules/nixos/packages/packages.nix
        ../../modules/nixos/packages/flatpak.nix
      ]
      ++ lib.optional (hardwareConfigPath != null) hardwareConfigPath
      ++ lib.optional (lib.pathExists userPackagesPath) userPackagesPath
      ++ lib.optional (lib.pathExists userFeaturesPath) userFeaturesPath
      # Fallback filesystem configuration if hardware-configuration.nix is missing
      ++ lib.optional (hardwareConfigPath == null) {
        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };
        boot.loader.grub.devices = [ "/dev/nodevice" ];
      }
    );

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                      NixOS Core Configuration                             ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  system.stateVersion = "25.11";

  # Nix package manager settings: enable flakes, automatic garbage collection,
  # and configure binary caches for faster builds
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      # Binary caches for faster package downloads
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    # Automatic garbage collection: keep packages from the last 7 days
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages (required for NVIDIA drivers, Steam, etc.)
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = pkg: true;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                        Boot & Kernel Configuration                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    # Kernel parameters for cleaner boot output and splash screen
    kernelParams = [
      "quiet"
      "splash"
    ];
    # Use latest kernel by default; NVIDIA module overrides to stable for driver compatibility
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    # Plymouth disabled: causes DRM lock issues and blinking cursor on some GPUs
    plymouth.enable = false;
  };

  # Enable redistributable firmware for hardware support (WiFi, Bluetooth, etc.)
  hardware.enableRedistributableFirmware = true;

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                          User Configuration                               ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  users = {
    defaultUserShell = pkgs.fish;
    users.${meowrchUser} = {
      isNormalUser = true;
      description = "Meowrch User";
      group = meowrchUser;
      initialPassword = "1";
      # Groups for hardware access, audio, gaming, and virtualization
      extraGroups = [
        "wheel" # sudo access
        "networkmanager" # network management
        "audio" # audio device access
        "video" # GPU access
        "storage" # removable storage
        "optical" # optical drives
        "scanner" # scanner devices
        "power" # power management
        "input" # input devices
        "uucp" # serial ports
        "bluetooth" # Bluetooth devices
        "render" # GPU rendering without sudo
        "libvirtd" # KVM/QEMU virtualization
      ];
      shell = pkgs.fish;
    };
    groups.${meowrchUser} = { };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                    Environment Variables & Shell Aliases                  ║
  # ╚════════════════════════════════════════════════════════════════════════════╝
  # System-wide environment variables and shell shortcuts for common operations

  environment = {
    sessionVariables = {
      # XDG Base Directory specification for application data organization
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_STATE_HOME = "$HOME/.local/state";
      XDG_CACHE_HOME = "$HOME/.cache";

      # Default applications for editing, browsing, and terminal emulation
      EDITOR = "micro";
      VISUAL = "micro";
      BROWSER = "firefox";
      TERMINAL = "kitty";

      # Wayland and Qt configuration for modern desktop environments
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "1";

      # Java configuration for window manager compatibility and GPU acceleration
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dsun.java2d.opengl=true";
    };

    shellAliases = {
      # Navigation and listing
      cls = "clear";
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";

      # Editor shortcuts
      g = "git";
      n = "nvim";
      m = "micro";

      # NixOS rebuild and update commands
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      update = "nix flake update";
      # Full system update: pull latest config, update package hashes, rebuild
      u = "cd ~/NixOS-Meowrch && git pull && ./scripts/update-pkg-hashes.sh && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
      update-pkgs = "cd ~/NixOS-Meowrch && ./scripts/update-pkg-hashes.sh && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
      # Cleanup old Nix store entries to free disk space
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
      # Quick rebuild shortcut
      b = "cd ~/NixOS-Meowrch && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
      # Russian keyboard shortcut for rebuild (same as 'b')
      "и" =
        "cd ~/NixOS-Meowrch && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
    };
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                          Program Configuration                            ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  programs = {
    # Shell configuration (detailed setup in home-manager modules)
    fish.enable = true;
    # GTK settings manager for consistent theming
    dconf.enable = true;
    # Git configuration with main as default branch
    git = {
      enable = true;
      config.init.defaultBranch = "main";
    };
    # File manager with archive and media tag support
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin # Extract/compress archives
        thunar-volman # Auto-mount removable media
        thunar-media-tags-plugin # Edit audio file metadata
      ];
    };
    # Steam gaming platform with network features
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    # Performance optimization daemon for gaming
    gamemode.enable = true;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                       System Services Configuration                       ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  services = {
    # X11 disabled: using Wayland (Hyprland) as primary display server
    xserver.enable = false;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                      Localization & Timezone Settings                     ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    # Consistent UTF-8 locale for all categories
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                    Memory Management & Virtualization                     ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Compressed RAM swap using Zstandard compression for better performance
  # Allocates 25% of system RAM as compressed swap space
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # ╔════════════════════════════════════════════════════════════════════════════╗
  # ║                        User-Level Systemd Services                        ║
  # ╚════════════════════════════════════════════════════════════════════════════╝

  # Polkit authentication agent for privilege escalation dialogs in Hyprland
  # Required for sudo operations from GUI applications
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
