#!/bin/bash

select_keymap(){
    keymap_list=(us trq)
    select KEYMAP in "${keymap_list[@]}"; do
        if contains_element "$KEYMAP" ${keymap_list[@]}; then
            loadkeys $KEYMAP
            echo "$KEYMAP keypad has been set."
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
