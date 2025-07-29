#!/bin/bash

TODO_FILE="todo.txt"

# Load tasks from file or create if not exists
if [ ! -f "$TODO_FILE" ]; then
  touch "$TODO_FILE"
fi

function show_tasks() {
  echo "TODO List:"
  if [ ! -s "$TODO_FILE" ]; then
    echo "  No tasks yet."
  else
    nl -w3 -s". " "$TODO_FILE" | while read -r line; do
      num=$(echo "$line" | cut -d'.' -f1)
      rest=$(echo "$line" | cut -d'.' -f2-)
      # rest is like "  [ ] Task" or "  [x] Task"
      echo "$num.$rest"
    done
  fi
  echo
}

function add_task() {
  read -rp "Enter new task: " task
  if [ -n "$task" ]; then
    echo "[ ] $task" >> "$TODO_FILE"
    echo "Task added."
  else
    echo "Empty task not added."
  fi
}

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

  # Extract the line to toggle
  line=$(sed "${num}q;d" "$TODO_FILE")
  if [[ "$line" =~ ^\[.\] ]]; then
    if [[ "$line" =~ ^\[ \] ]]; then
      # Mark done
      new_line="[x]${line:3}"
    else
      # Mark undone
      new_line="[ ]${line:3}"
    fi
    # Replace line in file
    sed -i "${num}s/.*/$new_line/" "$TODO_FILE"
    echo "Toggled task $num."
  else
    echo "Invalid task format in file."
  fi
}

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
    3) echo "Bye!"; exit 0 ;;
    *) echo "Invalid option." ;;
  esac
done
