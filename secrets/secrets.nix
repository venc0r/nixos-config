let
  # Host SSH public keys — used by agenix to decrypt secrets at boot.
  # To get a host key: cat /etc/ssh/ssh_host_ed25519_key.pub
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDQa+CWAzmqryMRUj0dtcRyjOd539T6iJMMLQZq4XUd root@nixos";
  # cubi = "ssh-ed25519 <REPLACE with output of: cat /etc/ssh/ssh_host_ed25519_key.pub on cubi>";

  # Your personal SSH key — lets you edit/re-encrypt secrets from any machine.
  jma = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPuI7XTWodjRsAb4sNpPk/hlrVUlcWco8O/igRvIDFk2 jma";

  allHosts = [ nixos /* cubi */ jma ];
in
{
  "wg-private-key.age".publicKeys = allHosts;
  "wg-preshared-key.age".publicKeys = allHosts;
}
