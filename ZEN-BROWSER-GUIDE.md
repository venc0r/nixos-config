# Zen Browser Configuration Guide

## Overview

Zen Browser is configured with multiple profiles, each capable of syncing with different Firefox Sync accounts. All profiles share the same custom keybindings and privacy settings.

## Profiles

Three profiles are configured:

1. **Personal** (default) - For personal browsing
2. **Work** - For work-related browsing  
3. **Development** - For development tasks with DevTools optimizations

## Switching Profiles

### Method 1: Profile Manager
```bash
zen --ProfileManager
```

### Method 2: Command Line
```bash
zen -P personal   # Launch personal profile
zen -P work       # Launch work profile
zen -P dev        # Launch development profile
```

### Method 3: Desktop Entries (Recommended)
Create custom .desktop files for each profile to have separate launcher icons.

## Setting Up Firefox Sync

Each profile can use a different Firefox Sync account:

1. Launch the profile: `zen -P <profile-name>`
2. Open Settings → Firefox Account
3. Sign in with the account you want to use for this profile
4. Enable sync for the data you want (bookmarks, passwords, history, **extensions**, etc.)

**Note**: Extensions (including Bitwarden) are synced via Firefox Sync and are NOT managed through Nix configuration. Each profile will sync its own set of extensions from its respective Firefox account.

## Password Manager

The built-in Firefox password manager is **disabled** in this configuration. Use the Bitwarden extension (synced via Firefox account) for password management.

## Custom Keyboard Shortcuts

All keyboard shortcuts are declaratively managed in `programs/zen-browser.nix` and synced across all profiles. The configuration includes version protection that will fail activation if Zen Browser updates change the shortcuts schema.

### Navigation (Vim-like)
- `Ctrl+O` - Go back
- `Ctrl+I` - Go forward

### Tab Management
- `Ctrl+Q` - Close tab
- `Ctrl+Shift+D` - Toggle pin tab
- `Ctrl+Shift+K` - Close all unpinned tabs

### Window Management
- `Ctrl+Alt+N` - New unsynced window

### Sidebar Controls
- `Ctrl+Alt+Z` - Toggle sidebar
- `Alt+B` - Toggle sidebar (alternative)
- `Ctrl+Alt+X` - AI chatbot sidebar

### Workspace Navigation
- `Ctrl+Alt+Q` - Workspace backward
- `Ctrl+Alt+E` - Workspace forward

### Split View
- `Ctrl+Alt+G` - Split view grid
- `Ctrl+Shift+V` - Split view vertical
- `Ctrl+Alt+U` - Unsplit view
- `Ctrl+Shift+*` - New empty split view

### Utility
- `Ctrl+Alt+Shift+C` - Copy URL as markdown

### Disabled Shortcuts
- Undo close window - Disabled
- Toggle reader mode - Disabled
- Exit fullscreen (F11) - Disabled

## Adding Custom Keyboard Shortcuts

To add or modify keyboard shortcuts, edit `programs/zen-browser.nix` in the `keyboardShortcuts` section:

```nix
profiles.personal = {
  keyboardShortcuts = [
    {
      id = "key_close";
      key = "q";
      modifiers = {
        accel = true;
      };
    }
    # Disable a shortcut
    {
      id = "key_quitApplication";
      disabled = true;
    }
  ];
};
```

### Finding Shortcut IDs

1. Open `~/.zen/<profile>/zen-keyboard-shortcuts.json`
2. Search for shortcuts using:
   ```bash
   jq -c '.shortcuts[] | {id, key, keycode, action}' ~/.zen/default/zen-keyboard-shortcuts.json | fzf
   ```
3. Or inspect the keyboard shortcuts settings page in Zen Browser

### Modifiers

Available modifiers:
- `accel` - Accelerator key (Ctrl on Linux/Windows, Cmd on macOS)
- `control` - Ctrl key
- `alt` - Alt key
- `shift` - Shift key
- `meta` - Meta/Windows/Command key

### Version Protection

The configuration includes `keyboardShortcutsVersion = 14` which ensures that if Zen Browser updates change the shortcuts schema, your activation will fail rather than silently breaking. Find the current version in `about:config` as `zen.keyboard.shortcuts.version`.

## Custom Browser Preferences

