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

  # Keep i915 in initramfs (kernel driver for Iris Xe)
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [
    "kvm-intel"
    "drm"
    "drm_kms_helper"
  ];
  boot.extraModulePackages = [ ];

  # i915 GuC + runtime/power params
  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.fastboot=1"
    "i915.enable_rc6=1"
    "i915.enable_dc=1"
    "i915.enable_psr=1"
  ];

  ############################################
  # vm maps
  ############################################
  boot.kernel.sysctl = {
    "vm.max_map_count" = 262144;
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
  # Graphics stack with 32-bit support
  ############################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = lib.concatLists [
      (with pkgs; [
        mesa
        libva
        libva-utils
        libdrm
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
        vulkan-extension-layer
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
        vpl-gpu-rt
      ])
      (if builtins.hasAttr "vulkan-intel" pkgs then [ pkgs.vulkan-intel ] else [ ])
    ];

    # Avoid pulling a second mesa copy. Leave empty unless you need specific 32-bit libs.
    extraPackages32 = [ ];
  };

  ############################################
  # Environment variables to prefer iris userspace driver
  ############################################
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    VAAPI_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
  };

  ############################################
  # Scanner support
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
    linux-firmware
    microcode-intel
    vulkan-tools
    glmark2

    # Mesa demos (glxinfo) and VA-API utils (vainfo)
    mesa-demos
    libva-utils

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
  # Runtime tmpfiles
  ############################################
  systemd.tmpfiles.rules = [
    "d /tmp/.X11-unix 1777 root root 10d"
    "d /tmp/.ICE-unix 1777 root root 10d"
  ];

  ############################################
  # Hardware configuration
  ############################################
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
