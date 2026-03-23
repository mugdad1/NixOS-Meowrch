{ config, pkgs, ... }:

let
  mkFunction = body: { inherit body; };
  mkFunctionWithArgs = args: body: {
    argumentNames = args;
    inherit body;
  };
in
{
  programs.fish = {
    enable = true;
    package = pkgs.fish;

    # ========================================================================
    # ALIASES
    # ========================================================================
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";

      # Editors
      n = "nvim";
      m = "micro";

      # Listing
      cls = "clear";
      ll = "lsd -la";
      la = "lsd -la";
      l = "lsd -l";
      lt = "lsd --tree";

      # Git
      g = "git";

      # Safe file operations
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";

      # System
      htop = "btop";
      top = "btop";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      rebuild-boot = "sudo nixos-rebuild boot --flake .#meowrch";
      update = "nix flake update";
      b = "rebuild";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";

      # Complex update
      u = "cd ~/NixOS-Meowrch && git pull && ./scripts/update-pkg-hashes.sh && nix flake update && sudo nixos-rebuild switch --flake .#meowrch --impure";
    };

    # ========================================================================
    # ABBREVIATIONS
    # ========================================================================
    shellAbbrs = {
      gst = "git status";
      gco = "git checkout";
      gaa = "git add --all";
      gcm = "git commit -m";
      gp = "git push";
      gl = "git pull";
      glog = "git log --oneline --graph";

      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";

      sctl = "systemctl";
      jctl = "journalctl";
    };

    # ========================================================================
    # PLUGINS
    # ========================================================================
    plugins = [
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
    ];

    # ========================================================================
    # FUNCTIONS
    # ========================================================================
    functions = {
      fish_greeting = mkFunction "";

      # XDG Compliance
      wget = mkFunction ''
        command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
      '';

      nvidia-settings = mkFunction ''
        mkdir -p $XDG_CONFIG_HOME/nvidia/
        command nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings" $argv
      '';

      # Enhanced commands
      ls = mkFunction ''
        if command -q lsd
          command lsd $argv
        else
          command ls --color=auto $argv
        end
      '';

      cat = mkFunction ''
        if command -q bat
          command bat $argv
        else
          command cat $argv
        end
      '';

      # File operations
      mkcd = mkFunctionWithArgs [ "dir" ] ''
        mkdir -p $dir && cd $dir
      '';

      extract = mkFunctionWithArgs [ "file" ] ''
        if test -f $file
          switch $file
            case "*.tar.bz2"; tar xjf $file
            case "*.tar.gz"; tar xzf $file
            case "*.bz2"; bunzip2 $file
            case "*.rar"; unrar x $file
            case "*.gz"; gunzip $file
            case "*.tar"; tar xf $file
            case "*.tbz2"; tar xjf $file
            case "*.tgz"; tar xzf $file
            case "*.zip"; unzip $file
            case "*.Z"; uncompress $file
            case "*.7z"; 7z x $file
            case "*"; echo "'$file' cannot be extracted"
          end
        else
          echo "'$file' is not a valid file"
        end
      '';

      backup = mkFunctionWithArgs [ "source" "destination" ] ''
        if test -z "$source" -o -z "$destination"
          echo "Usage: backup <source> <destination>"
          return 1
        end

        set timestamp (date +"%Y%m%d_%H%M%S")
        set backup_name (basename $source)_$timestamp

        if test -d "$source"
          tar -czf "$destination/$backup_name.tar.gz" -C (dirname $source) (basename $source)
        else
          cp "$source" "$destination/$backup_name"
        end

        echo "Backup created: $destination/$backup_name"
      '';

      # Git operations
      gclone = mkFunctionWithArgs [ "repo" ] ''
        git clone $repo
        set repo_name (basename $repo .git)
        cd $repo_name
      '';

      # Process management
      killp = mkFunctionWithArgs [ "name" ] ''
        set pids (ps aux | grep $name | grep -v grep | awk '{print $2}')
        if test -n "$pids"
          echo "Killing processes: $pids"
          echo $pids | xargs kill
        else
          echo "No processes found matching '$name'"
        end
      '';

      # Configuration management
      config = mkFunctionWithArgs [ "file" ] ''
        switch $file
          case "fish"; $EDITOR ~/.config/fish/config.fish
          case "hypr" "hyprland"; $EDITOR ~/.config/hypr/hyprland.conf
          case "kitty"; $EDITOR ~/.config/kitty/kitty.conf
          case "rofi"; $EDITOR ~/.config/rofi/config.rasi
          case "starship"; $EDITOR ~/.config/starship.toml
          case "*"; echo "Unknown config: $file"
        end
      '';

      # System info
      sysinfo = mkFunction ''
        if command -q fastfetch
          fastfetch
        else if command -q neofetch
          neofetch
        else
          echo "OS: "(uname -o)
          echo "Kernel: "(uname -r)
          echo "Uptime: "(uptime -p)
        end
      '';

      weather = mkFunctionWithArgs [ "city" ] ''
        curl -s "wttr.in/''${city:-.}?format=3"
      '';
    };

    # ========================================================================
    # INITIALIZATION
    # ========================================================================
    interactiveShellInit = ''
      # VI Mode
      fish_vi_key_bindings
      bind \co 'fish_commandline_prepend sudo'
      bind \cr 'history | fzf | read -l result; and commandline $result'

      # Editor & Terminal
      set -gx EDITOR micro
      set -gx VISUAL micro
      set -gx BROWSER zen-beta
      set -gx TERMINAL kitty

      # XDG Base Directory
      set -gx XDG_DATA_HOME $HOME/.local/share
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_STATE_HOME $HOME/.local/state
      set -gx XDG_CACHE_HOME $HOME/.cache

      # Application Settings
      set -gx MICRO_TRUECOLOR 1
      set -gx GTK2_RC_FILES $XDG_CONFIG_HOME/gtk-2.0/gtkrc
      set -gx XCURSOR_PATH /usr/share/icons:$XDG_DATA_HOME/icons

      # Development Tools
      set -gx CARGO_HOME $XDG_DATA_HOME/cargo
      set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
      set -gx PYENV_ROOT $XDG_DATA_HOME/pyenv
      set -gx NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history
      set -gx GNUPGHOME $XDG_DATA_HOME/gnupg

      # Wayland & Qt
      set -gx QT_QPA_PLATFORM "wayland;xcb"
      set -gx QT_QPA_PLATFORMTHEME qt6ct
      set -gx QT_AUTO_SCREEN_SCALE_FACTOR 1

      # Java
      set -gx _JAVA_AWT_WM_NONREPARENTING 1

      # PATH
      fish_add_path $HOME/bin
      fish_add_path $HOME/.local/bin
      fish_add_path $CARGO_HOME/bin
      fish_add_path $PYENV_ROOT/bin

      # Tool Initialization
      command -q starship && starship init fish | source
      command -q zoxide && zoxide init fish | source
      command -q pyenv && pyenv init - | source

      # Startup Display
      status is-interactive && command -q fastfetch && fastfetch

      # Catppuccin Mocha Colors
      set fish_color_normal cdd6f4
      set fish_color_autosuggestion 585b70
      set fish_color_command 89b4fa
      set fish_color_error f38ba8
      set fish_color_param f5c2e7
      set fish_color_comment 6c7086
      set fish_color_quote a6e3a1
      set fish_color_redirection f5c2e7
      set fish_color_end fab387
      set fish_color_operator 00a6b2
      set fish_color_escape 00a6b2
      set fish_color_cwd green
      set fish_color_cwd_root red
      set fish_pager_color_prefix white --bold --underline
      set fish_pager_color_progress brwhite --background=cyan
    '';
  };
}
