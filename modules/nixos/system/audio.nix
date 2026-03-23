{
  config,
  pkgs,
  lib,
  ...
}:
{
  # PipeWire audio stack with low-latency defaults
  # Bluetooth audio is configured separately in bluetooth.nix
  # Safe to import on any host

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  services.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    pavucontrol
    pamixer
    playerctl
    wireplumber
  ];

  # Audio device permissions
  services.udev.extraRules = ''
    SUBSYSTEM=="sound", GROUP="audio", MODE="0664"
    KERNEL=="controlC[0-9]*", GROUP="audio", MODE="0664"
  '';

  # Low-latency tuning (32 samples @ 48kHz)
  services.pipewire.extraConfig = {
    pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 32;
        default.clock.min-quantum = 32;
        default.clock.max-quantum = 32;
      };
    };
    pipewire-pulse."92-low-latency" = {
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "32/48000";
            pulse.default.req = "32/48000";
            pulse.max.req = "32/48000";
            pulse.min.quantum = "32/48000";
            pulse.max.quantum = "32/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "32/48000";
        resample.quality = 1;
      };
    };
  };

  # Kernel audio modules
  boot.kernelModules = [
    "snd-seq"
    "snd-rawmidi"
  ];

  # HDA power management (prevent codec wake delay/pop)
  boot.kernelParams = [
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  # Real-time & memory locking for audio group
  security.pam.loginLimits = [
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@audio";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
  ];

  environment.sessionVariables.PIPEWIRE_LATENCY = "32/48000";
}
