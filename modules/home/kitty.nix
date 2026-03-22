{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      # Font
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "JetBrainsMono Nerd Font Bold";
      italic_font = "JetBrainsMono Nerd Font Italic";
      bold_italic_font = "JetBrainsMono Nerd Font Bold Italic";
      font_size = "12.0";
      disable_ligatures = "never";
      font_features = "JetBrainsMonoNerdFont-Regular +zero +onum";

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = "15.0";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      # Scrollback
      scrollback_lines = "10000";
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";

      # Mouse
      mouse_hide_wait = "3.0";
      url_color = "#89b4fa";
      url_style = "curly";
      open_url_modifiers = "kitty_mod";
      copy_on_select = "yes";

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "yes";
      bell_on_tab = "yes";

      # Window
      remember_window_size = "yes";
      initial_window_width = "1200";
      initial_window_height = "700";
      window_border_width = "1px";
      draw_minimal_borders = "yes";
      window_padding_width = "10";
      placement_strategy = "center";

      # Colors - Base
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";

      # Colors - Borders
      active_border_color = "#b4befe";
      inactive_border_color = "#6c7086";
      bell_border_color = "#f9e2af";

      # Colors - Tab Bar
      tab_bar_background = "#11111b";
      active_tab_foreground = "#11111b";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#181825";

      # Colors - Marks
      mark1_foreground = "#1e1e2e";
      mark1_background = "#b4befe";
      mark2_foreground = "#1e1e2e";
      mark2_background = "#cba6f7";
      mark3_foreground = "#1e1e2e";
      mark3_background = "#74c7ec";

      # Terminal Colors
      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#f5c2e7";
      color6 = "#94e2d5";
      color7 = "#bac2de";
      color8 = "#585b70";
      color9 = "#f38ba8";
      color10 = "#a6e3a1";
      color11 = "#f9e2af";
      color12 = "#89b4fa";
      color13 = "#f5c2e7";
      color14 = "#94e2d5";
      color15 = "#a6adc8";

      # Tab Bar Style
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_switch_strategy = "previous";
      tab_separator = " ┇";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

      # Shell & Editor
      shell = "fish";
      editor = "micro";

      # Behavior
      allow_remote_control = "yes";
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
      term = "xterm-kitty";

      # Performance
      repaint_delay = "10";
      input_delay = "3";
      sync_to_monitor = "yes";

      # Opacity
      background_opacity = "0.95";
      dim_opacity = "0.75";

      # Keyboard
      kitty_mod = "ctrl+shift";
    };

    keybindings = {
      # Clipboard
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+s" = "paste_from_selection";
      "shift+insert" = "paste_from_selection";

      # Scrolling
      "kitty_mod+up" = "scroll_line_up";
      "kitty_mod+k" = "scroll_line_up";
      "kitty_mod+down" = "scroll_line_down";
      "kitty_mod+j" = "scroll_line_down";
      "kitty_mod+page_up" = "scroll_page_up";
      "kitty_mod+page_down" = "scroll_page_down";
      "kitty_mod+home" = "scroll_home";
      "kitty_mod+end" = "scroll_end";

      # Window Management
      "kitty_mod+enter" = "new_window";
      "kitty_mod+n" = "new_os_window";
      "kitty_mod+w" = "close_window";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+r" = "start_resizing_window";
      "kitty_mod+1" = "first_window";
      "kitty_mod+2" = "second_window";
      "kitty_mod+3" = "third_window";
      "kitty_mod+4" = "fourth_window";
      "kitty_mod+5" = "fifth_window";
      "kitty_mod+6" = "sixth_window";
      "kitty_mod+7" = "seventh_window";
      "kitty_mod+8" = "eighth_window";
      "kitty_mod+9" = "ninth_window";
      "kitty_mod+0" = "tenth_window";

      # Tab Management
      "kitty_mod+right" = "next_tab";
      "kitty_mod+left" = "previous_tab";
      "kitty_mod+t" = "new_tab";
      "kitty_mod+q" = "close_tab";
      "kitty_mod+." = "move_tab_forward";
      "kitty_mod+," = "move_tab_backward";

      # Font Size
      "kitty_mod+equal" = "change_font_size all +2.0";
      "kitty_mod+plus" = "change_font_size all +2.0";
      "kitty_mod+minus" = "change_font_size all -2.0";
      "kitty_mod+backspace" = "change_font_size all 0";

      # Text Hints
      "kitty_mod+e" = "kitten hints";
      "kitty_mod+p>f" = "kitten hints --type path --program -";
      "kitty_mod+p>l" = "kitten hints --type line --program -";
      "kitty_mod+p>w" = "kitten hints --type word --program -";

      # Misc
      "kitty_mod+f11" = "toggle_fullscreen";
      "kitty_mod+f10" = "toggle_maximized";
      "kitty_mod+f2" = "edit_config_file";
      "kitty_mod+delete" = "clear_terminal reset active";
      "kitty_mod+a>m" = "set_background_opacity +0.1";
      "kitty_mod+a>l" = "set_background_opacity -0.1";
      "kitty_mod+a>1" = "set_background_opacity 1";
    };
  };
}
