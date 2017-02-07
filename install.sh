#!/bin/bash

cols=$(tput cols)
lines=$(tput lines)
#mirror_file="/etc/pacman.d/mirrorlist"
mirror_file="/home/alish/mirrorlist"

select_keymap(){
    selected_keymap=$(whiptail --title "Test" --radiolist "Choose:"  20 78 15 \
        "us" "" off \
        "trq" "" on 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        loadkeys "$selected_keymap"
        main_menu
    else
        main_menu
    fi
}

select_mirrorlist(){
    selected_countries=($(whiptail --title "Test" --checklist --separate-output "Choose:" 20 78 15 \
    "Turkey" "" on \
    "Worldwide" "" on 3>&1 1>&2 2>&3))
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        cp "$mirror_file" "$mirror_file"".orgin"
        pacman -Sy --noconfirm pacman-mirrorlist
        for selected_country in "${selected_countries[@]}"; do
            awk -v GG="$selected_country" '{if(match($0,GG) != "0")AA="1";if(AA == "1"){if( length($2) != "0"  )print substr($0,2) ;else AA="0"} }' "$mirror_file"".pacnew" >> "$mirror_file"".country"
            echo "">> "$mirror_file"".country"
            echo $selected_country
        done
        rankmirrors "$mirror_file"".country" > "$mirror_file"
        main_menu
    else
        main_menu
    fi
}

main_menu(){
    selected_menu=$(whiptail --title "Main Menu" --menu "Choose a progcess" $lines $cols 16 \
    "Keymap Chooser" "Set keyboard" \
    "Mirror Country" "Set local mirror repository" \
    "Disk Manager" "Set disk configuration" 3>&1 1>&2 2>&3)

case $selected_menu in
    "Keymap Chooser" )
        select_keymap;;
    "Mirror Country" )
        select_mirrorlist;;
    "Disk Manager" )
        select_disk;;
esac
}

create_disk_list(){
unset $disk_list
i=0
disks=($(lsblk -io KNAME | grep 'sd[a-z]'))
for ddd in ${disks[@]} ;do
    disk_list[i]="/dev/"$ddd
    type="$(lsblk --noheadings -d -o TYPE,FSTYPE,SIZE,LABEL,MODEL,MOUNTPOINT "${disk_list[i]}")"
    i=$((i+1))
    disk_list[i]=$type
    i=$((i+1))
done
}

select_disk(){
create_disk_list
selected_disk=$(whiptail --title "Disk Manager" --menu "Slect a disk or partition for configuration" $lines $cols 16 "${disk_list[@]}" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    selected_disk_type="$(lsblk --noheadings -d -o TYPE "$selected_disk")"
    if [ $selected_disk_type = "disk" ]; then
        disk_manager
    else
        format_manager
    fi
else
    main_menu
fi
}

disk_manager(){
    selected_disk_manager=$(whiptail --title "Partition Manager" --menu "Choose a partition Manager for configuration the $selected_disk" $lines $cols 16 \
    "cfdisk" "for MBR and GPT partitions" \
    "cgdisk" "for GPT partitions" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $selected_disk_manager in
        "cfdisk" )
            cfdisk $selected_disk;;
        "cgdisk" )
            cgdisk $selected_disk;;
        esac
        select_disk
    else
        select_disk
    fi

}

format_manager(){
    selected_format=$(whiptail --title "Format Manager" --menu "Format the $selected_disk partition" $lines $cols 16 \
    "none" "Do not format" \
    "fat32" "efi boot partition" \
    "ext4" "fourth extended filesystem" \
    "swap" "swap partition" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $selected_format in
        "fat32" )
            mkfs.fat -F32 $selected_disk;;
        "ext4" )
            mkfs.ext4 -F $selected_disk;;
        "swap" )
            mkswap -f $selected_disk;;
        esac
        mount_manager
    else
        select_disk
    fi
}

mount_manager(){
    selected_mountpoint=$(whiptail --title "Mount Manager" --menu "mount the $selected_disk" $lines $cols 16 \
    "none" "Do not mount" \
    "/mnt" "for root partition" \
    "/mnt/boot" "for efi or grub boot partition" \
    "/mnt/home" "for user home directory" \
    "swap" "for swap" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        case $selected_mountpoint in
        "/mnt" )
            mount $selected_disk /mnt;;
        "/mnt/boot" )
            mkdir -p /mnt/boot
            mount $selected_disk /mnt/boot;;
        "/mnt/home" )
            mkdir -p /mnt/home
            mount $selected_disk /mnt/home;;
        "swap" )
            swapon $selected_disk;;
        esac
        select_disk
    else
        main_menu
    fi

}

contains_element() {
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

main_menu

