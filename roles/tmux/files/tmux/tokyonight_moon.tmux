#!/usr/bin/env bash

# ── TokyoNight Moon ────────────────────────────────────────────────────────────

# Color palette
bg_dark="#1e2030"     # main status bar background
bg_mid="#3b4261"      # secondary background (active window tab)
fg_blue="#82aaff"     # primary foreground / accent
fg_muted="#828bb8"    # inactive window tabs
fg_orange="#ffc777"   # prefix-highlight accent

# Script paths
scripts="$HOME/.config/tmux/scripts"

# ── Mode & Message ─────────────────────────────────────────────────────────────

tmux set -g mode-style            "fg=${fg_blue},bg=${bg_mid}"
tmux set -g message-style         "fg=${fg_blue},bg=${bg_mid}"
tmux set -g message-command-style "fg=${fg_blue},bg=${bg_mid}"

# ── Pane Borders ───────────────────────────────────────────────────────────────

tmux set -g pane-border-style        "fg=${bg_mid}"
tmux set -g pane-active-border-style "fg=${fg_blue}"

# ── Status Bar ─────────────────────────────────────────────────────────────────

tmux set -g status         "on"
tmux set -g status-justify "left"
tmux set -g status-style   "fg=${fg_blue},bg=${bg_dark}"

tmux set -g status-left-length  "100"
tmux set -g status-right-length "200"
tmux set -g status-left-style   NONE
tmux set -g status-right-style  NONE

# Left: session name badge
tmux set -g status-left "#[fg=${bg_dark},bg=${fg_blue},bold] #S #[default]"

# Right: prefix indicator + system stats
status_right=""
status_right+="#[fg=${fg_blue},bg=${bg_dark}] #{prefix_highlight} "
status_right+="#[fg=${fg_muted},bg=${bg_dark}]"
status_right+=" CPU: #(${scripts}/cpu.sh) "
status_right+="#[fg=${fg_blue},bg=${bg_mid}]"
status_right+=" RAM: #(${scripts}/ram.sh) "
status_right+="#[fg=${bg_dark},bg=${fg_blue},bold]"
status_right+=" Disk: #(${scripts}/disk.sh) "

tmux set -g status-right "$status_right"

# ── Window Tabs ────────────────────────────────────────────────────────────────

tmux setw -g window-status-activity-style "underscore,fg=${fg_muted},bg=${bg_dark}"
tmux setw -g window-status-separator      ""
tmux setw -g window-status-style          "NONE,fg=${fg_muted},bg=${bg_dark}"

tmux setw -g window-status-format         " #I  #W #F "

tmux setw -g window-status-current-format "#[fg=${fg_blue},bg=${bg_mid},bold] #I  #W #F #[default]"

# ── Plugin: tmux-prefix-highlight ─────────────────────────────────────────────

tmux set -g @prefix_highlight_output_prefix "#[fg=${fg_orange},bg=${bg_dark}]"
tmux set -g @prefix_highlight_output_suffix "#[default]"
