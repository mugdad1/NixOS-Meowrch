{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        JustWorksRepairing = "always";
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
        ReconnectAttempts = 7;
        ReconnectIntervals = "1, 2, 4, 8, 16, 32, 64";
      };
    };
  };

  services.blueman.enable = true;
  services.dbus.packages = with pkgs; [
    bluez
    blueman
  ];

  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];

  boot.kernelModules = [
    "bluetooth"
    "btusb"
    "rfcomm"
    "bnep"
  ];

  services.udev.extraRules = ''
    KERNEL=="rfkill", SUBSYSTEM=="rfkill", ATTR{type}=="bluetooth", TAG+="uaccess"
    SUBSYSTEM=="bluetooth", TAG+="uaccess"
    KERNEL=="hci[0-9]*", TAG+="uaccess"
  '';

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.codecs"] = "[ sbc sbc_xq aac ldac aptx aptx_hd ]",
      }
    '')
  ];
}
