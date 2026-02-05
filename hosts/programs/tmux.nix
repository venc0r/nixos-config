{ lib, config, pkgs, ... }:
let

in
{
  programs.tmux = {
    enable = true;
    clock24 = true;
    baseIndex = 1;
    escapeTime = 20;
    historyLimit = 10240;
    keyMode = "vi";
    mouse = false;
    terminal = "screen-256color";
    prefix = "M-s";

    extraConfig = ''
      # Start windows and panes at 1
      set -g status on
      setw -g pane-base-index 1

      # nvim optimization
      set-option -sa terminal-overrides ',xterm*:Tc'

      set-option -g renumber-windows on
      set-option -g focus-events on

      # Prefix key
      bind-key M-s send-prefix

      # Split binds
      bind-key | split-window -h -c "#{pane_current_path}"
      bind-key - split-window -v -c "#{pane_current_path}"

      # New window in current path
      bind-key c new-window -c "#{pane_current_path}"
      bind-key C new-window -c "#{pane_current_path}"\; \
          split-window -h -c "#{pane_current_path}" -p 80\; \
          split-window -h -c "#{pane_current_path}" -p 25\; \
          split-window -v -c "#{pane_current_path}" \; \
          select-pane -t 1\; \
          split-window -v -c "#{pane_current_path}" \; \
          select-pane -t 3

      # Reload config
      bind-key R source-file $HOME/.config/tmux/tmux.conf \; display-message "Reloaded!"

      # Clear scrollback buffer
      bind-key b clear-history \; display-message "History cleared!"

      # Custom script bindings (note: scripts need to be in PATH)
      bind-key i run-shell "tmux neww tmux-cht.sh"
      bind-key y run-shell "tmux neww tmux-cal.sh"
      bind-key g run-shell "tmux neww tmux-sessionizer.sh"
      bind-key t display-popup -E -h 95% -w 95% "tmux new-session -A -s jump1"
      bind-key n display-popup -E -h 95% -w 95% "tmux new-session -A -s jump2"
      bind-key m display-popup -E -h 100% -w 100% "tmux new-session -A -s iamb"

      # Vim-like copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${pkgs.xclip}/bin/xclip -in -selection clipboard'
      bind-key v paste-buffer

      # Vim-like pane switching
      bind-key -r C-^ switch-client -l
      bind-key k select-pane -U
      bind-key j select-pane -D
      bind-key h select-pane -L
      bind-key l select-pane -R

      # Vim-like pane resizing
      bind-key -r C-k resize-pane -U
      bind-key -r C-j resize-pane -D
      bind-key -r C-h resize-pane -L
      bind-key -r C-l resize-pane -R

      # Unbind arrow keys
      unbind Up
      unbind Down
      unbind Left
      unbind Right
      unbind C-Up
      unbind C-Down
      unbind C-Left
      unbind C-Right

      # Status bar styling (Gruvbox)
      set-option -g status-right "#[fg=#fbf1c7]%d %b %Y %H:%M:%S"
      set-option -g status-interval 1
      set-option -g status-style bg='#665c54',fg='#ebdbb2'

      # Window status styling
      set-window-option -g window-status-format '#[fg=#fbf1c7]#[bg=#98971a] #I#[fg=#3e3e3e] #[bg=#b8bb26] #W '
      set-window-option -g window-status-current-format '#[bg=#3c3836]#[fg=#928374] #I #[bg=#282828]#[fg=#b8bb26] #[bg=colour234]#W#[bg=colour235]#[fg=#b8bb26]#F#[bg=colour236] '
    '';
  };
}
