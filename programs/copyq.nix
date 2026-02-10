{ config, pkgs, ... }:

{
  xdg.configFile."copyq/copyq.conf".source = ../dotfiles/copyq/copyq.conf;
  xdg.configFile."copyq/copyq-commands.ini".source = ../dotfiles/copyq/copyq-commands.ini;
  xdg.configFile."copyq/copyq-filter.ini".source = ../dotfiles/copyq/copyq-filter.ini;
  xdg.configFile."copyq/copyq-monitor.ini".source = ../dotfiles/copyq/copyq-monitor.ini;
  xdg.configFile."copyq/copyq_tabs.ini".source = ../dotfiles/copyq/copyq_tabs.ini;
}
