{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Import Noctalia (v5) Home Manager module
  imports = [ inputs.noctalia.homeModules.default ];

  # Configure Noctalia Shell (v5 schema — written to ~/.config/noctalia/config.toml).
  # Mirrors the exported default config from the running shell.
  programs.noctalia = {
    enable = true;
    validateConfig = true;

    settings = {
      audio = {
        enable_overdrive = false;
        enable_sounds = false;
      };

      bar.main = {
        position = "top";
        thickness = 34;
        radius = 12;
        background_opacity = 0.0;
        capsule = true;
        capsule_opacity = 1.0;
        margin_edge = 6;
        margin_ends = 8;
        reserve_space = true;
        shadow = true;
        start = [
          "launcher"
          "group:g1"
          "workspaces"
        ];
        center = [
          "clock"
          "wallpaper"
        ];
        end = [
          "tray"
          "notifications"
          "clipboard"
          "caffeine"
          "volume"
          "control-center"
          "session"
        ];
        capsule_group = [
          {
            id = "g1";
            fill = "surface_variant";
            members = [
              "cpu"
              "ram"
              "temp"
            ];
            opacity = 1.0;
            padding = 6.0;
          }
        ];
      };

      brightness = {
        enable_ddcutil = false;
      };

      control_center.shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "wallpaper"; }
        { type = "notification"; }
        { type = "nightlight"; }
        { type = "session"; }
      ];

      desktop_widgets = {
        enabled = false;
      };

      dock = {
        enabled = true;
        position = "bottom";
        active_monitor_only = true;
        auto_hide = true;
        background_opacity = 1.0;
        reserve_space = false;
        show_dots = true;
      };

      location = {
        address = "Chennai, TN";
        auto_locate = false;
      };

      lockscreen = {
        enabled = true;
      };

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [
          "lockscreen-login-box@HDMI-A-1"
          "lockscreen-login-box@DP-2"
        ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget = {
          "lockscreen-login-box@DP-2" = {
            type = "login_box";
            output = "DP-2";
            box_height = 70.0;
            box_width = 400.0;
            cx = 1280.0;
            cy = 961.0;
            rotation = 0.0;
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
          "lockscreen-login-box@HDMI-A-1" = {
            type = "login_box";
            output = "HDMI-A-1";
            box_height = 70.0;
            box_width = 400.0;
            cx = 960.0;
            cy = 961.0;
            rotation = 0.0;
            settings = {
              background_color = "surface_variant";
              background_opacity = 0.88;
              background_radius = 12.0;
              input_opacity = 1.0;
              input_radius = 6.0;
              show_login_button = true;
            };
          };
        };
      };

      nightlight = {
        enabled = false;
        force = false;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      notification = {
        enable_daemon = true;
        show_app_name = true;
        show_actions = true;
        layer = "overlay";
        background_opacity = 0.97;
      };

      osd = {
        position = "top_right";
        background_opacity = 1.0;
      };

      shell = {
        ui_scale = 1.0;
        corner_radius_scale = 1.0;
        font_family = "FiraCode Nerd Font";
        time_format = "{:%I:%M %p}";
        date_format = "%A, %d %b %Y";
        telemetry_enabled = false;
        settings_show_advanced = true;
        show_location = true;
        clipboard_enabled = true;
        clipboard_history_max_entries = 100;
        clipboard_auto_paste = "off";
        avatar_path = "/home/srie/.face";

        animation = {
          enabled = true;
          speed = 1.0;
        };

        panel = {
          borders = true;
          shadow = true;
          transparency_mode = "soft";
          launcher_placement = "centered";
          clipboard_placement = "centered";
          control_center_placement = "attached";
          wallpaper_placement = "attached";
          session_placement = "attached";
        };

        shadow = {
          direction = "down_right";
          alpha = 0.55;
        };

        session.actions = [
          {
            action = "lock";
            enabled = true;
            variant = "default";
          }
          {
            action = "logout";
            enabled = true;
            variant = "default";
          }
          {
            action = "reboot";
            enabled = true;
            variant = "default";
          }
          {
            action = "shutdown";
            enabled = true;
            variant = "destructive";
          }
        ];
      };

      system.monitor = {
        enabled = true;
        cpu_poll_seconds = 3.0;
        gpu_poll_seconds = 3.0;
        memory_poll_seconds = 3.0;
        network_poll_seconds = 3.0;
        disk_poll_seconds = 30.0;
      };

      theme = {
        mode = "dark";
        source = "wallpaper";
        builtin = "Dracula";
        wallpaper_scheme = "m3-tonal-spot";
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        transition = [
          "fade"
          "wipe"
          "disc"
          "stripes"
          "zoom"
          "honeycomb"
        ];
        transition_duration = 1500;
        directory = "/home/srie/Pictures/Wallpapers";
        automation = {
          enabled = false;
          interval_seconds = 300;
          order = "random";
          recursive = true;
        };
        default = {
          path = "/home/srie/Pictures/Wallpapers/a_group_of_wooden_posts_in_water.jpg";
        };
        last = {
          path = "/home/srie/Pictures/Wallpapers/a_group_of_wooden_posts_in_water.jpg";
        };
        monitors = {
          "DP-2" = {
            path = "/home/srie/Pictures/Wallpapers/a_road_leading_to_mountains.jpg";
          };
          "HDMI-A-1" = {
            path = "/home/srie/Pictures/Wallpapers/a_group_of_wooden_posts_in_water.jpg";
          };
        };
      };

      weather = {
        enabled = true;
        refresh_minutes = 30;
        unit = "celsius";
        effects = true;
      };

      widget.clock = {
        format = "{:%d-%b-%Y %I:%M %p %A}";
        tooltip_format = "{:%A, %d %B %Y — %I:%M %p}";
      };
    };
  };
}
