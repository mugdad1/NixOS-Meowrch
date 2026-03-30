
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ============================================
  # Boot Configuration
  # ============================================
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [
    "kvm-intel"
    "drm"
    "drm_kms_helper"
  ];
  boot.extraModulePackages = [ ];

  boot.kernelParams = [
    "amdgpu.gpu_recovery=1"
    "amdgpu.dc=1"
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/b6e7a594-3b83-403e-943b-38322084da0e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5E76-84DA";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];
# ============================================
  # Graphics / GPU (AMD RX570 - Polaris)
  # ============================================
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
    ];
    extraPackages32 = with pkgs.driversi686Linux; [
      mesa
    ];
  };

  # OpenCL support for kdenlive (RX570 is Polaris - requires pre-Vega support)
  hardware.amdgpu.opencl.enable = true;

  services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

  # ============================================
  # Scanner Support
  # ============================================
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      hplip
      sane-airscan
    ];
  };

  # ============================================
  # GPU Control Daemon (LACT)
  # ============================================
  services.lact.enable = true;

  # ============================================
  # System Packages (Graphics, Video & Diagnostics)
  # ============================================
  environment.systemPackages = with pkgs; [
    # GPU monitoring & tools
    vulkan-tools
    gpu-viewer
    glmark2
    radeontop
    rocmPackages.rocm-core
    rocmPackages.rocminfo
    rocmPackages.amdsmi
    amdgpu_top
    lact
    clinfo
    mesa-demos
    # Video editing
    ffmpeg-full
    x264
    x265

    # Wayland utilities
    wlr-randr
    wayland-utils

    # Development libraries
    libGL
    libGLU
    wayland
    wayland-protocols

    # Hyprland / wlroots helpers
    seatd
    libinput
    libxkbcommon
    xorg.libxcb
    pipewire
    libgbm
  ];

  # ============================================
  # Environment Variables (AMD GPU - CRITICAL for Polaris)
  # ============================================
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1"; # REQUIRED for RX570 OpenCL support
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    AMD_VULKAN_ICD = "RADV";
  };

  # ============================================
  # Temporary Filesystems
  # ============================================
  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root 10d"
    "d /tmp/.ICE-unix 1777 root root 10d"
  ];

  # ============================================
  # Platform & Firmware
  # ============================================
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
