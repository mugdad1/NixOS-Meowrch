{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.zen-browser.homeModules.beta
  ];

  programs.zen-browser = {
    enable = true;

    # Extensions
    profiles.default.extensions.packages =
      with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
      ];

    # Search engine
    profiles.default.search = {
      force = true;
      default = "duckduckgo";
    };

    # Dark theme
    profiles.default.settings = {
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "ui.systemUsesDarkTheme" = 1;
    };

    # Strict security policies
    policies = {
      DisableAppUpdate = true;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };
  };
}
