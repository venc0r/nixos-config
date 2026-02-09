{ ... }:

{
  programs.iamb = {
    enable = true;

    settings = {
      profiles.v3nc = {
        url = "https://matrix.v3nc.org";
        user_id = "@v3nc:v3nc.org";

        layout = {
          style = "config";
          tabs = [
            {
              split = [
                { window = "@sh4ke:v3nc.org"; }
              ];
            }
          ];
        };
      };

      settings = {
        notifications = {
          enabled = true;
        };
      };
    };
  };
}
