{ config, pkgs, ... }:

let
  mkNotifyScript = name: text: {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${text}
    '';
  };

in
{
  home.packages = with pkgs; [
    dunst
    libnotify
    pamixer
    brightnessctl
    upower
    networkmanager
    bluez
  ];

  home.file.".config/dunst/.keep".text = "";

  # ============================================================================
  # NOTIFICATION SCRIPTS
  # ============================================================================

  home.file."bin/notify-volume.sh" = mkNotifyScript "volume" ''
    volume=$(pamixer --get-volume)
    mute=$(pamixer --get-mute)

    if [[ $mute == "true" ]]; then
      icon="🔇"
      text="Muted"
    elif [[ $volume -lt 30 ]]; then
      icon="🔉"
    else
      icon="🔊"
    fi

    dunstify -a "Volume" -u low -r 9991 -h int:value:$volume "$icon Volume" "''${text:-$volume%}"
  '';

  home.file."bin/notify-brightness.sh" = mkNotifyScript "brightness" ''
    brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    percentage=$((brightness * 100 / max_brightness))

    if [[ $percentage -lt 10 ]]; then
      icon="🔅"
    elif [[ $percentage -lt 30 ]]; then
      icon="🔆"
    else
      icon="☀️"
    fi

    dunstify -a "Brightness" -u low -r 9992 -h int:value:$percentage "$icon Brightness" "$percentage%"
  '';

  home.file."bin/notify-battery.sh" = mkNotifyScript "battery" ''
    battery_dev=$(upower -e | grep 'BAT')
    percentage=$(upower -i "$battery_dev" | grep percentage | awk '{print $2}' | sed 's/%//')
    status=$(upower -i "$battery_dev" | grep state | awk '{print $2}')

    case "$status" in
      charging)
        icon="🔌"; text="Charging - $percentage%"; urgency="normal" ;;
      *)
        if [[ $percentage -gt 80 ]]; then
          icon="🔋"; urgency="normal"
        elif [[ $percentage -gt 40 ]]; then
          icon="🔋"; urgency="normal"
        elif [[ $percentage -gt 20 ]]; then
          icon="🪫"; urgency="normal"
        else
          icon="🔴"; text="Critical - $percentage%"; urgency="critical"
        fi
        [[ -z $text ]] && text="$percentage%"
        ;;
    esac

    dunstify -a "Battery" -u "$urgency" -r 9993 "$icon Battery" "$text"
  '';

  home.file."bin/notify-network.sh" = mkNotifyScript "network" ''
    ssid=$(nmcli -t -f active,ssid dev wifi | egrep '^yes' | cut -d: -f2)

    if [[ -n "$ssid" ]]; then
      signal=$(nmcli -t -f active,signal dev wifi | egrep '^yes' | cut -d: -f2)
      dunstify -a "NetworkManager" -u low -r 9994 "📶 WiFi Connected" "Connected to $ssid ($signal%)"
    else
      dunstify -a "NetworkManager" -u normal -r 9994 "📵 WiFi Disconnected" "No wireless connection"
    fi
  '';

  home.file."bin/notify-bluetooth.sh" = mkNotifyScript "bluetooth" ''
    if bluetoothctl show | grep -q "Powered: yes"; then
      connected=$(bluetoothctl devices Connected | wc -l)
      if [[ $connected -gt 0 ]]; then
        devices=$(bluetoothctl devices Connected | cut -d' ' -f3- | tr '\n' ', ' | sed 's/, $//')
        dunstify -a "Bluetooth" -u low -r 9995 "󰂱 Bluetooth Connected" "Connected to: $devices"
      else
        dunstify -a "Bluetooth" -u low -r 9995 "󰂯 Bluetooth On" "No devices connected"
      fi
    else
      dunstify -a "Bluetooth" -u low -r 9995 "󰂲 Bluetooth Off" "Bluetooth is disabled"
    fi
  '';
}