To add more preferences, edit `programs/zen-browser.nix` in the `Preferences` section:

```nix
Preferences = mkDefaultAttrs {
  # Your custom preferences here
  "browser.tabs.closeTabByDblclick" = false;
  # Add more...
};
```

### Finding Preference Names

1. Open Zen Browser
2. Type `about:config` in the address bar
3. Search for the preference you want to modify
4. Copy the preference name and add it to the configuration

### Common Browser Preferences

```nix
# Smooth scrolling
"general.smoothScroll" = true;

# Hardware acceleration
"layers.acceleration.force-enabled" = true;

# Middle-click behavior
"middlemouse.paste" = false;  # Disable middle-click paste

# New tab behavior
"browser.newtabpage.enabled" = false;  # Blank new tab page
```

### Current Preferences

The following preferences are configured globally across all profiles:

#### Tab Behavior
- Tabs won't warn on close
- Browser won't close with last tab
- Double-click won't close tabs

#### Download Behavior
- Always ask where to save files (no automatic downloads to ~/Downloads)

#### UI Preferences
- Bookmarks bar shows only on new tab
- Resume previous session on startup
- Dark theme enabled
- Zen compact mode enabled at startup

## Installing Extensions

**Extensions are synced via Firefox Sync and should NOT be managed through Nix configuration.**

When you sign in to your Firefox account in a profile, all your extensions (including Bitwarden, uBlock Origin, etc.) will automatically sync and install.

### Why Not Manage Extensions Through Nix?

- Extensions are profile-specific and synced with your Firefox account
- Managing them through Nix would conflict with Firefox Sync
- Your extension settings and data are preserved through sync
- Different profiles can have different extensions via different Firefox accounts

### Manual Installation (If Not Using Sync)

If you're not using Firefox Sync for a particular profile, you can install extensions manually:
- Open `about:addons` → Search and install

**Note**: Manually installed extensions are profile-specific and won't sync to other profiles.

## Profile-Specific Settings

Each profile can have its own settings. Edit the profile in `programs/zen-browser.nix`:

```nix
profiles.work = {
  id = 1;
  name = "Work";
  
  settings = {
    # Work-specific settings
    "browser.startup.homepage" = "https://company-intranet.com";
    "browser.newtabpage.enabled" = true;
  };
};
```

**Note**: Extensions are managed via Firefox Sync, not through Nix configuration.

## Advanced: Container Tabs

Zen Browser supports container tabs (Multi-Account Containers). To configure:

```nix
profiles.personal = {
  containers = {
    Personal = {
      color = "purple";
      icon = "fingerprint";
      id = 1;
    };
    Shopping = {
      color = "yellow";
      icon = "cart";
      id = 2;
    };
  };
};
```

## Troubleshooting

### Profile Manager Not Opening
```bash
# Reset profiles
rm -rf ~/.zen

# Then run profile manager
zen --ProfileManager
```

### Sync Not Working
1. Check internet connection
2. Verify Firefox Account credentials
3. Check `about:sync-log` for errors

### Keyboard Shortcuts Not Working
1. Ensure Zen Browser has been started at least once (creates shortcuts file)
2. Run `home-manager switch` or `nixos-rebuild switch` to apply shortcuts
3. Check if shortcuts were created: `ls ~/.zen/*/zen-keyboard-shortcuts.json`
4. Manually trigger activation: `systemctl start home-manager-${USER}.service`

### Shortcuts Activation Fails
If you see version mismatch errors:
1. Check your current shortcuts version: `jq '.version' ~/.zen/*/zen-keyboard-shortcuts.json` or find `zen.keyboard.shortcuts.version` in `about:config`
2. Update `keyboardShortcutsVersion` in `programs/zen-browser.nix` to match
3. This prevents silent breakage after Zen Browser updates

### Custom Keybindings Not Working
Some keybindings might require browser extensions. Check if the preference exists in `about:config`.

## Resources

- [Zen Browser GitHub](https://github.com/zen-browser/desktop)
- [Firefox Policies](https://mozilla.github.io/policy-templates/)
- [Firefox Preferences](https://support.mozilla.org/en-US/kb/about-config-editor-firefox)
- [NixOS Zen Browser Flake](https://github.com/0xc000022070/zen-browser-flake)
