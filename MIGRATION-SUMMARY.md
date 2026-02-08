# NixOS Configuration Migration Summary

## Overview
This document tracks the migration of dotfiles from Arch Linux to a clean, modular NixOS flake-based configuration.

**Repository**: `~/Documents/git/github/venc0r/nixos-config`  
**User**: `jma`  
**Hosts**: 
- `nixos` (VM at 192.168.100.174)
- `cubi` (Intel box)

## Configuration Structure

### File Organization
```
nixos-config/
├── flake.nix                       # Main flake entry point
├── ZEN-BROWSER-GUIDE.md           # Zen Browser usage guide
├── dotfiles/                       # Shared configuration files
│   ├── .p10k.zsh                  # Powerlevel10k theme
│   └── nvim/                      # Neovim configuration (symlinked)
├── programs/                       # Modular program configurations (shared)
│   ├── alacritty.nix
│   ├── git.nix
│   ├── nvim.nix
│   ├── tmux.nix
│   ├── zen-browser.nix
│   └── zsh.nix
├── services/                       # Modular service configurations (shared)
│   └── dunst.nix
└── hosts/
    ├── common.nix                  # System-wide shared config
    ├── home.nix                    # Home Manager user config (packages, i3 config)
    ├── scripts.nix                 # Custom shell scripts as Nix derivations
    ├── nixos/
    │   ├── configuration.nix       # VM-specific config
    │   ├── hardware-configuration.nix
    │   └── autorandr.nix.example  # Template for adding autorandr
    └── cubi/
        ├── configuration.nix       # Intel box config
        ├── hardware-configuration.nix
        └── autorandr.nix          # Display profiles for cubi
```

### Design Principles
1. **Modular**: Host-specific configs only contain hostname + hardware
2. **Shared by default**: Common configuration in `common.nix` and `home.nix`
3. **Absolute paths**: All scripts use `${pkgs.package}/bin/command` for reliability
4. **Declarative**: Everything managed through Nix, minimal imperative setup
5. **Organized imports**: Programs and services at top-level for easy access

## Migration Progress

### ✅ Completed (12 items)

#### 1. **i3 Window Manager** 
- **Location**: `hosts/home.nix:414-704`
- **Features**:
  - Vim-style navigation (`h/j/k/l`)
  - Workspace switching with "follow" behavior
  - Resize mode with Vim bindings
  - Custom color scheme
  - Workspace assignments for applications
  - Floating rules
- **Custom scripts integrated**: `volume-brightness`, `blurlock`

#### 2. **i3blocks Status Bar**
- **Location**: `hosts/home.nix:339-412`
- **Custom blocks** (all in `hosts/scripts.nix`):
  - `block-cpu`: CPU usage via mpstat
  - `block-memory`: RAM percentage
  - `block-disk`: Free disk space
  - `block-temperature`: CPU temp (shows N/A on VM)
  - `block-bandwidth`: Network speed via sar
  - `block-battery`: Battery status with color coding
  - `block-volume`: Volume control (speakers + mic)

#### 3. **Zsh Shell**
- **Location**: `programs/zsh.nix`
- **Features**:
  - Oh-My-Zsh with custom plugins
  - Powerlevel10k theme
  - Auto-suggestions and syntax highlighting
  - Vi-mode enabled
  - SSH agent integration

#### 4. **Powerlevel10k Theme**
- **Location**: `dotfiles/.p10k.zsh`
- **Integration**: Loaded via `home.file`

#### 5. **SSH Configuration**
- **Location**: `programs/git.nix` (modular approach)
- **Features**: SSH identities configured via prezto

#### 6. **Alacritty Terminal**
- **Location**: `programs/alacritty.nix`
- **Features**:
  - MesloLGS NF font (size 10)
  - Gruvbox dark theme (with light theme available)
  - Window opacity: 0.9
  - No decorations
  - Custom environment variables
- **Color schemes**: Defined in the same file
  - `gruvbox-dark.toml` (active)
  - `gruvbox-light.toml` (commented out)
- **Important fix**: Semantic escape chars use plain string for proper TOML generation

#### 7. **Dunst Notification Daemon**
- **Location**: `services/dunst.nix`
- **Features**:
  - Follow mouse mode
  - Custom urgency levels with Gruvbox colors
  - Keyboard shortcuts (ctrl+space, ctrl+grave, etc.)
  - 10 notification limit
  - 30% transparency
- **Colors**:
  - Low: `#222222` / `#888888`
  - Normal: `#759a1f` / `#002b36`
  - Critical: `#900000` / `#ffffff` (no timeout)

#### 8. **Tmux Terminal Multiplexer**
- **Location**: `programs/tmux.nix`
- **Features**:
  - Custom prefix: `Alt+s` (instead of `Ctrl+b`)
  - Vim-style keybindings (navigation, resizing, copy mode)
  - Split panes: `|` (horizontal), `-` (vertical)
  - Copy to clipboard with `xclip`
  - Gruvbox status bar theme
  - Base index: 1 (windows and panes)
  - History: 10,240 lines
  - True color support for Neovim
