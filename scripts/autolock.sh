#!/usr/bin/env bash

# Only exported variables can be used within the timer's command.
PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"
export PRIMARY_DISPLAY

# Run xidlehook
xidlehook \
  `# Don't lock when there's a fullscreen application` \
  --not-when-fullscreen \
  `# Don't lock when there's audio playing` \
  --not-when-audio \
  `# Dim the screen after 60 seconds, undim if user becomes active` \
  --timer 60 \
    "xrandr --output \"$PRIMARY_DISPLAY\" --brightness .1" \
    "xrandr --output \"$PRIMARY_DISPLAY\" --brightness 1" \
  `# Undim & lock after 10 more seconds` \
  --timer 10 \
    "xrandr --output \"$PRIMARY_DISPLAY\" --brightness 1; '/home/$USER/.dotfiles/scripts/lock.sh'" \
    '' \
  `# Finally, suspend an hour after it locks` \
  --timer 3600 \
    'systemctl suspend' \
    ''
