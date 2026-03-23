{
  config,
  pkgs,
  lib,
  ...
}:

let
  home = config.home.homeDirectory;
in
{
  gtk = {
    enable = true;

    theme = {
      name = lib.mkDefault "pawlette-catppuccin-mocha";
      package = lib.mkDefault pkgs.meowrch-themes;
    };

    iconTheme = {
      name = lib.mkDefault "Papirus-Dark";
      package = lib.mkDefault pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = lib.mkForce "Bibata-Modern-Classic";
      package = lib.mkForce pkgs.bibata-cursors;
      size = lib.mkForce 24;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk2 = {
      configLocation = lib.mkForce "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
        gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
        gtk-button-images = 1
        gtk-menu-images = 1
        gtk-enable-event-sounds = 0
        gtk-enable-input-feedback-sounds = 0
        gtk-xft-antialias = 1
        gtk-xft-hinting = 1
        gtk-xft-hintstyle = "hintfull"
        gtk-xft-rgba = "rgb"
      '';
    };

    gtk3 = {
      bookmarks = [
        "file://${home}/Documents"
        "file://${home}/Downloads"
        "file://${home}/Music"
        "file://${home}/Pictures"
        "file://${home}/Videos"
      ];

      extraConfig = {
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH_HORIZ";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_LARGE_TOOLBAR";
        gtk-button-images = true;
        gtk-menu-images = true;
        gtk-enable-event-sounds = false;
        gtk-enable-input-feedback-sounds = false;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
        gtk-xft-rgba = "rgb";
        gtk-decoration-layout = "appmenu:minimize,maximize,close";
      };

      extraCss = ''
        decoration {
          border-radius: 12px;
          margin: 4px;
        }

        button {
          border-radius: 8px;
          transition: all 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        entry {
          border-radius: 8px;
        }

        scrollbar slider {
          border-radius: 10px;
          min-width: 6px;
          min-height: 6px;
        }

        menu {
          border-radius: 8px;
        }

        tooltip {
          border-radius: 8px;
        }
      '';
    };

    gtk4 = {
      extraConfig = {
        gtk-decoration-layout = "appmenu:minimize,maximize,close";
      };

      extraCss = ''
        window {
          border-radius: 12px;
        }

        headerbar {
          border-radius: 12px 12px 0 0;
        }

        button {
          border-radius: 8px;
        }

        entry {
          border-radius: 8px;
        }
      '';
    };
  };

  xdg.configFile = {
    "gtk-4.0/gtk.css".force = true;
    "gtk-4.0/settings.ini".force = true;
    "gtk-3.0/gtk.css".force = true;
    "gtk-3.0/settings.ini".force = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      font-name = "Noto Sans 11";
      document-font-name = "Noto Sans 11";
      monospace-font-name = "JetBrainsMono Nerd Font 10";
      font-antialiasing = "rgba";
      font-hinting = "slight";
      enable-animations = true;
      gtk-enable-primary-paste = false;
      locate-pointer = true;
      show-battery-percentage = true;
      clock-show-weekday = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Noto Sans Bold 11";
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = false;
      input-feedback-sounds = false;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = 4000;
      night-light-schedule-automatic = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
      workspaces-only-on-primary = true;
    };
  };

  home.packages = with pkgs; [
    glib
    gsettings-desktop-schemas
    gtk3
    gtk4
    adwaita-icon-theme
    lxappearance
    nwg-look
  ];

  home.sessionVariables = {
    GDK_BACKEND = "wayland,x11";
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
    GTK2_RC_FILES = lib.mkForce "${config.home.homeDirectory}/.gtkrc-2.0";
  };
}
