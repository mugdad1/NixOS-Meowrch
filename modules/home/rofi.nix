{
  config,
  pkgs,
  lib,
  ...
}:

let
  theme = "~/.config/rofi/themes/meowrch.rasi";
  mkRofiScript = name: text: {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${text}
    '';
  };
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-file-browser
    ];
    terminal = "${pkgs.kitty}/bin/kitty";

    extraConfig = {
      modi = "drun,run,filebrowser,emoji,calc";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " Files";
      display-emoji = "󰞅 Emoji";
      display-calc = " Calc";
      drun-display-format = "{name}";
      hide-scrollbar = true;
      sidebar-mode = true;
      hover-select = true;
      me-accept-entry = "MousePrimary";
      window-format = "[{w}] ··· {t}";
      click-to-exit = true;
      max-history-size = 25;
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      normalize-match = true;
      case-sensitive = false;
      cycle = true;
      parse-known-hosts = true;
    };

    theme = lib.mkForce "meowrch";
  };

  home.file.".config/rofi/themes/meowrch.rasi".text = ''
    /**
     * Meowrch Rofi Theme - Catppuccin Mocha
     **/

    * {
      bg-col:       #1e1e2e;
      border-col:   #b4befe;
      selected-col: #b4befe;
      blue:         #89b4fa;
      fg-col:       #cdd6f4;
      fg-col2:      #f38ba8;
      grey:         #6c7086;
      font:         "JetBrainsMono Nerd Font 11";
    }

    element-text, element-icon, mode-switcher {
      background-color: inherit;
      text-color:       inherit;
    }

    window {
      height:        450px;
      width:         700px;
      border:        0px;
      border-color:  @border-col;
      background-color: @bg-col;
      border-radius: 12px;
    }

    mainbox {
      background-color: @bg-col;
    }

    inputbar {
      children:      [prompt, entry];
      background-color: @bg-col;
      border-radius: 5px;
      padding:       2px;
    }

    prompt {
      background-color: @blue;
      padding:       6px;
      text-color:    @bg-col;
      border-radius: 3px;
      margin:        20px 0px 0px 20px;
    }

    entry {
      padding:       6px;
      margin:        20px 0px 0px 10px;
      text-color:    @fg-col;
      background-color: @bg-col;
    }

    listview {
      padding:       6px 0px 0px;
      margin:        10px 0px 0px 20px;
      columns:       2;
      lines:         5;
      background-color: @bg-col;
    }

    element {
      padding:       5px;
      background-color: @bg-col;
      text-color:    @fg-col;
    }

    element-icon {
      size: 25px;
    }

    element selected {
      background-color: @selected-col;
      text-color:       @bg-col;
      border-radius:    5px;
    }

    button {
      padding:       10px;
      background-color: @bg-col;
      text-color:    @grey;
      vertical-align: 0.5;
      horizontal-align: 0.5;
    }

    button selected {
      text-color: @blue;
    }

    message {
      background-color: @bg-col;
      margin:       2px;
      padding:      2px;
      border-radius: 5px;
    }

    textbox {
      padding:       6px;
      margin:        20px 0px 0px 20px;
      text-color:    @blue;
      background-color: @bg-col;
    }
  '';

  home.file.".config/rofi/selecting.rasi".text = ''
    configuration {
      show-icons: true;
      drun-display-format: "{name}";
    }

    @import "~/.config/rofi/themes/meowrch.rasi"

    window {
      transparency: "real";
      location: center;
      fullscreen: false;
      width: 1100px;
      border-radius: 15px;
      background-color: @bg-col;
    }

    mainbox {
      spacing: 20px;
      padding: 20px;
      background-color: transparent;
      children: ["inputbar", "listview"];
    }

    inputbar {
      spacing: 10px;
      background-color: transparent;
      children: ["prompt", "entry"];
    }

    prompt {
      background-color: @selected-col;
      text-color: @bg-col;
      padding: 10px;
      border-radius: 10px;
    }

    entry {
      background-color: @bg-col;
      text-color: inherit;
      padding: 10px;
      border-radius: 10px;
      placeholder: "Search...";
    }

    listview {
      columns: 5;
      lines: 2;
      cycle: true;
      spacing: 10px;
      background-color: transparent;
    }

    element {
      spacing: 10px;
      padding: 10px;
      border-radius: 15px;
      background-color: transparent;
      text-color: @fg-col;
      orientation: vertical;
    }

    element selected {
      background-color: @selected-col;
      text-color: @bg-col;
    }

    element-icon {
      size: 180px;
    }

    element-text {
      vertical-align: 0.5;
      horizontal-align: 0.5;
    }
  '';

  # Power menu
  home.file."bin/rofi-powermenu.sh" = mkRofiScript "powermenu" ''
    options="⏻ Shutdown\n Reboot\n Lock\n⏾ Suspend\n󰗽 Logout"
    chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -theme "${theme}" -width 300 -lines 5)

    case "$chosen" in
      "⏻ Shutdown") systemctl poweroff ;;
      " Reboot") systemctl reboot ;;
      "Lock") swaylock ;;
      "⏾ Suspend") systemctl suspend ;;
      "󰗽 Logout") hyprctl dispatch exit ;;
    esac
  '';

  # Emoji picker
  home.file."bin/rofi-emoji.sh" = mkRofiScript "emoji" ''
    if command -v rofimoji &> /dev/null; then
      rofimoji --rofi-args="-theme ${theme}"
    else
      rofi -modi emoji -show emoji -theme "${theme}"
    fi
  '';

  # Clipboard manager
  home.file."bin/rofi-clipboard.sh" = mkRofiScript "clipboard" ''
    if command -v cliphist &> /dev/null; then
      cliphist list | rofi -dmenu -p "Clipboard" -theme "${theme}" | cliphist decode | wl-copy
    else
      echo "cliphist not installed" | rofi -dmenu -p "Error" -theme "${theme}"
    fi
  '';

  # WiFi manager
  home.file."bin/rofi-wifi.sh" = mkRofiScript "wifi" ''
    wifi_list=$(nmcli dev wifi list | sed 1d | awk '{print $1}' | sort -u)
    chosen=$(echo "$wifi_list" | rofi -dmenu -p "WiFi Networks" -theme "${theme}")

    [[ -z "$chosen" ]] && exit 0

    password=$(rofi -dmenu -p "Password for $chosen" -password -theme "${theme}")
    [[ -n "$password" ]] && nmcli dev wifi connect "$chosen" password "$password" && \
      notify-send "WiFi" "Connecting to $chosen"
  '';

  # Bluetooth manager
  home.file."bin/rofi-bluetooth.sh" = mkRofiScript "bluetooth" ''
    theme="${theme}"

    toggle_bt() {
      if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
        notify-send "Bluetooth" "Turned off"
      else
        bluetoothctl power on
        notify-send "Bluetooth" "Turned on"
      fi
    }

    scan_devices() {
      bluetoothctl scan on & sleep 5; bluetoothctl scan off
      devices=$(bluetoothctl devices | cut -d' ' -f3-)
      chosen=$(echo "$devices" | rofi -dmenu -p "Available devices" -theme "$theme")
      [[ -n "$chosen" ]] && bluetoothctl connect "$(bluetoothctl devices | grep "$chosen" | cut -d' ' -f2)"
    }

    show_connected() {
      connected=$(bluetoothctl devices Connected | cut -d' ' -f3-)
      echo "''${connected:-No connected devices}" | rofi -dmenu -p "Connected" -theme "$theme"
    }

    pair_device() {
      bluetoothctl scan on & sleep 5; bluetoothctl scan off
      devices=$(bluetoothctl devices | cut -d' ' -f3-)
      chosen=$(echo "$devices" | rofi -dmenu -p "Pair device" -theme "$theme")
      if [[ -n "$chosen" ]]; then
        mac=$(bluetoothctl devices | grep "$chosen" | cut -d' ' -f2)
        bluetoothctl pair "$mac" && bluetoothctl trust "$mac" && bluetoothctl connect "$mac"
      fi
    }

    options="󰂯 Toggle\n Scan\n󰂱 Connected\n Pair"
    chosen=$(echo -e "$options" | rofi -dmenu -p "Bluetooth" -theme "$theme")

    case "$chosen" in
      "󰂯 Toggle") toggle_bt ;;
      " Scan") scan_devices ;;
      "󰂱 Connected") show_connected ;;
      " Pair") pair_device ;;
    esac
  '';
}
