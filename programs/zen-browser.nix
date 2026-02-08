{
  config,
  pkgs,
  inputs,
  ...
}:

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
        # Helper function to lock preferences
        mkLockedAttrs = builtins.mapAttrs (
          _: value: {
            Value = value;
            Status = "locked";
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
        OfferToSaveLogins = false;
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
        Preferences = mkLockedAttrs {
          # === Tab Behavior ===
          "browser.tabs.warnOnClose" = false;
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.tabs.closeTabByDblclick" = false;

          # === UI & Appearance ===
          "browser.toolbars.bookmarks.visibility" = "newtab"; # Show bookmarks only on new tab
          "ui.systemUsesDarkTheme" = 1; # Use dark theme

          # === Startup & Session ===
          "browser.startup.page" = 3; # Resume previous session
          "browser.sessionstore.interval" = 15000; # Save session every 15 seconds

          # === Search & URL Bar ===
          "browser.urlbar.suggest.searches" = false; # Disable search suggestions in URL bar
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";

          # === Download Behavior ===
          "browser.download.useDownloadDir" = false; # Always ask where to save

          # === Privacy & Security ===
          "privacy.globalprivacycontrol.was_ever_enabled" = true;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.history.custom" = true;
          "datareporting.usage.uploadEnabled" = false;

          # === Developer Tools ===
          "devtools.theme" = "dark";
          "devtools.cache.disabled" = true; # Disable cache in DevTools
          "devtools.toolbox.host" = "window"; # DevTools in separate window
          "devtools.toolbox.splitconsole.open" = true;
          "devtools.inspector.selectedSidebar" = "computedview";

          # === Zen-Specific Settings ===
          "zen.view.compact.enable-at-startup" = true; # Enable compact mode on startup
          "zen.view.compact.hide-toolbar" = true; # Hide toolbar in compact mode
          "zen.view.compact.should-enable-at-startup" = true;
          "zen.view.use-single-toolbar" = false; # Use separate toolbars
          "zen.workspaces.continue-where-left-off" = true; # Resume workspaces
          "zen.workspaces.separate-essentials" = false;

          # === Performance ===
          "browser.ml.enable" = true; # Enable machine learning features
          "accessibility.typeaheadfind.flashBar" = 0; # Disable find-as-you-type flash

          # === Sidebar ===
          "sidebar.visibility" = "hide-sidebar"; # Hide sidebar by default

          # === Display ===
          "browser.display.document_color_use" = 0; # Use system colors

          # === Forms & Autofill ===
          "dom.forms.autocomplete.formautofill" = true; # Enable form autofill
        };
      };

    # Profile 1: Personal
    profiles.personal = {
      id = 0;
      isDefault = true;
      name = "Personal";

      settings = {
        # This profile will use its own Firefox Sync account
        # Configure sync manually in the browser or via about:config
        "services.sync.username" = ""; # Will be set through browser UI
      };

      # You can add profile-specific extensions here
      # extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
      #   ublock-origin
      # ];
    };

    # Profile 2: Work
    profiles.work = {
      id = 1;
      name = "Work";

      settings = {
        # Different sync account for work
        "services.sync.username" = ""; # Will be set through browser UI
      };
    };

    # Profile 3: Development
    profiles.dev = {
      id = 2;
      name = "Development";

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
