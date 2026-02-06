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
├── flake.nix                    # Main flake entry point
├── hosts/
│   ├── common.nix              # System-wide shared config
│   ├── home.nix                # Home Manager user config (shared)
│   ├── scripts.nix             # Custom shell scripts as Nix derivations
│   ├── dotfiles/
│   │   └── .p10k.zsh          # Powerlevel10k theme
│   ├── programs/
│   │   └── git.nix            # Git configuration (modular)
│   ├── nixos/
│   │   ├── configuration.nix   # VM-specific config
│   │   └── hardware-configuration.nix
│   └── cubi/
│       ├── configuration.nix   # Intel box config
│       └── hardware-configuration.nix
```

### Design Principles
1. **Modular**: Host-specific configs only contain hostname + hardware
2. **Shared by default**: Common configuration in `common.nix` and `home.nix`
3. **Absolute paths**: All scripts use `${pkgs.package}/bin/command` for reliability
4. **Declarative**: Everything managed through Nix, minimal imperative setup

## Migration Progress

### ✅ Completed (8 items)

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
- **Location**: `hosts/home.nix:141-195`
- **Features**:
  - Oh-My-Zsh with custom plugins
  - Powerlevel10k theme
  - Auto-suggestions and syntax highlighting
  - Vi-mode enabled
  - SSH agent integration

#### 4. **Powerlevel10k Theme**
- **Location**: `hosts/dotfiles/.p10k.zsh`
- **Integration**: Loaded via `home.file`

#### 5. **SSH Configuration**
- **Location**: `hosts/programs/git.nix` (modular approach)
- **Features**: SSH identities configured via prezto

#### 6. **Alacritty Terminal**
- **Location**: `hosts/home.nix:199-250`
- **Features**:
  - MesloLGS NF font (size 10)
  - Gruvbox dark theme (with light theme available)
  - Window opacity: 0.9
  - No decorations
  - Custom environment variables
- **Color schemes**: `hosts/home.nix:71-135`
  - `gruvbox-dark.toml` (active)
  - `gruvbox-light.toml` (commented out)
- **Important fix**: Semantic escape chars use plain string for proper TOML generation

#### 7. **Dunst Notification Daemon**
- **Location**: `hosts/home.nix:252-337`
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
- **Location**: `hosts/home.nix:339-428` (after Dunst service)
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

#### 9. **Neovim**
- **Location**: `hosts/programs/nvim.nix`
- **Config source**: `hosts/dotfiles/nvim/` (symlinked)
- **Strategy**: Symlink existing structure to avoid complexity
- **Features**: Lazy.nvim, Mason, Treesitter, etc. kept as-is
- **Dependencies**: `gcc`, `gnumake`, `ripgrep`, `fd`, `xclip`, `tree-sitter`, `luajitPackages.luarocks` installed via Nix

### 🚧 High Priority Pending (3 items)

1. **Kitty** - Alternative terminal emulator  
2. **Autorandr** - Display/monitor management (critical for multi-monitor)
3. **power-profiles** - Power management script

### 📋 Medium Priority Pending (6 items)

1. **Host-specific packages** - Move `teams-for-linux`, `zoom-us` to respective hosts
2. **Bash** - Bash shell configuration
3. **Bin scripts** - General utility scripts (includes tmux helpers)
4. **CopyQ** - Clipboard manager
5. **iamb** - Matrix client
6. **Vim** - Vim editor configuration

### 📌 Low Priority Pending (4 items)

1. **Mangohud** - Gaming overlay
2. **Neofetch** - System info tool
3. **Remmina** - Remote desktop client
4. **Yamllint** - YAML linter
5. **Rofi theming** - `powermenu.rasi` theme

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

### Services Running
- **Dunst**: Notification daemon (via Home Manager service)
- **i3**: Window manager (via Home Manager xsession)

### Programs Configured
- **Alacritty**: Terminal emulator
- **Git**: Version control (modular config)
- **Tmux**: Terminal multiplexer
- **Zsh**: Shell with Oh-My-Zsh and Powerlevel10k

## Known Issues & Notes

1. **Tmux helper scripts**: Referenced in tmux config but not yet migrated
   - `tmux-cht.sh`, `tmux-cal.sh`, `tmux-sessionizer.sh`
   - Location: `~/.dotfiles/bin/.local/bin/scripts/`
   - Will be migrated with "Bin scripts" task

2. **VM-specific**: `block-temperature` shows "N/A" on VM (expected)

3. **Browser**: `zen-browser` not yet in nixpkgs, requires flake input or overlay

4. **Font naming**: Changed from "MesloLGS Nerd Font" to "MesloLGS NF" for consistency

## Recent Commits

- `31bdb46` - Migrate Tmux configuration to programs.tmux
- `b221fc9` - (previous git configuration work)
- `feb3a62` - Migrate Dunst configuration to services.dunst
- `44b5600` - Fix Alacritty semantic_escape_chars - use plain string for TOML generation
- `38cc7a3` - Remove alacritty from packages (managed via programs.alacritty)
- `8163018` - Add Alacritty configuration with Gruvbox themes
- `fb1f09c` - (earlier i3/i3blocks work)

## Next Session Checklist

1. Review this summary
2. Pull latest changes: `git pull`
3. Choose next task from high-priority list:
   - **Nvim** (most complex, may need multiple sessions)
   - **Autorandr** (important for multi-monitor setups)
   - **Kitty** (similar to Alacritty, should be straightforward)
   - **power-profiles** script

4. Continue migration following established patterns
5. Test on VM before deploying to main machine

## Resources

- **NixOS Options Search**: https://search.nixos.org/options
- **Home Manager Options**: https://nix-community.github.io/home-manager/options.html
- **Original dotfiles**: `~/.dotfiles/` (Arch Linux setup)

---

**Last Updated**: 2026-02-05  
**Status**: 8/22 tasks completed (36%)  
**Next Priority**: Nvim, Autorandr, or Kitty configuration
