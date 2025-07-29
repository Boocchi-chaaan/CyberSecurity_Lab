#!/bin/bash

TODO_FILE="todo.txt"

# Create file with predefined tasks if not already exists
if [ ! -f "$TODO_FILE" ]; then
  cat <<EOF > "$TODO_FILE"
[ ] 🔧 Hardware & Assembly - Assemble Raspberry Pi 4 with all required peripherals
[ ] 🔧 Hardware & Assembly - Set up portable power bank and OTG hub
[ ] 🔧 Hardware & Assembly - Connect HDMI display for local access
[ ] 🔧 Hardware & Assembly - Install heat sinks or cooling for stability (optional)

[ ] 💽 OS & Software Setup - Flash Kali Linux to microSD card
[ ] 💽 OS & Software Setup - Configure SSH, VNC, or direct desktop access
[ ] 💽 OS & Software Setup - Install and configure: Nmap
[ ] 💽 OS & Software Setup - Install and configure: Wireshark
[ ] 💽 OS & Software Setup - Install and configure: Aircrack-ng, Reaver, Wifite
[ ] 💽 OS & Software Setup - Install and configure: Metasploit, Burp Suite
[ ] 💽 OS & Software Setup - Install and configure: Tcpdump, Bettercap
[ ] 💽 OS & Software Setup - Install and configure: Snort
[ ] 💽 OS & Software Setup - Install and configure: Kismet
[ ] 💽 OS & Software Setup - Install and configure: Hashcat
[ ] 💽 OS & Software Setup - Set up Pi-hole with VPN
[ ] 💽 OS & Software Setup - Configure Raspberry Pi as Tor router

[ ] 🛡️ Security Testing Features - Test packet sniffing on local network
[ ] 🛡️ Security Testing Features - Set up USB Rubber Ducky / Teensy payloads
[ ] 🛡️ Security Testing Features - Conduct test scans and attacks in a lab environment

[ ] 🌐 Network & Privacy - Configure VPN tunneling
[ ] 🌐 Network & Privacy - Set up Tor for anonymous routing
[ ] 🌐 Network & Privacy - Block ads and trackers using Pi-hole

[ ] 📚 Educational Content - Create beginner tutorials for each tool
[ ] 📚 Educational Content - Develop lesson plans or workshop material
[ ] 📚 Educational Content - Add safety guidelines and legal disclaimers

[ ] 📦 Documentation & Publishing - Finalize and update README.md
[ ] 📦 Documentation & Publishing - Add TODO.md
[ ] 📦 Documentation & Publishing - Create LICENSE file (MIT, GPL, etc.)
[ ] 📦 Documentation & Publishing - Publish repository to GitHub
[ ] 📦 Documentation & Publishing - Share build instructions and images
EOF
fi

# Display tasks with numbers
function show_tasks() {
  echo -e "\n✅ TODO List – Multifunctional Cybersecurity Platform"
  if [ ! -s "$TODO_FILE" ]; then
    echo "  No tasks yet!"
  else
    nl -w2 -s'. ' "$TODO_FILE"
  fi
  echo
}

# Add a new task
function add_task() {
  read -rp "Enter new task: " task
  if [ -n "$task" ]; then
    echo "[ ] $task" >> "$TODO_FILE"
    echo "Task added."
  else
    echo "Empty task not added."
  fi
}

# Toggle task done/undone (safely)
function toggle_task() {
  read -rp "Enter task number to toggle: " num
  if ! [[ "$num" =~ ^[0-9]+$ ]]; then
    echo "Invalid number."
    return
  fi

  total=$(wc -l < "$TODO_FILE")
  if (( num < 1 || num > total )); then
    echo "Task number out of range."
    return
  fi

  line=$(sed -n "${num}p" "$TODO_FILE")

  if echo "$line" | grep -q "^\[ \]"; then
    new_line="[x]${line:3}"
  else
    new_line="[ ]${line:3}"
  fi

  # Safely write back using a temporary file
  temp_file=$(mktemp)
  awk -v n="$num" -v new="$new_line" 'NR == n {$0 = new} {print}' "$TODO_FILE" > "$temp_file"
  mv "$temp_file" "$TODO_FILE"

  echo "Toggled task $num."
}

# Menu loop
while true; do
  show_tasks
  echo "Options:"
  echo "  1. Add task"
  echo "  2. Toggle task done/undone"
  echo "  3. Quit"
  read -rp "Choose an option (1-3): " choice
  case "$choice" in
    1) add_task ;;
    2) toggle_task ;;
    3) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option." ;;
  esac
done

