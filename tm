#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <session_name>"
	exit 1
fi

session_names=()
working_dirs=()
env_scripts=()
while IFS= read -r line; do
    session_names+=($(echo $line | awk '{print $1}'))
    working_dirs+=($(echo $line | awk '{print $2}'))
    env_scripts+=($(echo $line | awk '{print $3}'))
done < ~/.tmrc

found=0
for i in "${!session_names[@]}"; do
    if [ $1 == ${session_names[$i]} ]; then
	tmux new-session -d -s ${session_names[$i]}
	tmux split-window -h -t ${session_names[$i]}
	tmux send-keys -t ${session_names[$i]}:0.0 "cd ${working_dirs[$i]}" C-m
	tmux send-keys -t ${session_names[$i]}:0.1 "cd ${working_dirs[$i]}" C-m
	tmux send-keys -t ${session_names[$i]}:0.0 "source ${env_scripts[$i]}" C-m
	tmux send-keys -t ${session_names[$i]}:0.1 "source ${env_scripts[$i]}" C-m
	tmux attach-session -t ${session_names[$i]}

	found=1
	break
    fi
done

if [ $found -eq 0 ]; then
	echo "Session not found"
fi
