{
  config,
  pkgs,
  inputs,
  ...
}:

let
  ffAddons = pkgs.nur.repos.rycee.firefox-addons;
  sharedExtensions = with ffAddons; [
    ublock-origin
    darkreader
    vimium
  ];
in
{
  # Zen Browser - Firefox-based browser with vertical tabs and modern UI
  # Multiple profiles with shared keybindings

  imports = [
    inputs.zen-browser.homeModules.default
  ];

  programs.zen-browser = {
    enable = true;

    # Global policies applied to all profiles
    policies =
      let
        # Helper function to lock preferences (use sparingly!)
        mkLockedAttrs = builtins.mapAttrs (
          _: value: {
            Value = value;
            Status = "locked";
          }
        );
        # Helper for default (non-locked) preferences
        mkDefaultAttrs = builtins.mapAttrs (
          _: value: {
            Value = value;
            Status = "default";
          }
        );
      in
      {
        # Disable automatic updates (managed by Nix)
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFeedbackCommands = true;

        # Privacy settings
        DontCheckDefaultBrowser = true;
        OfferToSaveLogins = false; # Disabled - using Bitwarden extension
        PasswordManagerEnabled = false; # Disable built-in password manager
        NoDefaultBookmarks = true;

        # Autofill settings
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;

        # Tracking protection
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };

        # Custom preferences and settings shared across all profiles
        # Migrated from existing Zen Browser configuration
        #
        # NOTE: Most preferences use "default" status so Zen can still modify them.
        # Only security/privacy-critical settings are "locked".
        Preferences =
          (mkLockedAttrs {
            # === LOCKED Preferences (cannot be changed by user) ===
            # These are security/privacy critical
            "datareporting.usage.uploadEnabled" = false; # No telemetry
            "signon.rememberSignons" = false; # Force disable password manager
            "signon.autofillForms" = false; # Force disable password autofill
          })
          // (mkDefaultAttrs {
            # === DEFAULT Preferences (can be changed by user) ===

            # === Tab Behavior ===
            "browser.tabs.warnOnClose" = false;
            "browser.tabs.closeWindowWithLastTab" = false;
            "browser.tabs.closeTabByDblclick" = false;
            "browser.warnOnQuitShortcut" = false; # Disable Ctrl+Q quit warning

            # === UI & Appearance ===
            "browser.toolbars.bookmarks.visibility" = "newtab";
            "ui.systemUsesDarkTheme" = 1;

            # === Startup & Session ===
            "browser.startup.page" = 3; # Resume previous session
            "browser.sessionstore.interval" = 15000;

            # === Search & URL Bar ===
            "browser.urlbar.suggest.searches" = false;
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.placeholderName.private" = "DuckDuckGo";

            # === Download Behavior ===
            "browser.download.useDownloadDir" = false;

            # === Privacy & Security ===
            "privacy.globalprivacycontrol.was_ever_enabled" = true;
            "privacy.clearOnShutdown_v2.formdata" = true;
            "privacy.history.custom" = true;

            # === Password Manager ===
            "signon.management.page.breach-alerts.enabled" = false;

            # === Developer Tools ===
            "devtools.theme" = "dark";
            "devtools.cache.disabled" = true;
            "devtools.toolbox.host" = "window";
            "devtools.toolbox.splitconsole.open" = true;
            "devtools.inspector.selectedSidebar" = "computedview";

            # === Zen-Specific Settings ===
            "zen.view.compact.enable-at-startup" = true;
            "zen.view.compact.hide-toolbar" = true;
            "zen.view.compact.should-enable-at-startup" = true;
            "zen.view.use-single-toolbar" = false;
            "zen.workspaces.continue-where-left-off" = true;
            "zen.workspaces.separate-essentials" = false;

            # === Performance ===
            "browser.ml.enable" = true;
            "accessibility.typeaheadfind.flashBar" = 0;

            # === Sidebar ===
            "sidebar.visibility" = "hide-sidebar";

            # === Display ===
            "browser.display.document_color_use" = 0;

            # === Forms & Autofill ===
            "dom.forms.autocomplete.formautofill" = true;

            # === Translations ===
            "browser.translations.neverTranslateLanguages" = "de";

            # === Sync (self-hosted token server) ===
            "identity.sync.tokenserver.uri" = "https://firefox-sync.hcp.v3nc.org/1.0/sync/1.5";

            # === Firezone deep-link callback (launch the OS handler, no prompt) ===
            "network.protocol-handler.external.firezone-fd0020211111" = true;
            "network.protocol-handler.warn-external.firezone-fd0020211111" = false;
          })
          // (pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isAarch64 (mkDefaultAttrs {
            # virtio-gpu-gl (virgl) WebRender produces red color artifacts in the VM;
            # force software WebRender (CPU rasterization = correct colors).
            "gfx.webrender.software" = true;
            # GPU-accelerated present of the software-rendered frames (cheap blit,
            # not the buggy rasterization path) — keeps perf up, no artifacts.
            "gfx.webrender.software.opengl" = true;
          }));
      };

    # Profile 1: private — matches existing on-disk profile dir
    profiles.private = {
      id = 0;
      isDefault = true;
      name = "private";

      extensions.packages = sharedExtensions ++ [
        ffAddons.bitwarden
        ffAddons.onepassword-password-manager
      ];

      settings = {
        # Firefox Sync will be configured through browser UI
        # Extensions (including Bitwarden) are synced via Firefox account
        "services.sync.username" = ""; # Set via browser UI
      };

      # Version protection: fails activation if Zen Browser updates change shortcuts schema
      # Current version found in about:config as "zen.keyboard.shortcuts.version"
      keyboardShortcutsVersion = 19;

      # Custom keyboard shortcuts (migrated from existing Zen Browser config)
      keyboardShortcuts = [
        # === Navigation (Custom Vim-like) ===
        {
          id = "focusURLBar";
          key = "l";
          modifiers = {
            control = true;
          };
        }
        {
          id = "key_newNavigatorTab";
          key = "t";
          modifiers = {
            control = true;
          };
        }
        {
          id = "goBackKb";
          key = "o";
          modifiers = {
            control = true;
          };
        }
        {
          id = "goForwardKb";
          key = "i";
          modifiers = {
            control = true;
          };
        }

        # === Tab Management ===
        {
          id = "key_close";
          key = "q";
          modifiers = {
            control = true;
          };
        }
        {
          id = "zen-toggle-pin-tab";
          key = "d";
          modifiers = {
            control = true;
            shift = true;
          };
        }
        {
          id = "zen-close-all-unpinned-tabs";
          key = "k";
          modifiers = {
            control = true;
            shift = true;
          };
        }

        # === Window Management ===
        {
          id = "zen-new-unsynced-window";
          key = "n";
          modifiers = {
            control = true;
            alt = true;
          };
        }

        # === Sidebar Controls ===
        {
          id = "toggleSidebarKb";
          key = "z";
          modifiers = {
            control = true;
            alt = true;
          };
        }
        {
          id = "zen-toggle-sidebar";
          key = "b";
          modifiers = {
            alt = true;
          };
        }
        {
          id = "viewGenaiChatSidebarKb";
          key = "x";
          modifiers = {
            control = true;
            alt = true;
          };
        }

        # === Workspace Navigation ===
        {
          id = "zen-workspace-backward";
          key = "q";
          modifiers = {
            control = true;
            alt = true;
          };
        }
        {
          id = "zen-workspace-forward";
          key = "e";
          modifiers = {
            control = true;
            alt = true;
          };
        }

        # === Split View ===
        {
          id = "zen-split-view-grid";
          key = "g";
          modifiers = {
            control = true;
            alt = true;
          };
        }
        {
          id = "zen-split-view-vertical";
          key = "v";
          modifiers = {
            control = true;
            shift = true;
          };
        }
        {
          id = "zen-split-view-unsplit";
          key = "u";
          modifiers = {
            control = true;
            alt = true;
          };
        }
        {
          id = "zen-new-empty-split-view";
          key = "*";
          modifiers = {
            control = true;
            shift = true;
          };
        }

        # === Utility Shortcuts ===
        {
          id = "zen-copy-url-markdown";
          key = "c";
          modifiers = {
            control = true;
            alt = true;
            shift = true;
          };
        }

        # === Disabled Shortcuts ===
        # Disabled to prevent conflicts or unwanted behavior
        {
          id = "key_undoCloseWindow";
          disabled = true;
        }
        {
          id = "key_toggleReaderMode";
          disabled = true;
        }
        {
          id = "key_exitFullScreen";
          disabled = true;
        }
        # Conflicts with Ctrl+O (Back navigation)
        {
          id = "zen-glance-expand";
          disabled = true;
        }
        # Conflicts with Ctrl+I (Forward navigation) - DevTools shortcuts
        {
          id = "key_toggleToolbox";
          disabled = true;
        }
        {
          id = "key_browserToolbox";
          disabled = true;
        }
        # Conflicts with Ctrl+I (Forward navigation) - Page Info
        {
          id = "key_viewInfo";
          disabled = true;
        }
        # Conflicts with Ctrl+Shift+K (Close unpinned tabs)
        {
          id = "key_webconsole";
          disabled = true;
        }
      ];
    };

    # Profile 2: Default (release) — matches existing on-disk profile dir
    profiles.default-release = {
      id = 1;
      name = "Default (release)";

      settings = {
        "services.sync.username" = ""; # Set via browser UI
      };

      extensions.packages = sharedExtensions ++ [
        ffAddons.onepassword-password-manager
      ];

      keyboardShortcutsVersion = config.programs.zen-browser.profiles.private.keyboardShortcutsVersion;
      keyboardShortcuts = config.programs.zen-browser.profiles.private.keyboardShortcuts;
    };

    # Profile 3: Clockodo
    profiles.clockodo = {
      id = 2;
      name = "clockodo";

      settings = {
        # Developer-specific settings from your current config
        "devtools.theme" = "dark";
        "devtools.cache.disabled" = true;
        "devtools.toolbox.host" = "window";
        "devtools.toolbox.previousHost" = "bottom";
        "devtools.toolbox.selectedTool" = "netmonitor";
        "devtools.toolbox.splitconsole.open" = true;
        "devtools.toolbox.splitconsoleHeight" = 451;
        "devtools.inspector.activeSidebar" = "computedview";
        "devtools.inspector.selectedSidebar" = "computedview";
        "devtools.toolsidebar-height.inspector" = 350;
        "devtools.toolsidebar-width.inspector" = 510;
        "devtools.toolsidebar-width.inspector.splitsidebar" = 255;
        "devtools.performance.recording.entries" = 134217728;
        "devtools.performance.recording.features" = "[\"screenshots\",\"js\",\"cpu\",\"memory\"]";
        "devtools.performance.recording.threads" =
          "[\"GeckoMain\",\"Compositor\",\"Renderer\",\"DOM Worker\"]";
      };

      extensions.packages = sharedExtensions ++ [
        ffAddons.onepassword-password-manager
      ];

      # Same shortcuts version as personal profile
      keyboardShortcutsVersion = config.programs.zen-browser.profiles.private.keyboardShortcutsVersion;

      # Inherit same keyboard shortcuts as personal profile
      keyboardShortcuts = config.programs.zen-browser.profiles.private.keyboardShortcuts;
    };
  };

  # Set Zen as default browser
  xdg.mimeApps =
    let
      associations = builtins.listToAttrs (
        map
          (name: {
            inherit name;
            value = "zen.desktop";
          })
          [
            "application/x-extension-shtml"
            "application/x-extension-xhtml"
            "application/x-extension-html"
            "application/x-extension-xht"
            "application/x-extension-htm"
            "x-scheme-handler/unknown"
            "x-scheme-handler/mailto"
            "x-scheme-handler/chrome"
            "x-scheme-handler/about"
            "x-scheme-handler/https"
            "x-scheme-handler/http"
            "application/xhtml+xml"
            "application/json"
            "text/plain"
            "text/html"
          ]
      );
    in
    {
      associations.added = associations;
      defaultApplications = associations;
    };
}
