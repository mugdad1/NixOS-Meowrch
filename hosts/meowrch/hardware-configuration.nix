{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  ############################################
  # Boot configuration
  ############################################
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [
    "kvm-intel"
    "drm"
    "drm_kms_helper"
  ];
  boot.extraModulePackages = [ ];

  ############################################
  # Intel kernel tuning
  ############################################
  boot.kernelParams = [
    "i915.enable_psr=1"
    "i915.fastboot=1"
  ];

  ############################################
  # Increase virtual memory map count (large games / proton)
  ############################################
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  ############################################
  # Filesystems
  ############################################
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/65a8bb73-9530-4e86-a342-6d3cffdb1784";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BD67-31BC";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  ############################################
  # X11 video driver (if X is enabled)
  ############################################
  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "modesetting" ];

  ############################################
  # Modern graphics stack with 32-bit support
  ############################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      libva
      libva-utils
      libdrm
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      intel-media-driver # iHD driver (Broadwell+, recommended)
      intel-vaapi-driver # i965 driver (older GPUs fallback)
      libva-vdpau-driver # VDPAU backend for VA-API
      libvdpau-va-gl # VDPAU via VA-API
      vpl-gpu-rt # Intel oneVPL GPU runtime
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
    ];
  };

  ############################################
  # Environment variables for Intel VA-API
  ############################################
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Use intel-media-driver (Broadwell+)
    # For older GPUs, change to "i965"
  };

  ############################################
  # Scanner support (hardware capability)
  ############################################
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplip
      sane-airscan
    ];
  };

  ############################################
  # Common userland tooling / diagnostics
  ############################################
  environment.systemPackages = with pkgs; [
    # Capability / info (glxinfo is part of mesa-demos)
    vulkan-tools
    mesa-demos
    gpu-viewer
    glmark2

    # Performance / overlays
    mangohud
    goverlay

    # Wayland utilities
    wlr-randr
    wayland-utils

    # Debugging & tracing
    renderdoc
    apitrace

    # Development libs
    libGL
    libGLU
    wayland
    wayland-protocols

    # Hyprland / wlroots helper libs
    seatd
    libinput
    libxkbcommon
    xorg.libxcb
    pipewire
    libgbm

    # Intel-specific monitoring tools
    intel-gpu-tools
  ];

  ############################################
  # Common runtime filesystem expectations
  ############################################
  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root 10d"
    "d /tmp/.ICE-unix 1777 root root 10d"
  ];

  ############################################
  # Hardware configuration
  ############################################
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
