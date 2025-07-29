#!/bin/bash

TODO_FILE="todo.txt"

# Create file if not exists
if [ ! -f "$TODO_FILE" ]; then
  touch "$TODO_FILE"
fi

# Display all tasks
function show_tasks() {
  echo -e "\n✅ TODO List"
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

# Toggle task done/undone
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

  line=$(sed "${num}q;d" "$TODO_FILE")

  if echo "$line" | grep -q "^\[ \]"; then
    new_line="[x]${line:3}"
  else
    new_line="[ ]${line:3}"
  fi

  # Safely replace the line
  sed -i "${num}s/.*/$new_line/" "$TODO_FILE"
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
