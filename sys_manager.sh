#!/bin/bash
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

add_users() {
    [ ! -f "$1" ] && echo "${red}File not found!${reset}" && exit 1
    mkdir -p users
    while IFS= read -r name; do
        [ -z "$name" ] && continue
        [ -d "users/$name" ] && echo "${yellow}$name exists${reset}" || { mkdir "users/$name"; echo "${green}Created users/$name${reset}"; }
    done < "$1"
}

setup_projects() {
    [ ! -d "users/$1" ] && echo "${red}User not found!${reset}" && exit 1
    mkdir -p "users/$1/projects"
    for i in $(seq 1 "$2"); do
        p="users/$1/projects/project$i"
        mkdir -p "$p"
        echo "Project $i by $1 on $(date)" > "$p/README.txt"
        echo "${green}Made project$i for $1${reset}"
    done
}

sys_report() {
    echo "System Report - $(date)" > "$1"
    echo "Disk:" >> "$1"; df -h >> "$1"
    echo "Memory:" >> "$1"; free -h >> "$1"
    echo "CPU:" >> "$1"; lscpu | grep "Model name" >> "$1"
    echo "Top Memory:" >> "$1"; ps aux --sort=-%mem | head -n 6 >> "$1"
    echo "Top CPU:" >> "$1"; ps aux --sort=-%cpu | head -n 6 >> "$1"
    echo "${green}Saved to $1${reset}"
}

process_manage() {
    case "$2" in
        list_zombies) ps -u "$1" -o pid,stat,cmd | grep "Z";;
        list_stopped) ps -u "$1" -o pid,stat,cmd | grep "T";;
        kill_stopped) ps -u "$1" -o pid,stat | grep "T" | awk '{print $1}' | xargs kill -9 2>/dev/null; echo "${green}Killed${reset}";;
        *) echo "${yellow}Use: list_zombies, list_stopped, kill_stopped${reset}";;
    esac
}

perm_owner() {
    [ ! -e "$2" ] && echo "${red}Path not found!${reset}" && exit 1
    chmod -R "$3" "$2"
    echo "${green}Changed to $3 for $2${reset}"
}

show_help() {
    echo "${yellow}Usage:${reset} ./sys_manager.sh <mode> [args]"
    echo " add_users <file>"
    echo " setup_projects <user> <num>"
    echo " sys_report <file>"
    echo " process_manage <user> <action>"
    echo " perm_owner <user> <path> <perm>"
    echo " help"
}

case "$1" in
    add_users) shift; add_users "$@";;
    setup_projects) shift; setup_projects "$@";;
    sys_report) shift; sys_report "$@";;
    process_manage) shift; process_manage "$@";;
    perm_owner) shift; perm_owner "$@";;
    help|*) show_help;;
esac
