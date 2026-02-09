# Configuring Home Manager for Entra ID Users

## Current Setup

Home Manager is currently configured **only** for the local `jma` user in each host's `configuration.nix`:

```nix
home-manager.users.jma.imports = [ ../home.nix ];
```

Entra ID users do **not** automatically get Home Manager configuration.

## Adding Home Manager for Entra ID Users

When an Entra ID user needs the shared desktop configuration (i3, Alacritty, Neovim, etc.), you must manually add them to the Home Manager configuration.

### Example: Adding user `alice@cloudpunks.onmicrosoft.com`

Edit `hosts/nixos/configuration.nix` or `hosts/cubi/configuration.nix`:

```nix
home-manager.users = {
  # Local user
  jma.imports = [ ../home.nix ];
  
  # Entra ID user
  # Note: Himmelblau typically creates users with their UPN as username
  "alice@cloudpunks.onmicrosoft.com".imports = [ ../home.nix ];
};
```

### Username Format

Entra ID usernames in Himmelblau typically use the User Principal Name (UPN) format:
- `alice@cloudpunks.onmicrosoft.com`
- `bob.smith@company.com`

You can verify the exact username after first login with:
```bash
getent passwd | grep alice
```

### Host-Specific Overrides

If an Entra ID user needs different configuration on different hosts:

**On cubi** (with autorandr, picom, etc.):
```nix
home-manager.users."alice@cloudpunks.onmicrosoft.com".imports = [
  ../home.nix
  ./autorandr.nix
  ./packages.nix
  ../../services/picom.nix
];
```

**On nixos VM** (minimal):
```nix
home-manager.users."alice@cloudpunks.onmicrosoft.com".imports = [
  ../home.nix
];
```

## Important Notes

1. **Username must be exact** - Use the full UPN including `@domain.com`
2. **Quotes required** - The `@` symbol requires quoting in Nix
3. **Pre-configuration** - Add the user to Home Manager **before** their first login if you want the config applied immediately
4. **Post-configuration** - If added after first login, run `home-manager switch` as that user or rebuild the system

## Alternative: Shared Base Configuration

If you want to provide a lighter shared configuration for all Entra ID users, you can create a separate module:

```nix
# hosts/home-entra-minimal.nix
{ lib, config, pkgs, ... }:
{
  # Minimal shared config for Entra ID users
  home.stateVersion = "25.11";
  programs.git.enable = true;
  # etc...
}
```

Then import it for Entra ID users while keeping the full config for `jma`.
