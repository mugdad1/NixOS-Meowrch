{
  config,
  pkgs,
  lib,
  meowrchUser,
  ...
}:

{
  # Security Configuration
  security = {
    # Enable polkit for privilege escalation
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (
                subject.isInGroup("users")
                    && (
                        action.id == "org.freedesktop.login1.reboot" ||
                        action.id == "org.freedesktop.login1.power-off" ||
                        action.id == "org.freedesktop.login1.suspend" ||
                        action.id == "org.freedesktop.login1.hibernate"
                    )
                )
            {
                return polkit.Result.YES;
            }
        });

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.NetworkManager.settings.modify.system" &&
                subject.isInGroup("networkmanager")) {
                return polkit.Result.YES;
            }
        });

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
                subject.isInGroup("users")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    # RTKit for real-time scheduling
    rtkit.enable = true;

    # PAM configuration
    pam = {
      loginLimits = [
        {
          domain = "@users";
          type = "soft";
          item = "nofile";
          value = "65536";
        }
        {
          domain = "@users";
          type = "hard";
          item = "nofile";
          value = "65536";
        }
        {
          domain = "@audio";
          type = "-";
          item = "rtprio";
          value = "99";
        }
        {
          domain = "@audio";
          type = "-";
          item = "memlock";
          value = "unlimited";
        }
        {
          domain = "@video";
          type = "-";
          item = "rtprio";
          value = "99";
        }
      ];

      services = {
        sddm.enableGnomeKeyring = true;
        su.requireWheel = true;
      };
    };

    # Sudo configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = false;

      extraRules = [
        {
          commands = [
            {
              command = "${pkgs.systemd}/bin/systemctl suspend";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl reboot";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl poweroff";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl restart bluetooth";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl restart NetworkManager";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.brightnessctl}/bin/brightnessctl";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
        {
          commands = [
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild boot";
              options = [ "NOPASSWD" ];
            }
          ];
          groups = [ "wheel" ];
        }
        {
          users = [ meowrchUser ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      extraConfig = ''
        Defaults timestamp_timeout=30
        Defaults insults
        Defaults lecture=never
        Defaults pwfeedback
      '';
    };

    # User namespaces
    allowUserNamespaces = true;
  };

  # Security packages
  environment.systemPackages = with pkgs; [
    polkit_gnome
    gnome-keyring
    libsecret
    gnupg
    openssl
  ];

  # Kernel security parameters
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.printk" = "3 3 3 3";
    "kernel.dmesg_restrict" = 1;
    "kernel.randomize_va_space" = 2;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_userns_clone" = 1;
    "net.core.bpf_jit_harden" = 2;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
    "fs.protected_hardlinks" = 1;
    "fs.protected_symlinks" = 1;
    "fs.protected_fifos" = 2;
    "fs.protected_regular" = 2;
    "fs.suid_dumpable" = 0;
  };

  # Blacklist kernel modules
  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
    "freevxfs"
    "jffs2"
    "hfs"
    "hfsplus"
    "udf"
    "firewire-core"
    "firewire-ohci"
    "firewire-sbp2"
    "thunderbolt"
  ];

  # Services for security
  services = {
    gnome.gnome-keyring.enable = true;
    udisks2.enable = true;
  };

  # SystemD security environment
  environment.sessionVariables = {
    MALLOC_CHECK_ = "2";
    MALLOC_PERTURB_ = "1";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  # File permissions
  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
    "d /var/tmp 1777 root root - -"
    "d /home 0755 root root - -"
    "z /etc/shadow 0600 root root - -"
    "z /etc/passwd 0644 root root - -"
    "z /etc/group 0644 root root - -"
  ];
}
