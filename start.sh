#!/usr/bin/env bash
# Cybersecurity Lab Menu (animated, fixed)

# ---------- Colors (use printf-friendly $'...' syntax) ----------
if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'
  CYAN=$'\033[0;36m'
  RESET=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; RESET=""
fi

clear
printf "%s" "$RED"
figlet -f slant "Cybersecurity Lab"
printf "%s\n" "$RESET"

# ---------- Typing effect ----------
type_writer() {
  local text="$1" delay="${2:-0.03}"
  local i
  for ((i=0; i<${#text}; i++)); do
    printf "%s" "${text:i:1}"
    sleep "$delay"
  done
  printf "\n"
}

# ---------- Spinner (duration in seconds) ----------
spinner() {
  local msg="$1" dur="${2:-2}"
  local -a spin=( '|' '/' '-' '\' )
  local i=0
  local start=$SECONDS
  local end=$(( start + dur ))
  tput civis 2>/dev/null || true  # hide cursor if possible
  printf "[ ] %s" "$msg"
  while (( SECONDS < end )); do
    printf "\r[%s] %s" "${spin[i%4]}" "$msg"
    sleep 0.1
    ((i++))
  done
  printf "\r%s[✔]%s %s\n" "$GREEN" "$RESET" "$msg"
  tput cnorm 2>/dev/null || true  # restore cursor
}

# Ensure cursor is restored on exit even if interrupted
cleanup() { tput cnorm 2>/dev/null || true; }
trap cleanup EXIT INT TERM

# ---------- Startup animation ----------
type_writer "${YELLOW}Initializing Cybersecurity Lab...${RESET}" 0.04
spinner "Loading modules" 2
spinner "Preparing environment" 2
type_writer "${GREEN}System Ready!${RESET}" 0.03
printf "\n"

# ---------- Menu ----------
printf "%sWhat do you want to do?%s\n" "$CYAN" "$RESET"

# Colored prompt for `select`
PS3="${CYAN}#? ${RESET}"

options=(
  "Start WiFi deauther script"
  "Start Fluxion"
  "Start Camera"
  "Anonymous"
  "Try FM Transmitter"
  "Try Bluetooth DOS Attack"
  "Advanced Scanner"
"Exit"
)

select action in "${options[@]}"; do
  case "$action" in
    "Start WiFi deauther script")
      type_writer "${YELLOW}Starting WiFi Deauther...${RESET}" 0.02
      "$PWD/scripts/start-mon.sh"
      "$PWD/scripts/scan.sh"
      "$PWD/scripts/attack.sh"
      printf "%s[✔]%s Completed!\n" "$GREEN" "$RESET"
      break
      ;;
    "Start Fluxion")
      type_writer "${YELLOW}Launching Fluxion...${RESET}" 0.02
      "$PWD/wlan/fluxion/fluxion.sh" -i
      printf "%s[✔]%s Fluxion started!\n" "$GREEN" "$RESET"
      break
      ;;
    "Start Camera")
      type_writer "${YELLOW}Starting Camera...${RESET}" 0.02
      cd "$PWD/scripts" || { printf "%s[!]%s Cannot cd to scripts\n" "$RED" "$RESET"; break; }
      ./start-capture.sh
      printf "%s[✔]%s Camera running!\n" "$GREEN" "$RESET"
      break
      ;;
    "Anonymous")
      type_writer "${YELLOW}Switching to Anonymous mode...${RESET}" 0.02
      "$PWD/scripts/anon.sh"
      printf "%s[✔]%s Done!\n" "$GREEN" "$RESET"
      break
      ;;
    "Try FM Transmitter")
      type_writer "${YELLOW}Starting FM Transmitter...${RESET}" 0.02
      cd "$PWD/fm_transmitter" || { printf "%s[!]%s Cannot cd to fm_transmitter\n" "$RED" "$RESET"; break; }
      ./start.sh
      printf "%s[✔]%s Done!\n" "$GREEN" "$RESET"
      break
      ;;
    "Try Bluetooth DOS Attack")
      type_writer "${YELLOW}Launching Bluetooth DOS...${RESET}" 0.02
      cd "$PWD/bt/DOS-Atack" || { printf "%s[!]%s Cannot cd to bt/DOS-Atack\n" "$RED" "$RESET"; break; }
      python3 start.py
      printf "%s[✔]%s Done!\n" "$GREEN" "$RESET"
      break
      ;;
    "Advanced Scanner")
      type_writer "${YELLOW}Launching Advanced Scanner...${RESET}" 0.02
      cd "$PWD/scanner/" || { printf "%s[!]%s Cannot cd to scanner\n" "$RED" "$RESET"; break; }
      ./scanner wlan0 -n -t 10
      printf "%s[✔]%s Done!\n" "$GREEN" "$RESET"
      break
      ;;
    "Exit")
      printf "%s[✘] Exiting...%s\n" "$RED" "$RESET"
      exit 0
      ;;
    *)
      printf "%s[!] Invalid option, try again.%s\n" "$RED" "$RESET"
      ;;
  esac
done
