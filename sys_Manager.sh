#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

add_users() {
  file="$1"
  if [ ! -f "$file" ]; then
    echo "${RED}File not found: $file${RESET}"
    exit 1
  fi
  echo "${BLUE}Adding users from file (simulation)...${RESET}"
  while read username; do
    if [ -d "./users/$username" ]; then
      echo "${YELLOW}User $username already exists locally.${RESET}"
    else
      mkdir -p "./users/$username"
      echo "${GREEN}Created local user folder: ./users/$username${RESET}"
    fi
  done < "$file"
}

setup_projects() {
  username="$1"
  count="$2"
  base="./users/$username/projects"
  if [ ! -d "./users/$username" ]; then
    echo "${RED}User $username does not exist locally. Run add_users first.${RESET}"
    exit 1
  fi
  mkdir -p "$base"
  for ((i = 1; i <= count; i++))
  do
    proj="$base/project$i"
    mkdir -p "$proj"
    echo "Project $i created by $username on $(date)" > "$proj/README.txt"
    chmod 755 "$proj"
    chmod 640 "$proj/README.txt"
    echo "${GREEN}Created $proj${RESET}"
  done
}

sys_report() {
  outfile="$1"
  echo "${BLUE}Generating system report...${RESET}"
  echo "===== System Report =====" > "$outfile"
  echo "Date: $(date)" >> "$outfile"
  echo "" >> "$outfile"
  echo "Disk Usage:" >> "$outfile"
  df -h >> "$outfile"
  echo "" >> "$outfile"
  echo "Memory Info:" >> "$outfile"
  free -h >> "$outfile"
  echo "" >> "$outfile"
  echo "CPU Info:" >> "$outfile"
  lscpu | grep "Model name" >> "$outfile"
  echo "" >> "$outfile"
  echo "Top 5 Memory Processes:" >> "$outfile"
  ps aux --sort=-%mem | head -n 6 >> "$outfile"
  echo "" >> "$outfile"
  echo "Top 5 CPU Processes:" >> "$outfile"
  ps aux --sort=-%cpu | head -n 6 >> "$outfile"
  echo "${GREEN}Report saved to $outfile${RESET}"
}

process_manage() {
  username="$1"
  action="$2"
  echo "${BLUE}Process management (${action}) for user: $username${RESET}"
  case "$action" in
    list_zombies)
      ps -o pid,stat,cmd | grep "Z"
      ;;
    list_stopped)
      ps -o pid,stat,cmd | grep "T"
      ;;
    kill_zombies)
      echo "${YELLOW}Zombie processes cannot be killed directly. Restart parent process.${RESET}"
      ;;
    kill_stopped)
      ps -o pid,stat,cmd | grep "T" | awk '{print $1}' | xargs kill -9 2>/dev/null
      echo "${GREEN}Stopped processes killed (if any).${RESET}"
      ;;
    *)
      echo "${RED}Invalid action. Use: list_zombies, list_stopped, kill_zombies, kill_stopped${RESET}"
      ;;
  esac
}

perm_owner() {
  username="$1"
  path="$2"
  perms="$3"
  owner="$4"
  group="$5"
  if [ ! -e "$path" ]; then
    echo "${RED}Path not found: $path${RESET}"
    exit 1
  fi
  chmod -R "$perms" "$path"
  echo "${GREEN}Permissions changed for $path (ownership not changed - needs root).${RESET}"
}

show_help() {
  echo "${YELLOW}Usage:${RESET}"
  echo "./sys_manager.sh <mode> [arguments]"
  echo
  echo "Modes:"
  echo "  add_users <file>                   Create local user folders"
  echo "  setup_projects <username> <num>    Create project folders inside local user"
  echo "  sys_report <outfile>               Generate system report"
  echo "  process_manage <user> <action>     Manage running processes"
  echo "  perm_owner <user> <path> <perm> <owner> <group>  Change permissions"
  echo "  help                               Show this help menu"
  echo
  echo "${BLUE}Examples:${RESET}"
  echo "./sys_manager.sh add_users users.txt"
  echo "./sys_manager.sh setup_projects alice 5"
  echo "./sys_manager.sh sys_report report.txt"
  echo "./sys_manager.sh process_manage $(whoami) list_stopped"
  echo "./sys_manager.sh perm_owner $(whoami) ./users/alice/projects 755 $(whoami) $(whoami)"
}

case "$1" in
  add_users) shift; add_users "$@" ;;
  setup_projects) shift; setup_projects "$@" ;;
  sys_report) shift; sys_report "$@" ;;
  process_manage) shift; process_manage "$@" ;;
  perm_owner) shift; perm_owner "$@" ;;
  help|*) show_help ;;
esac

