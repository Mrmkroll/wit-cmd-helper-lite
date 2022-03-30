#!/usr/bin/env zsh

# Function
pause() {
    echo "\nPress any key to continue . . ."
    read -q
}

get_path(){
    if [ "$1" = "dir" ]; then
        got_ext="wbfs"
        while [ "${got_ext:l}" = "wbfs" ] || [ "${got_ext:l}" = "iso" ]
        do
            echo "Please drag and drop the disk image folder."
            read got_path
            got_path=${got_path//"'"/}
            got_ext=${got_path##*.}
        done
    else
        got_ext=""
        while [ "${got_ext:l}" != "wbfs" ] && [ "${got_ext:l}" != "iso" ]
        do
            echo "Please drag and drop the disk image."
            read got_path
            got_path=${got_path//"'"/}
            got_ext=${got_path##*.}
        done
    fi
}

extension(){
    ex=""
    while [ "$ex" != "w" ] && [ "$ex" != "i" ]
    do
        echo "Set the image file extension to be WBFS(w)/ISO(i)"
        read -k1 ex
    done
    if [ "$ex" = "w" ]; then
        ex="wbfs"
    else
        ex="iso"
    fi
}

convert(){
    if [ "${got_ext:l}" = "wbfs" ]; then
        wit copy $got_path -P -d ${got_path%.*}.iso
    else
        wit copy $got_path -P -d ${got_path%.*}.wbfs
    fi
}

extract(){
    if [ "$dn" = "\e[32mYes\e[m" ]; then
        echo "Please enter the folder name you want."
        read dir_name
        dir_path=${got_path%/*}
        wit extract $got_path -P -d $dir_path"/"$dir_name
    else
        wit extract $got_path -P -d ${got_path%.*}.tmp
    fi
}

create(){
    if [ "$fn" = "\e[32mYes\e[m" ]; then
        echo "Please enter image file name."
        read file_name
        dir_path=${got_path%/*}
        wit copy $got_path -P -d $dir_path"/"$file_name.$ex
    else
        if [ "${got_ext:l}" = "tmp" ]; then
            wit copy $got_path -P -d ${got_path%.*}.$ex
        fi
        wit copy $got_path -P -d $got_path.$ex
    fi
}

# Main
while true
do
    clear
    echo "-- Main Menu --\n"
    echo "- For the disk image -
1. Convert      --- Convert image file formats, such as WBFS to ISO and vice versa.
2. Extract      --- Extract all files in the image file while maintaining the directory tree.
3. Create       --- Create image files such as WBFS and ISO.

- Other -
4. Change Game ID       --- Change the Game ID of the image file.
5. Change Save Data     --- Change the save data when using the image file.

0. Exit"

    read -k1 input
    case "$input" in
    "1" ) # Convert
        clear
        echo "Convert image file formats. . .\n"
        get_path
        convert
        pause;;
    "2" ) # Extract
        clear
        echo "Extract all files in the image file. . .\n"
        get_path
        clear
        echo "Extract all files in the image file. . .\n\nDo you want to set a folder name?(y/N)"
        read -q && dn="\e[32mYes\e[m" || dn="\e[31mNo\e[m"
        clear
        echo "Extract all files in the image file. . .\n\nSet your own folder names: $dn"
        extract
        pause;;
    "3" ) # Create
        clear
        echo "Create image file. . .\n"
        get_path dir
        clear
        echo "Create image file. . .\n"
        extension
        clear
        echo "Create image file. . .\n\nSet extension: \e[37m$ex\e[m\nDo you want to set a image file name?(y/N)"
        read -q && fn="\e[32mYes\e[m" || fn="\e[31mNo\e[m"
        clear
        echo "Create image file. . .\n\nSet extension: \e[37m$ex\e[m\nSet image file name: $fn"
        create
        pause;;
    "4" ) # Game ID
        clear
        echo "Change Game ID. . .\n"
        get_path
        id=""
        while [ "${#id}" != "6" ]
        do
            clear
            echo "Change Game ID. . .\n\nPlease enter Game ID. (length: 6)\nex: RMCJ01"
            read id
        done
        clear
        echo "Change Game ID. . .\n\nSet Game ID: \e[37m$id\e[m"
        wit edit $got_path --disc-id $id
        pause;;
    "5" ) # Save Data
        clear
        echo "Change Save Data. . .\n"
        get_path
        sd=""
        while [ "${#sd}" != "4" ]
        do
            clear
            echo "Change Save Data. . .\n\nPlease enter Save Data ID. (length: 4)\nex: RMCJ"
        read sd
        done
        clear
        echo "Change Save Data. . .\n\nSet Save Data ID: \e[37m$sd\e[m"
        wit edit $got_path --ticket-id $sd --tmd-id $sd --tt-id $sd
        pause;;
    "0" ) # Exit
        clear
        echo "See you."
        break;;
    * ) echo "　Error: Invalid input"
        sleep 1.6;;
    esac
done