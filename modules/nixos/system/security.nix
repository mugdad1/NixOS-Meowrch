{
  config,
  pkgs,
  lib,
  meowrchUser,
  ...
}:

{
  # ============================================================================
  # SECURITY CONFIGURATION
  # ============================================================================

  security = {
    # Privilege Escalation with polkit
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (subject.isInGroup("users") && (
                action.id == "org.freedesktop.login1.reboot" ||
                action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                action.id == "org.freedesktop.login1.power-off" ||
                action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
                action.id == "org.freedesktop.login1.suspend" ||
                action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
                action.id == "org.freedesktop.login1.hibernate" ||
                action.id == "org.freedesktop.login1.hibernate-multiple-sessions"
            )) {
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

        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.login1.set-brightness" &&
                subject.isInGroup("video")) {
                return polkit.Result.YES;
            }
        });
      '';
    };

    # Real-time scheduling for audio/video
    rtkit.enable = true;

    # PAM Configuration
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
        login.enableGnomeKeyring = true;
        passwd.enableGnomeKeyring = true;
        sddm.enableGnomeKeyring = true;
      };
    };

    # Sudo Configuration
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      execWheelOnly = false;

      extraRules = [
        {
          groups = [ "wheel" ];
          commands = [
            {
              command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
              options = [ "NOPASSWD" ];
            }
            {
              command = "${pkgs.systemd}/bin/systemctl";
              options = [ "NOPASSWD" ];
            }
          ];
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
        Defaults use_pty
      '';
    };

    # User namespaces (needed for containers, development)
    allowUserNamespaces = true;
  };

  # ============================================================================
  # KERNEL HARDENING
  # ============================================================================

  boot = {
    kernel.sysctl = {
      # Performance vs. security
      "kernel.nmi_watchdog" = 0;

      # Pointer and information disclosure prevention
      "kernel.kptr_restrict" = 2;
      "kernel.printk" = "3 3 3 3";
      "kernel.dmesg_restrict" = 1;

      # Address Space Layout Randomization
      "kernel.randomize_va_space" = 2;

      # Process tracing restrictions
      "kernel.yama.ptrace_scope" = 1;

      # Kexec restrictions
      "kernel.kexec_load_disabled" = 1;

      # Allow unprivileged user namespaces for development
      "kernel.unprivileged_userns_clone" = 1;

      # Network security (complementary to network config)
      "net.core.bpf_jit_harden" = 2;

      # Memory protection
      "vm.mmap_rnd_bits" = 32;
      "vm.mmap_rnd_compat_bits" = 16;

      # Filesystem protections
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;

      # Restrict kernel module loading after boot (dev-friendly: keep at 0)
      "kernel.modules_disabled" = 0;
    };

    # Blacklisted kernel modules
    blacklistedKernelModules = [
      # Uncommon network protocols
      "dccp"
      "sctp"
      "rds"
      "tipc"

      # Rare filesystems (squashfs NOT disabled — required by NixOS)
      "freevxfs"
      "jffs2"
      "hfs"
      "hfsplus"
      "udf"

      # DMA attack vectors
      "firewire-core"
      "firewire-ohci"
      "firewire-sbp2"
      "thunderbolt"
    ];
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Authentication and credential management
    polkit_kde_agent # For Hyprland/SDDM
    gnome-keyring
    libsecret

    # Encryption
    gnupg
    openssl
  ];

  # ============================================================================
  # SERVICES
  # ============================================================================

  services = {
    # Credential storage
    gnome.gnome-keyring.enable = true;

    # Disk management
    udisks2.enable = true;

    # Audit logging for security events
    audit = {
      enable = true;
      rules = [
        "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change"
        "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change"
        "-a always,exit -F arch=b64 -S clock_settime -k time-change"
        "-a always,exit -F arch=b32 -S clock_settime -k time-change"
        "-w /etc/sudoers -p wa -k scope"
        "-w /etc/sudoers.d/ -p wa -k scope"
      ];
    };
  };

  # ============================================================================
  # SYSTEMD SERVICE HARDENING
  # ============================================================================

  systemd.services = {
    # Harden UDisks2
    udisks2.serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      ProtectClock = true;
      ProtectHostname = true;
    };

    # Harden NetworkManager
    NetworkManager.serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      LockPersonality = true;
    };

    # Harden auditd
    audit.serviceConfig = {
      PrivateTmp = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };

  # ============================================================================
  # SYSTEMD USER SERVICES (Hyprland-specific)
  # ============================================================================

  systemd.user.services = {
    # Auto-start polkit agent for Hyprland
    polkit-kde-agent = {
      Unit = {
        Description = "KDE Polkit Authentication Agent";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_kde_agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================

  environment.sessionVariables = {
    # Memory allocator hardening
    MALLOC_CHECK_ = "2";
    MALLOC_PERTURB_ = "1";

    # Wayland security
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  # ============================================================================
  # FILESYSTEM SECURITY
  # ============================================================================

  systemd.tmpfiles.rules = [
    "d /tmp 1777 root root - -"
    "d /var/tmp 1777 root root - -"
    "d /home 0755 root root - -"
    "z /etc/shadow 0600 root root - -"
    "z /etc/passwd 0644 root root - -"
    "z /etc/group 0644 root root - -"
  ];
}
