#!/bin/bash
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
reset=$(tput sgr0)

add_users() {
    if [ ! -f "$1" ]; then
        echo "${red}File not found!${reset}"
        exit 1
    else
        mkdir -p users
        while IFS= read -r name; do
            if [ -z "$name" ]; then
                continue
            else
                if [ -d "users/$name" ]; then
                    echo "${yellow}$name exists${reset}"
                else
                    mkdir "users/$name"
                    echo "${green}Created users/$name${reset}"
                fi
            fi
        done < "$1"
    fi
}

setup_projects() {
    if [ ! -d "users/$1" ]; then
        echo "${red}User not found!${reset}"
        exit 1
    else
        mkdir -p "users/$1/projects"
        for i in $(seq 1 "$2"); do
            p="users/$1/projects/project$i"
            mkdir -p "$p"
            echo "Project $i by $1 on $(date)" > "$p/README.txt"
            echo "${green}Made project$i for $1${reset}"
        done
    fi
}

sys_report() {
    if [ -z "$1" ]; then
        echo "${red}Please provide a filename for the report!${reset}"
        exit 1
    else
        echo "System Report - $(date)" > "$1"
        echo "Disk:" >> "$1"
        df -h >> "$1"
        echo "Memory:" >> "$1"
        free -h >> "$1"
        echo "CPU:" >> "$1"
        lscpu | grep "Model name" >> "$1"
        echo "Top Memory:" >> "$1"
        ps aux --sort=-%mem | head -n 6 >> "$1"
        echo "Top CPU:" >> "$1"
        ps aux --sort=-%cpu | head -n 6 >> "$1"
        echo "${green}Saved to $1${reset}"
    fi
}

process_manage() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "${red}Usage: process_manage <user> <action>${reset}"
        exit 1
    else
        case "$2" in
            list_zombies)
                ps -u "$1" -o pid,stat,cmd | grep "Z"
                ;;
            list_stopped)
                ps -u "$1" -o pid,stat,cmd | grep "T"
                ;;
            kill_stopped)
                pids=$(ps -u "$1" -o pid,stat | grep "T" | awk '{print $1}')
                if [ -n "$pids" ]; then
                    echo "$pids" | xargs kill -9 2>/dev/null
                    echo "${green}Killed${reset}"
                else
                    echo "${yellow}No stopped processes found for $1${reset}"
                fi
                ;;
            *)
                echo "${yellow}Use: list_zombies, list_stopped, kill_stopped${reset}"
                ;;
        esac
    fi
}

perm_owner() {
    if [ ! -e "$2" ]; then
        echo "${red}Path not found!${reset}"
        exit 1
    else
        chmod -R "$3" "$2"
        echo "${green}Changed to $3 for $2${reset}"
    fi
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
    add_users)
        shift
        add_users "$@"
        ;;
    setup_projects)
        shift
        setup_projects "$@"
        ;;
    sys_report)
        shift
        sys_report "$@"
        ;;
    process_manage)
        shift
        process_manage "$@"
        ;;
    perm_owner)
        shift
        perm_owner "$@"
        ;;
    help|*)
        show_help
        ;;
esac
