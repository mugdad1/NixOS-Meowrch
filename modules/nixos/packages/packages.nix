{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        TERMINAL & SHELL                                   ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    kitty
    fish
    starship
    fastfetch

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        FILE MANAGERS                                      ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    nemo
    ranger
    zenity
    filen-desktop
    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        WAYLAND / HYPRLAND                                 ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    xwayland
    wl-clipboard
    cliphist
    wl-clip-persist
    grim
    slurp
    swww
    rofi
    rofimoji
    waybar
    swaylock-effects
    hyprlock
    pamixer
    playerctl
    udiskie
    polkit_gnome
    kdePackages.polkit-kde-agent-1
    hyprsunset
    brightnessctl
    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        WEB & NETWORKING                                   ║
    # ╚════════════════════════════════════════════════════════════════════════════╝

    wget
    curl
    networkmanagerapplet
    tor-browser

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        DEVELOPMENT                                        ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    zed-editor
    nil
    nixd
    alejandra
    git
    gcc
    clang
    nodejs
    ripgrep
    cmake
    gnumake
    (python3.withPackages (
      ps: with ps; [
        pyyaml
        pillow
      ]
    ))
    python3Packages.pip

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        MULTIMEDIA                                         ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    mpv
    obs-studio
    feh
    ffmpeg
    imagemagick

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        GRAPHICS LIBRARIES                                 ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    mesa
    libGL
    libva
    libvdpau
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
    dxvk

    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        SYSTEM UTILITIES                                   ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    btop
    gnome-disk-utility
    unzip
    unrar
    kdePackages.ark
    blueman
    bluez
    bluez-tools
    openssh
    usbutils
    pciutils
    lshw
    dmidecode
    tree
    file
    which
    upower
    xdg-utils
    gnome-keyring
    libsecret
    gcr
    gnome-calculator
    fuse2
    fuse2fs
    appimage-run
    # ╔════════════════════════════════════════════════════════════════════════════╗
    # ║                        THEMES & ICONS                                     ║
    # ╚════════════════════════════════════════════════════════════════════════════╝
    catppuccin-gtk
    catppuccin-qt5ct
    gnome-themes-extra
    gsettings-desktop-schemas
    pawlette
    meowrch-themes
    meowrch-settings
    hotkeyhub
    meowrch-tools
    themix-gui
    sassc
    gtk-engine-murrine
    dconf-editor
  ];
}