- **Custom bindings**:
  - `R`: Reload config
  - `b`: Clear history
  - `i/y/g`: Launch helper scripts (tmux-cht.sh, tmux-cal.sh, tmux-sessionizer.sh)
  - `t/n/m`: Popup sessions
- **Note**: Helper scripts referenced but not yet migrated (pending "Bin scripts" task)

#### 9. **Neovim Editor**
- **Location**: `programs/nvim.nix`
- **Config source**: `dotfiles/nvim/` (symlinked)
- **Strategy**: Symlink existing Neovim configuration to avoid complexity
- **Features**: 
  - Lazy.nvim plugin manager
  - Mason for LSP/DAP/linter management
  - Treesitter for syntax highlighting
  - Complete existing setup preserved
- **Dependencies installed via Nix**: 
  - `gcc`, `gnumake`, `unzip`, `wget`, `curl`, `gzip`
  - `ripgrep`, `fd`, `xclip`, `tree-sitter`
  - `luajitPackages.luarocks`
- **Aliases**: `vi` and `vim` point to `nvim`
- **Default editor**: Set as system default via `defaultEditor = true`

#### 9. **Neovim Editor**
- **Location**: `programs/nvim.nix`
- **Config source**: `dotfiles/nvim/` (symlinked)
- **Strategy**: Symlink existing Neovim configuration to avoid complexity
- **Features**: 
  - Lazy.nvim plugin manager
  - Mason for LSP/DAP/linter management
  - Treesitter for syntax highlighting
  - Complete existing setup preserved
- **Dependencies installed via Nix**: 
  - `gcc`, `gnumake`, `unzip`, `wget`, `curl`, `gzip`
  - `ripgrep`, `fd`, `xclip`, `tree-sitter`
  - `luajitPackages.luarocks`
- **Aliases**: `vi` and `vim` point to `nvim`
- **Default editor**: Set as system default via `defaultEditor = true`
- **Note**: lazy-lock.json writes will fail in read-only symlinked config; needs manual git updates

#### 10. **Autorandr Display Manager**
- **Location**: `hosts/cubi/autorandr.nix` (host-specific)
- **Strategy**: Host-specific configuration imported in each host's configuration.nix
- **Features**:
  - Automatic display configuration switching based on connected monitors
  - Three profiles configured for `cubi` host:
    - `buero` (office): External 2560x1440 @ 59.95Hz (DP-1-8) + laptop 1920x1200 @ 60.03Hz (eDP-1)
    - `desktop`: External 3840x2160 @ 120Hz (DP-3) + laptop 1920x1200 @ 60.03Hz (eDP-1)
    - `notebook`: Laptop screen only 1920x1200 @ 60.03Hz (eDP-1)
  - EDID fingerprinting for automatic profile detection
  - Proper positioning: external monitors to the right of laptop screen
- **Adding profiles**:
  1. Connect monitors and run `autorandr --save <profile-name>`
  2. Extract EDID from `~/.config/autorandr/<profile-name>/setup`
  3. Extract config from `~/.config/autorandr/<profile-name>/config`
  4. Add to `hosts/<hostname>/autorandr.nix`
  5. Import in `hosts/<hostname>/configuration.nix` via `home-manager.users.jma.imports`
- **Note**: Template available at `hosts/nixos/autorandr.nix.example`

#### 11. **Zen Browser**
- **Location**: `programs/zen-browser.nix`
- **Flake input**: `github:0xc000022070/zen-browser-flake`
- **Features**:
  - Multi-profile support (personal, work, development)
  - Each profile can sync with different Firefox Sync account
  - Shared keybindings and policies across all profiles
  - Privacy-focused defaults (no telemetry, tracking protection enabled)
  - Custom keyboard shortcuts and preferences
  - Set as default browser via XDG MIME associations
- **Profiles configured**:
  - `personal` (default): For personal browsing
  - `work`: For work-related browsing
  - `dev`: For development with DevTools optimizations
- **Profile management**: Launch with `zen -P <profile-name>` or `zen --ProfileManager`
- **Documentation**: See `ZEN-BROWSER-GUIDE.md` for detailed usage instructions
- **Note**: Auto-updates disabled (managed by Nix flake)

#### 12. **Host-Specific Packages**
- **Location**: `hosts/cubi/packages.nix`
- **Strategy**: Host-specific package imports
- **Packages added to cubi**:
  - `teams-for-linux` - Microsoft Teams client
  - `zoom-us` - Zoom video conferencing
- **Configuration**: Imported in `hosts/cubi/configuration.nix` via `home-manager.users.jma.imports`
- **Note**: These packages are only installed on the production machine (cubi), not on the VM

### 📋 Medium Priority Pending (5 items)

1. **Bash** - Bash shell configuration
2. **Bin scripts** - General utility scripts (includes tmux helpers)
3. **CopyQ** - Clipboard manager
4. **iamb** - Matrix client
5. **Vim** - Vim editor configuration

