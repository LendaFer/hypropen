#!/usr/bin/env bash

# clear the workspaces we need to use
# move windows occupying a workspace (between 1 and 4) to <workspace> + 4

for ws in 1 2 3 4; do
    hyprctl clients -j |
    jq -r --argjson ws "$ws" \
       '.[] | select(.workspace.id == $ws) | .pid' |
    while IFS= read -r pid; do
        hyprctl dispatch movetoworkspacesilent $((ws + 4)),pid:$pid
    done
done


#
hyprctl keyword windowrulev2 "workspace 1, class:^(alacritty)$"
hyprctl keyword windowrulev2 "workspace 2, class:^(chromium)$"
hyprctl keyword windowrulev2 "workspace 3, class:^(chrome-web.whatsapp.com__-Default)$"
hyprctl keyword windowrulev2 "workspace 4, class:^(chrome-music.apple.com__de_home-Default)$"


# open the desired windows

hyprctl dispatch workspace 1
hyprctl dispatch exec alacritty
hyprctl dispatch exec omarchy-launch-or-focus-webapp WhatsApp "https://web.whatsapp.com/"
hyprctl dispatch exec omarchy-launch-or-focus-webapp AppleMusic "https://music.apple.com/de/home"
hyprctl dispatch exec omarchy-launch-browser

hyprctl dispatch moveworkspacetomonitor 1 0
sleep 0.2
hyprctl dispatch moveworkspacetomonitor 3 0
sleep 0.2
hyprctl dispatch moveworkspacetomonitor 2 1
sleep 0.2
hyprctl dispatch moveworkspacetomonitor 4 1
sleep 0.2
hyprctl dispatch workspace 2
hyprctl dispatch workspace 1

sleep 1

hyprctl keyword windowrulev2 "unset,class:^(alacritty)$"
hyprctl keyword windowrulev2 "unset,class:^(chromium)$"
hyprctl keyword windowrulev2 "unset,class:^(chrome-web.whatsapp.com__-Default)$"
hyprctl keyword windowrulev2 "unset,class:^(chrome-music.apple.com__de_home-Default)$"
