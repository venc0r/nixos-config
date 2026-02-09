# Himmelblau Azure Entra ID Integration

## Overview
This configuration enables Azure Entra ID authentication for NixOS using Himmelblau.

## Configuration Details

### Service Configuration
- **Module**: `services/himmelblau.nix`
- **Package Variant**: Desktop (includes Teams for Linux and O365 integration)
- **Entra ID Domain**: `cloudpunks.onmicrosoft.com` (TODO: Update with actual domain)

### User Management
- **Local Account Fallback**: User `jma` remains configured as a local user and will work when Entra ID is unavailable
- **Entra ID Users**: Automatically created on first login
- **Auto Groups**: Entra ID users are automatically added to:
  - `wheel` (sudo access)
  - `docker` (Docker access)
  - `networkmanager` (Network management)

### Authentication Flow
1. **PAM Stack**: Himmelblau is configured first, falling back to local authentication
2. **NSS Integration**: Resolves both Entra ID and local users
3. **First Login**: Entra ID users will be prompted for device authorization (QR code or URL)

## TODO Before Production Use

### 1. Update Entra ID Domain
Edit `services/himmelblau.nix` and replace:
```nix
domain = "cloudpunks.onmicrosoft.com";
```
with your actual Entra ID domain.

### 2. Configure Group Authorization
Add the GUIDs of Entra ID groups that should be allowed to authenticate.

To find group GUIDs:
1. Log into Azure Portal
2. Navigate to Azure Active Directory → Groups
3. Select the group and copy the "Object ID"

Then uncomment and update in `services/himmelblau.nix`:
```nix
pam_allow_groups = [ "GUID-1" "GUID-2" ];
```

### 3. Entra ID App Registration
You'll need to register an application in Azure Entra ID:
1. Go to Azure Portal → Azure Active Directory → App registrations
2. Create a new registration
3. Configure the redirect URIs as required by Himmelblau
4. Note the Application (client) ID and configure if needed

## Using Himmelblau

### After Deployment
1. Check service status:
   ```bash
   systemctl status himmelblaud himmelblaud-tasks
   ```

2. Test user resolution:
   ```bash
   getent passwd <entra-username>
   ```

3. First login will show a QR code or URL for device authorization

### Available Commands
- `aad-tool` - Azure AD management tool (available in system path)
- Check logs: `journalctl -u himmelblaud -f`

## References
- [Himmelblau GitHub](https://github.com/himmelblau-idm/himmelblau)
- [Himmelblau Documentation](https://himmelblau-idm.org/)
- [NixOS Module Options](https://github.com/himmelblau-idm/himmelblau/tree/main/nix)
