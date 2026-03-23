{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    package = pkgs.starship;

    settings = {
      format = "$directory$git_branch$git_status$nix_shell$character";
      right_format = "$cmd_duration";
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
        read_only = " 🔒";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold cyan";
      };

      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
      };

      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "cyan";
        conflicted = "🏳";
        up_to_date = " ";
        untracked = " ";
        ahead = "⇡$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        behind = "⇣$count";
        stashed = " ";
        modified = " ";
        staged = "[++$count](green)";
        renamed = "襁 ";
        deleted = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style)";
        style = "yellow bold";
      };

      nix_shell = {
        symbol = "❄️  ";
        format = "via [$symbol$state]($style) ";
        style = "bold blue";
      };

      # Disabled modules
      username.disabled = true;
      hostname.disabled = true;
      time.disabled = true;
      battery.disabled = true;
      memory_usage.disabled = true;
    };
  };
}
