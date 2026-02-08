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

        # Custom keybindings and preferences shared across all profiles
        Preferences = mkLockedAttrs {
          # Tab behavior
          "browser.tabs.warnOnClose" = false;
          "browser.tabs.closeWindowWithLastTab" = false;

          # UI preferences
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.startup.page" = 3; # Resume previous session

          # Search behavior
          "browser.search.suggest.enabled" = true;
          "browser.urlbar.suggest.searches" = true;

          # Download behavior
          "browser.download.useDownloadDir" = false; # Always ask where to save

          # Performance
          "browser.sessionstore.interval" = 15000; # Save session every 15 seconds

          # Custom keybindings (if Zen supports these)
          # Note: Some keybindings might need browser extensions or Zen-specific settings
          "browser.tabs.closeTabByDblclick" = false;
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

    # Profile 3: Development (optional)
    profiles.dev = {
      id = 2;
      name = "Development";

      settings = {
        # Developer-specific settings
        "devtools.theme" = "dark";
        "devtools.toolbox.host" = "right";
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
