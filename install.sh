#!/bin/bash

select_keymap(){
    keymap_list=(us trq)
    echo $'\n'"Select your keymap:"    
    select KEYMAP in "${keymap_list[@]}"; do
        if contains_element "$KEYMAP" ${keymap_list[@]}; then
            loadkeys "$KEYMAP"
            break
        else
            echo "Invalid option"
        fi
    done
}

select_mirrorlist(){
    local MIRRORLIST="/etc/pacman.d/mirrorlist"
    country_list=(Turkey)
    echo $'\n'"Select your mirror country:"    
    select COUNTRY in "${country_list[@]}"; do
        if contains_element "$COUNTRY" ${country_list[@]}; then
            pacman -Sy --noconfirm pacman-mirrorlist
            cp "$MIRRORLIST" "$MIRRORLIST"".orgin"
            awk -v GG="$COUNTRY" '{if(match($0,GG) != "0")AA="1";if(AA == "1"){if( length($2) != "0"  )print substr($0,2) ;else AA="0"} }' "$MIRRORLIST"".pacnew" > "$MIRRORLIST"".country"
            rankmirrors "$MIRRORLIST"".country" > "$MIRRORLIST"
            break
        else
            echo "Invalid option"
        fi
    done
}

contains_element() {
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}


select_keymap
select_mirrorlist
