{
  config,
  pkgs,
  lib,
  inputs,
  firefox-addons,
  pkgs-unstable,
  meowrchUser,
  meowrchHostname,
  ...
}:
{
  imports = [
    ../../modules/home/rofi.nix
    ../../modules/home/gtk.nix
    ../../modules/home/fish.nix
    ../../modules/home/starship.nix
    ../../modules/home/zen-browser.nix
  ];

  # Basic user configuration
  home.username = lib.mkForce meowrchUser;
  home.homeDirectory = lib.mkForce "/home/${meowrchUser}";
  home.stateVersion = "25.11";

  # Cursor theme with support for Wayland (Hyprland), X11, and GTK applications
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
    hyprcursor.size = 24;
  };

  # System packages and CLI tools
  home.packages = with pkgs; [
    meowrch-scripts
    meowrch-themes
    mewline
    fabric-cli
    pawlette
    meowrch-tools
    pkgs-unstable.gemini-cli
  ];

  # User-level systemd services for background processes
  systemd.user.services = {
    # Dynamic island-style status bar for Hyprland
    mewline = {
      Unit = {
        Description = "Mewline Dynamic Island Status Bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.mewline}/bin/mewline";
        Restart = "on-failure";
        RestartSec = "3";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Automatically set wallpaper on login if change-wallpaper.sh script exists
    wallpaper-changer = {
      Unit = {
        Description = "Random wallpaper changer";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'test -x $HOME/.config/meowrch/bin/change-wallpaper.sh && $HOME/.config/meowrch/bin/change-wallpaper.sh'";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # Python version manager for project-specific Python environments
  programs.pyenv = {
    enable = true;
    enableFishIntegration = true;
  };

  # Environment variables for Wayland, development, and default applications
  home.sessionVariables = {
    # Enable Wayland support across applications
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";

    # Custom binary directory for meowrch scripts
    XDG_BIN_HOME = "$HOME/.config/meowrch/bin";

    # Default applications for editing, browsing, and terminal
    EDITOR = "zed";
    VISUAL = "zed";
    BROWSER = "firefox";
    TERMINAL = "kitty";

    # Allow unfree packages in nixpkgs
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  # Catppuccin Mocha theme for system-wide consistency
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";
  };

  # Firefox configuration with Wayland support, hardware acceleration, and essential extensions
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      extensions = {
        force = true;
        packages = with firefox-addons; [
          ublock-origin # Ad and tracker blocking
          bitwarden # Password manager
        ];
      };
      settings = {
        # GPU acceleration for video playback and rendering
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;

        # Enforce dark theme from system settings
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;

        # Use XDG portals for better Wayland integration
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;

        # Allow cookies for Google login persistence
        "network.cookie.cookieBehavior" = 0;
      };
    };
  };

  # Zed editor configuration with custom keybindings and theme
  # Settings file is symlinked to cache for dynamic updates via theme script
  home.file.".config/zed/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "/home/${meowrchUser}/.cache/meowrch/zed/settings.json";
  };

  # Vim-like keybindings for Zed editor
  home.file.".config/zed/keymap.json".text = builtins.toJSON [
    {
      context = "Editor";
      bindings = {
        "ctrl-/" = "editor::ToggleComments";
        "ctrl-d" = "editor::SelectNext";
        "ctrl-shift-k" = "editor::DeleteLine";
        "ctrl-shift-d" = "editor::DuplicateLineDown";
        "ctrl-p" = "file_finder::Toggle";
        "ctrl-shift-p" = "command_palette::Toggle";
        "ctrl-shift-f" = "search::ToggleReplace";
        "ctrl-`" = "terminal_panel::ToggleFocus";
      };
    }
  ];

  # Theme placeholder files for dynamic theme switching via meowrch scripts
  # These are overwritten at runtime by the theme-changer service
  home.file.".cache/meowrch/hypr/theme.conf".text = "# Initial theme placeholder\n";
  home.file.".cache/meowrch/kitty/theme.conf".text = "# Initial theme placeholder\n";
  home.file.".cache/meowrch/waybar/theme.css".text = "/* Initial theme placeholder */\n";

  # Default Zed settings (symlinked, can be modified at runtime)
  home.file.".cache/meowrch/zed/settings.json".text = builtins.toJSON {
    theme = "One Dark";
    theme_mode = "dark";
    ui_font_size = 14;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    ui_font_family = "JetBrainsMono Nerd Font";
    tab_size = 2;
    soft_wrap = "editor_width";
    git.git_gutter = "tracked_files";
    # AI assistant integration with OpenRouter and DeepSeek R1
    assistant = {
      enabled = true;
      version = "2";
      default_model = {
        provider = "openrouter";
        model = "deepseek/deepseek-r1-0528";
      };
    };
  };

  # Hyprland window manager configuration
  home.file.".config/hypr" = {
    source = ../../config/hypr;
    recursive = true;
  };

  # Kitty terminal emulator configuration
  home.file.".config/kitty" = {
    source = ../../config/kitty;
    recursive = true;
  };

  # System information display tool configuration
  home.file.".config/fastfetch" = {
    source = ../../config/fastfetch;
    recursive = true;
  };

  # System resource monitor configuration
  home.file.".config/btop" = {
    source = ../../config/btop;
    recursive = true;
  };

  # Custom meowrch configuration and utilities
  home.file.".config/meowrch" = {
    source = ../../config/meowrch;
    recursive = true;
  };

  # Custom shell scripts and utilities (symlinked to PATH via XDG_BIN_HOME)
  home.file.".config/meowrch/bin" = {
    source = ../../scripts;
    recursive = true;
  };

  # Qt5 theme configuration for Catppuccin Mocha (used by Ark, VLC, etc.)
  home.file.".config/qt5ct" = {
    source = ../../config/qt5ct;
    recursive = true;
  };

  # Qt6 theme configuration for Catppuccin Mocha
  home.file.".config/qt6ct" = {
    source = ../../config/qt6ct;
    recursive = true;
  };

  # Wallpaper collection sourced from meowrch-themes package
  home.file.".config/meowrch/wallpapers" = {
    source = "${pkgs.meowrch-themes}/share/wallpapers/meowrch";
    recursive = true;
  };

  # XDG directories for user files (Desktop, Documents, Downloads, etc.)
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
      templates = "$HOME/Templates";
      publicShare = "$HOME/Public";
    };

    # Default applications for opening different file types
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Web browsers and HTTP(S)
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];

        # Image viewers
        "image/jpeg" = [ "feh.desktop" ];
        "image/png" = [ "feh.desktop" ];
        "image/gif" = [ "feh.desktop" ];

        # Video and audio players
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
        "audio/mpeg" = [ "mpv.desktop" ];
        "audio/flac" = [ "mpv.desktop" ];
      };
    };
  };

  # Enable Home Manager to manage itself
  programs.home-manager.enable = true;
}
