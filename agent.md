# agent.md — nixos-config

Multi-platform Nix flake: NixOS desktops, nix-darwin MacBook, home-manager-only WSL.

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | All outputs: `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations` |
| `hosts/common.nix` | Shared NixOS system config |
| `hosts/home-common.nix` | Shared home-manager config (Linux + macOS) |
| `hosts/home.nix` | Linux-only home-manager (i3, X11, GUI) |
| `hosts/darwin/` | `configuration.nix` (nix-darwin system) + `home.nix` (macOS home-manager) |
| `hosts/nixos/`, `hosts/cubi/` | Per-machine NixOS config + hardware |
| `hosts/home-wsl.nix` | CLI-only home-manager for Arch WSL |
| `programs/`, `services/`, `scripts/` | Reusable modules, each one program/service/script |
| `pkgs/` | Local derivations for software missing from nixpkgs |
| `dotfiles/` | Config trees referenced by home-manager (nvim, copyq) |

## Apply

```sh
sudo darwin-rebuild switch --flake '.#MacBook-Pro-von-Jorg'   # macOS
sudo nixos-rebuild switch --flake .#nixos                     # NixOS (arm)
sudo nixos-rebuild switch --flake .#cubi                      # NixOS (x86)
home-manager switch --flake .#jma@wsl                         # Arch WSL
```

`.#MacBook-Pro-von-Jorg-upgrade` is the same darwin config with homebrew `autoUpdate`/`upgrade`/`cleanup` forced on — use when you want brew casks bumped.

## Gotchas

- **Flakes only see git-tracked files.** New files (a `pkgs/` derivation, a new module) must be `git add`ed before any rebuild or `nix eval`, otherwise the config evaluates without them and fails with a confusing "path does not exist".
- **`nixos-config-private` is a sibling repo on disk**, not a URL: clone to `~/Documents/git/forgejo/nixos-config-private`. Bootstrap without it by pointing the input at a stub dir — see the comment in `flake.nix`.
- **WSL switch needs both overrides** (nixpkgs + private input), and a corporate proxy kills tarball fetches while `git clone` still works. `vault` always builds from source there and wants ~10GB RAM.
- **`permittedInsecurePackages` lives in three places** and they must stay in sync: `flake.nix` (WSL), `hosts/common.nix` (NixOS), `hosts/darwin/configuration.nix`. Entries are name-exact including the Python version, so a nixpkgs bump that moves `python3.13` → `python3.14` breaks all three at once.
- **skhd config changes do not take effect on rebuild alone**: `launchctl kickstart -k gui/$UID/org.nixos.skhd`.
- **macOS TCC grants are tied to the signed binary.** Nix ad-hoc-signs Darwin binaries, so every store path change drops the grant; a running tmux server keeps the stale attribution until `tmux kill-server`.
- **LAN hosts unreachable from nix apps** is a signing problem, not a network one — see "Local Network access" below. Do not go looking at the VPN.

## Adding a package

Prefer nixpkgs. If the software is not packaged, add `pkgs/<name>/default.nix` and reference it from the consuming host with `(callPackage ../../pkgs/<name> { })`.

`pkgs/flux-local` is the plain case: a PyPI `buildPythonApplication` wrapped so `kustomize`/`helm`/`flux` are on PATH. Upstream sunset it at 8.4.0 (prints a deprecation banner on every run) in favour of `flate`, which nixpkgs does not have yet - bump to `flate` once it lands.

`pkgs/meshcmd` is the working example: upstream ships no standalone build, so the derivation reproduces what a MeshCentral server does at download time (merge `modules_meshcmd/*.js` into `meshcmd.js`, append it to the platform `meshagent_*` binary with a length and marker GUID). It sets `dontFixup = true` on purpose — the payload sits past the end of the macOS code signature, and any nix re-sign or strip would append bytes after the trailing GUID so meshcmd could no longer find its own payload. `codesign -v` reporting `main executable failed strict validation` is expected and does not stop it running.

## Local Network access

macOS keys its Local Network privacy grant to an app's **code-signing identity**. Nix ad-hoc-signs every Darwin bundle, so that identity is a bare cdhash which changes on every rebuild and silently takes the grant with it ([nixpkgs#375072](https://github.com/NixOS/nixpkgs/issues/375072), still open). Zen compounds it by shipping no `NSLocalNetworkUsageDescription`, so it never even appears in the permission list ([zen-browser/desktop#13860](https://github.com/zen-browser/desktop/issues/13860)).

**Symptom.** Apple-signed apps (Safari) reach the LAN; everything from nix does not. `arp -an` resolves the target, `ping` times out silently, TCP fails with `No route to host`, internet still works. The routing table is correct and innocent — as is Firezone, whose Internet Resource already excludes `192.168/16`, `10/8`, `172.16/12`, `169.254/16` and `100.64/10`.

**Fix.** `home.activation.signAppsForLocalNetwork` in `hosts/darwin/home.nix` runs after `copyApps`, patches `NSLocalNetworkUsageDescription` into each bundle's Info.plist, and re-signs with a self-signed certificate. Signing with a real certificate makes the identity `identifier + certificate leaf` instead of a cdhash, which survives rebuilds. `copyApps` rsyncs with `--checksum`, so it restores the pristine store bundle on every activation and the hook re-signs it every time — that is intended, not waste.

