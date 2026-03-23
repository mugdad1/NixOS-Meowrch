{
  config,
  pkgs,
  lib,
  ...
}:
{
  fonts = {
    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel.rgba = "rgb";
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [
          "Inter"
          "Noto Sans"
        ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    packages = with pkgs; [
      # Nerd fonts (programming)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.iosevka

      # System fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      # Programming fonts
      jetbrains-mono
      fira-code
      source-code-pro

      # Interface fonts
      inter
      roboto
      roboto-mono

      # Icons
      font-awesome
    ];

    enableDefaultPackages = false;
  };

  environment.systemPackages = with pkgs; [
    gucharmap
  ];
}
