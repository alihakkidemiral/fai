#!/bin/bash

select_keymap(){
    selected_keymap=$(whiptail --title "Test" --radiolist "Choose:"  20 78 15 \
        "us" "" off \
        "trq" "" on 3>&1 1>&2 2>&3)
    loadkeys "$selected_keymap"
}

select_mirrorlist(){
    pacman -Sy --noconfirm pacman-mirrorlist
    MIRRORLIST="/etc/pacman.d/mirrorlist"
    cp "$MIRRORLIST" "$MIRRORLIST"".orgin"
    selected_countries=$(whiptail --title "Test" --checklist --separate-output "Choose:"  20 78 15 \
        "Turkey" "" on \
        "Worldwide" "" off 3>&1 1>&2 2>&3)
    for country in ${selected_countries[@]}; do
        awk -v GG="$country" '{if(match($0,GG) != "0")AA="1";if(AA == "1"){if( length($2) != "0"  )print substr($0,2) ;else AA="0"} }' "$MIRRORLIST"".pacnew" >> "$MIRRORLIST"".country"
        echo "">> "$MIRRORLIST"".country"
    done
    rankmirrors "$MIRRORLIST"".country" > "$MIRRORLIST"
}

contains_element() {
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

select_keymap
select_mirrorlist