Bootstrap once with `macos-codesign-cert` (`scripts/macos-codesign-cert.nix`), then rebuild, then grant in System Settings → Privacy & Security → Local Network. Verify with `codesign -dv --verbose=2` on the bundle: `Authority=Nix Local Code Signing` and `Info.plist entries=N` (rather than `not bound`) mean it took.

Traps, all of which cost time once already:

- `security import` rejects an empty PKCS#12 password **and** only understands a SHA-1 MAC, while OpenSSL 3 defaults to SHA-256. Needs `-macalg sha1` plus a real password, otherwise: `SecKeychainItemImport: MAC verification failed during PKCS12 import (wrong password?)`.
- The certificate must be a trusted root, or `codesign` cannot build a chain to it. Trust is scoped to `-p codeSign` so it signs nothing else.
- First signing run pops a keychain dialog — "Always Allow", or every later activation blocks on it.
- Re-signing changes the binary, so an app's **other** TCC grants reset once, then stay stable.
- Replacing a running process's executable on disk costs it the grant. A no-op `darwin-rebuild switch` is enough: `copyApps` restores the pristine bundle and the hook re-signs it, which strands the Alacritty that is already running.

### tmux

Local Network privacy is **not TCC** — it is a packet filter in Network Extension, so `tccutil` cannot reset it and there is no way to switch it off. It attributes every connection to the **responsible process pid recorded when the process was spawned**. A tmux server inherits the pid of the terminal that started it, so when that terminal exits every pane loses LAN access while the server keeps running. The log says it plainly:

```
UserEventAgent: Failed to get the signing identifier for <pid>: No such process
```

This half is not nix-specific — Homebrew and source builds behave identically, and only Apple's own `/usr/bin` binaries are exempt (`/usr/bin/curl` works in a pane where nix `curl` gets `No route to host` in 3ms).

**Fix, two halves, both required:**

1. `pkgs/tmux-localnetwork` links an `Info.plist` into the binary (`-sectcreate __TEXT __info_plist`, bundle id `org.venc0r.tmux`) so tmux has an identity at all, and `home.activation.signTmuxForLocalNetwork` signs a copy in `~/.local/bin` — ahead of the nix profile in PATH. A store-path stamp guards the copy, because replacing the inode would strand the running server (see the trap above).
2. `launchd.agents.tmux-server` starts `tmux -D` (foreground server, `exit-empty` off). A launchd-spawned process is its own responsible process, which is what makes the grant stick; the identity from step 1 is what it sticks *to*. Identity alone is not enough — verified, the pid attribution still wins.

`KeepAlive = true` is deliberate: if the server dies, the next `tmux` client forks a replacement off the terminal and silently restores the broken arrangement.

Check which kind of server is running — anything else means a client started it:

```
launchctl list | grep tmux-server     # pid must match
ps -o args= -p <pid>                  # /Users/.../.local/bin/tmux -D
```

Switching over needs one `tmux kill-server` (detaching is not enough) and launchd fail-loops at ~10s until the old server frees the socket. Snapshot sessions first with `~/bin/tmux-snapshot.sh`, which writes a restore script for sessions, windows, panes and cwds — programs running in the panes are not restored.

Two traps, both already paid for:

- **Run the switch outside tmux when, and only when, the agent's plist changes.** `processAgent` compares the rendered plist with the installed one (`cmp -s`) and skips untouched agents, so ordinary rebuilds — package bumps, `flake.lock`, other modules — are safe from inside tmux. A **tmux version bump is also safe**: the plist names the fixed path `~/.local/bin/tmux`, not a store path, so its content does not move. Only editing the `launchd.agents.tmux-server` block (`ProgramArguments`, `KeepAlive`, `EnvironmentVariables`) rewrites it, and then `launchctl bootout --wait` kills the server the rebuild is running in, which kills the rebuild. It dies *after* the system profile is switched but *before* the new plist is installed and bootstrapped — half-applied, no server, no loaded job — so the recovery is a second switch from a plain terminal, then `~/bin/tmux-restore.sh`. `KeepAlive` does not save you here: it only applies while the job is loaded. Pre-flight when unsure:

  ```sh
  git diff -- hosts/darwin/home.nix | grep -n "tmux-server" -A6
  ```
- **launchd passes no locale.** Panes inherit it, and under `LC_CTYPE=C` zsh miscounts the width of the prompt's multi-byte glyphs, so the cursor sits right of the prompt and the right-hand segment lands in the wrong column. `EnvironmentVariables.LANG` on the agent fixes it; `PATH` needs no such help because the login shell rebuilds it. Only a server restart propagates a change, since the server's environment is fixed at start.

## Conventions

- Nix formatting: 2-space indent, `with pkgs;` inside package lists, one blank line + comment per logical group.
- Every module gets a top-of-file comment saying what it covers and where its counterpart lives.
- Commits: Conventional Commits with a scope when the change is host- or program-specific (`feat(nixos):`, `fix(zsh):`, `fix(git):`).
- Work goes straight to `main` on `git@github.com:venc0r/nixos-config.git` — no PRs, no merge commits in history.
