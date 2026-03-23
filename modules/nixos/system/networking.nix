{
  config,
  pkgs,
  lib,
  meowrchUser,
  meowrchHostname,
  ...
}:

{
  # ============================================================================
  # NETWORKING CORE
  # ============================================================================

  networking = {
    hostName = meowrchHostname;
    enableIPv6 = true;

    # DNS via systemd-resolved (no need for static nameservers here)
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # NetworkManager (primary network management)
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        powersave = false;
        macAddress = "preserve";
      };
      ethernet.macAddress = "preserve";
      unmanaged = [ "*,except:type:wifi,except:type:ethernet" ];
      settings = {
        connectivity = {
          uri = "http://nmcheck.gnome.org/check_network_status.txt";
          interval = 300;
        };
        connection."connection.metered" = 2;
      };
    };

    wireless.enable = false; # Using NetworkManager instead
    dhcpcd.enable = false; # Using NetworkManager instead

    # ============================================================================
    # FIREWALL
    # ============================================================================

    firewall = {
      enable = true;
      allowPing = true;
      logReversePathDrops = true;
      connectionTrackingModules = [
        "ftp"
        "irc"
      ];

      # Standard services
      allowedTCPPorts = [
        22 # SSH
        80 # HTTP
        443 # HTTPS
        8080 # Alternative HTTP
      ];

      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
        68 # DHCP
        5353 # mDNS
      ];

      # KDE Connect
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];

      # Custom iptables rules
      extraCommands = ''
        # Loopback traffic
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A OUTPUT -o lo -j ACCEPT

        # Established and related connections
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      '';
    };
  };

  # ============================================================================
  # NETWORK SERVICES
  # ============================================================================

  services = {
    # DNS Resolution with systemd-resolved and AdGuard DNS
    resolved = {
      enable = true;
      dnssec = lib.mkDefault "true";
      domains = [ "~." ];
      extraConfig = ''
        DNS=94.140.14.14 94.140.15.15
        FallbackDNS=1.1.1.1 8.8.8.8
        DNSOverTLS=yes
        MulticastDNS=yes
        LLMNR=yes
        Cache=yes
        CacheFromLocalhost=yes
      '';
    };

    # mDNS/Bonjour service discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    # SSH Server
    openssh = {
      enable = true;
      ports = [ 22 ];
      openFirewall = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        PrintMotd = false;
      };
    };

    # Network Time Synchronization
    timesyncd = {
      enable = true;
      servers = [
        "0.nixos.pool.ntp.org"
        "1.nixos.pool.ntp.org"
        "2.nixos.pool.ntp.org"
        "3.nixos.pool.ntp.org"
      ];
    };
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Network Management
    networkmanager
    networkmanagerapplet
    networkmanager-openvpn

    # Network Utilities
    wget
    curl
    dig
    nmap
    netcat-gnu
    traceroute
    whois
    iperf3

    # Wireless Tools
    iw
    wpa_supplicant

    # VPN Clients
    openvpn
    wireguard-tools

    # Network Monitoring
    nethogs
    iftop
    bandwhich

    # Service Discovery
    avahi
  ];

  # ============================================================================
  # KERNEL OPTIMIZATION & SECURITY
  # ============================================================================

  boot.kernel.sysctl = {
    # TCP Performance (BBR congestion control)
    "net.core.rmem_max" = 268435456;
    "net.core.wmem_max" = 268435456;
    "net.ipv4.tcp_rmem" = "4096 65536 268435456";
    "net.ipv4.tcp_wmem" = "4096 65536 268435456";
    "net.ipv4.tcp_congestion_control" = "bbr";

    # IPv4 Security
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;

    # IPv6 Security
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
  };

  # ============================================================================
  # SYSTEMD CONFIGURATION
  # ============================================================================

  systemd.services.NetworkManager-wait-online.enable = false;

  # ============================================================================
  # ENVIRONMENT VARIABLES
  # ============================================================================

}
