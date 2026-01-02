#!/usr/bin/env bash

workspace_file=$1
remove_previous_windows=$(grep "removePreviousWindows" $workspace_file | cut -d "=" -f2-) 
reserved_workspaces=( $(grep -oP '^\[Workspace\s+\K\d+' $workspace_file) )
used_monitors=( $(grep -oP "^monitor\K\d+" $workspace_file) )

declare -a addr_arr

addr_arr_search () {
    local addr=$1
    for id in "${addr_arr[@]}"; do
        if (( $addr == $id )); then
            return 0
        fi
    done
    return 1
}

check_for_new_addr () {
    for addr in $(hyprctl clients -j | jq -r \ '.[] | .address'); do
        if ! addr_arr_search "$addr"; then
            return 1
        fi
    done
    return 0
}


launch_window () {
    local ws=$1
    shift
    local cmd=("$@")
    local -a new_addrs=()

    hyprctl dispatch exec "sh -c $(printf '%q ' "${cmd[@]}")"

    counter=0

    while check_for_new_addr; do
        sleep 0.1
        if (( counter >= 10 )); then
            echo broke out of loop
            break;
        fi
        ((counter++))    
    done

    for addr in $(hyprctl clients -j | jq -r \ '.[] | .address'); do
        if ! addr_arr_search "$addr"; then
            new_addrs+=("$addr")
        fi
    done
    
    echo new_addrs: "${new_addrs[*]}"

    for addr in "${new_addrs[@]}"; do
        hyprctl dispatch movetoworkspacesilent "$ws,address:$addr"
        echo "presumably moved $addr to workspace $ws"
    done
}


for ws in ${reserved_workspaces[@]}; do
    hyprctl clients -j |
    jq -r --argjson ws "$ws" \
       '.[] | select(.workspace.id == $ws) | .address' |
    while IFS= read -r address; do
        if [[ $remove_previous_windows == false ]]; then
            hyprctl dispatch movetoworkspacesilent $((ws + 4)),address:$address
        else
            hyprctl dispatch killwindow address:$address
        fi
    done
done

addr_arr=( $(hyprctl clients -j | jq -r \ '.[] | .address') )


for ws in "${reserved_workspaces[@]}"; do
    mapfile -t ws_lines < <(
        awk -v ws="$ws" '
        $0 ~ "^\\[Workspace " ws "\\]" { in_ws=1; next }
        /^\[/                         { in_ws=0 }
        in_ws && NF                   { print }
        ' "$workspace_file"
    )

    for cmd in "${ws_lines[@]}"; do
        echo $cmd
        launch_window "$ws" "$cmd"
        addr_arr=($(hyprctl clients -j | jq -r \ '.[] | .address'))
    done
done

for mon in ${used_monitors[@]}; do
    for ws in $(grep "^monitor${mon}=" $workspace_file| cut -d "=" -f2-); do
        hyprctl dispatch moveworkspacetomonitor $ws $mon
    done
done