### 📌 Low Priority Pending (5 items)

1. **power-profiles** - Power management script
2. **Mangohud** - Gaming overlay
3. **Neofetch** - System info tool
4. **Remmina** - Remote desktop client
5. **Yamllint** - YAML linter
6. **Rofi theming** - `powermenu.rasi` theme

## Key Technical Details

### Package Management
- **System packages**: Defined in `hosts/common.nix`
- **User packages**: Defined in `hosts/home.nix`
- **Home Manager integration**: NixOS module (not standalone)
- **Unfree packages**: Handled via `useGlobalPkgs = true` and `useUserPackages = true`

### Deployment
```bash
# On the VM
ssh jma@192.168.100.174
cd nixos-config && git pull
sudo nixos-rebuild switch --flake .#nixos --refresh

# On the Intel box (cubi)
cd ~/nixos-config && git pull
sudo nixos-rebuild switch --flake .#cubi --refresh
```

### Important Patterns Established

1. **Absolute Nix store paths in scripts**:
   ```nix
   command = "${pkgs.package}/bin/command";
   ```

2. **Host-specific config minimal**:
   ```nix
   # Only hostname + hardware imports
   networking.hostName = "nixos";
   imports = [ ./hardware-configuration.nix ../common.nix ];
   ```

3. **Extending default keybindings**:
   ```nix
   keybindings = lib.mkOptionDefault { ... };
   ```

4. **TOML/INI string escaping**:
   - For settings converted to TOML: use plain strings, generator handles escaping
   - Example: `semantic_escape_chars = "=,│`|:\"' ()[]{}<>";`

5. **Testing workflow**:
   - Make changes locally
   - Commit and push to GitHub
   - Pull and rebuild on VM
   - Test thoroughly before deploying to main machine

## Current System State

### Installed Packages
**System-level** (`hosts/common.nix`):
- Base utilities, shell tools
- i3wm and related tools
- Development tools
- System monitoring (sysstat, lm_sensors, acpi)

**User-level** (`hosts/home.nix`):
- i3 ecosystem: i3lock, i3blocks, dmenu, rofi, feh, picom
- Terminal tools: alacritty (via programs.alacritty)
- Applications: thunar, discord, qalculate-gtk
- Utilities: flameshot, copyq, autorandr, xclip
- Fonts: meslo-lgs-nf
- Custom scripts (via `scripts.nix`)

### Programs Configured (via `programs/`)
- **Alacritty**: Terminal emulator (`alacritty.nix`)
- **Git**: Version control (`git.nix`)
- **Neovim**: Text editor with full Lazy.nvim setup (`nvim.nix`)
- **Tmux**: Terminal multiplexer (`tmux.nix`)
- **Zsh**: Shell with Oh-My-Zsh and Powerlevel10k (`zsh.nix`)

### Services Running (via `services/`)
- **Dunst**: Notification daemon (`dunst.nix`)
- **i3**: Window manager (via Home Manager xsession in `home.nix`)

## Known Issues & Notes

1. **Neovim lazy-lock.json**: Config is symlinked as read-only; plugin lockfile updates require manual git commits

2. **Tmux helper scripts**: Referenced in tmux config but not yet migrated
   - `tmux-cht.sh`, `tmux-cal.sh`, `tmux-sessionizer.sh`
   - Location: `~/.dotfiles/bin/.local/bin/scripts/`
   - Will be migrated with "Bin scripts" task

3. **VM-specific**: `block-temperature` shows "N/A" on VM (expected)

4. **Browser**: `zen-browser` not yet in nixpkgs, requires flake input or overlay

5. **Font naming**: Changed from "MesloLGS Nerd Font" to "MesloLGS NF" for consistency

6. **Hardware configuration**: Updated to use label-based filesystem mounting and support both Intel/AMD KVM modules

## Recent Commits

- `cb2fd54` - is this a problem?
- `456e260` - gemini is so fail
- `ef06daf` - feat(nixos): support both intel and amd kvm modules
- `1b40604` - feat(nixos): switch to label-based filesystem mounting
- `79e3430` - chore: remove lazy-lock.json and configure separate path
- `c59e6e1` - docs: update migration summary for neovim
- `05a9146` - feat: migrate neovim config
- `030f8c2` - Add migration summary document for future sessions
- `2a67be6` - add tmux, split program and service config into files and imports
- `31bdb46` - Migrate Tmux configuration to programs.tmux

## Next Session Checklist

1. Review this summary
2. Pull latest changes: `git pull`
3. Choose next task from high-priority list:
   - **Autorandr** (important for multi-monitor setups on cubi)
   - **Kitty** (similar to Alacritty, should be straightforward)
   - **power-profiles** script (power management)

4. Continue migration following established patterns
5. Test on VM before deploying to main machine

---

**Last Updated**: 2026-02-08  
**Status**: 12/22 tasks completed (55%)  
**Next Priority**: Bin scripts, Bash, or CopyQ
