{ pkgs }:

{
  volume-brightness = import ../scripts/volume-brightness.nix { inherit pkgs; };
  blurlock = import ../scripts/blurlock.nix { inherit pkgs; };
  block-volume = import ../scripts/block-volume.nix { inherit pkgs; };
  block-battery = import ../scripts/block-battery.nix { inherit pkgs; };
  block-cpu = import ../scripts/block-cpu.nix { inherit pkgs; };
  block-memory = import ../scripts/block-memory.nix { inherit pkgs; };
  block-disk = import ../scripts/block-disk.nix { inherit pkgs; };
  block-temperature = import ../scripts/block-temperature.nix { inherit pkgs; };
  block-bandwidth = import ../scripts/block-bandwidth.nix { inherit pkgs; };
  zen-profile-selector = import ../scripts/zen-profile-selector.nix { inherit pkgs; };
  tmux-cht = import ../scripts/tmux-cht.nix { inherit pkgs; };
  tmux-cal = import ../scripts/tmux-cal.nix { inherit pkgs; };
  tmux-sessionizer = import ../scripts/tmux-sessionizer.nix { inherit pkgs; };
  kube-schema-gen = import ../scripts/kube-schema-gen.nix { inherit pkgs; };
  tetra = import ../scripts/tetra.nix { inherit pkgs; };
}
