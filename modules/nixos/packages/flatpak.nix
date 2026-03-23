{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment.systemPackages = with pkgs; [
    flatpak
  ];

  systemd.services.flatpak-flathub = {
    description = "Add Flathub repository";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = "flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.Flatpak.app-install" ||
             action.id == "org.freedesktop.Flatpak.runtime-install" ||
             action.id == "org.freedesktop.Flatpak.app-uninstall" ||
             action.id == "org.freedesktop.Flatpak.runtime-uninstall" ||
             action.id == "org.freedesktop.Flatpak.modify-repo") &&
            subject.active == true && subject.local == true &&
            subject.isInGroup("wheel")) {
            return polkit.Result.YES;
        }
        return polkit.Result.NOT_HANDLED;
    });
  '';
}
