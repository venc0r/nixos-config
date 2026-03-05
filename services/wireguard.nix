{ config, ... }:

{
  age.secrets.wg-private-key = {
    file = ../secrets/wg-private-key.age;
    mode = "0400";
  };
  age.secrets.wg-preshared-key = {
    file = ../secrets/wg-preshared-key.age;
    mode = "0400";
  };

  networking.wg-quick.interfaces.wg-fcos = {
    autostart = false;
    address = [ "10.30.2.5/32" ];
    dns = [ "192.168.188.1" ];
    privateKeyFile = config.age.secrets.wg-private-key.path;
    peers = [
      {
        publicKey = "dE8gX80tJ8NygZtQeHJXfpaQRJoYHjW/+Wx0bLNGjgs=";
        presharedKeyFile = config.age.secrets.wg-preshared-key.path;
        endpoint = "fcos.ws.v3nc.org:51820";
        allowedIPs = [
          "10.30.2.0/24"
          "192.168.188.0/24"
          "10.11.12.0/24"
          "0.0.0.0/0"
        ];
      }
    ];
  };
}
