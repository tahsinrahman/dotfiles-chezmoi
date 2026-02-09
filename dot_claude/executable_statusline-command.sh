#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get directory basename
if [ -n "$cwd" ]; then
    dir=$(basename "$cwd")
else
    dir=""
fi

# Get git branch if in a git repo (suppress errors, skip optional locks)
if [ -n "$cwd" ]; then
    git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
else
    git_branch=""
fi

# Get kubectl context (suppress errors)
kubectl_ctx=$(kubectl config current-context 2>/dev/null)

# Colors (using Tide-like colors - will be dimmed in terminal)
# Cyan/Blue for directory
COLOR_DIR="\033[38;2;0;175;255m"
# Green for git branch
COLOR_GIT="\033[38;2;95;215;0m"
# Light blue/cyan for model
COLOR_MODEL="\033[38;2;0;172;215m"
# Purple/blue for kubectl
COLOR_K8S="\033[38;2;50;108;229m"
# Gray for separators
COLOR_SEP="\033[38;2;148;148;148m"
# Yellow for context percentage
COLOR_CTX="\033[38;2;215;175;0m"
# Reset
COLOR_RESET="\033[0m"

# Build status line
output=""

# Directory
if [ -n "$dir" ]; then
    output="${COLOR_DIR}${dir}${COLOR_RESET}"
fi

# Git branch
if [ -n "$git_branch" ]; then
    if [ -n "$output" ]; then
        output="${output} ${COLOR_SEP}•${COLOR_RESET} "
    fi
    output="${output}${COLOR_GIT}${git_branch}${COLOR_RESET}"
fi

# Model
if [ -n "$model" ]; then
    if [ -n "$output" ]; then
        output="${output} ${COLOR_SEP}•${COLOR_RESET} "
    fi
    output="${output}${COLOR_MODEL}${model}${COLOR_RESET}"
fi

# Kubectl context
if [ -n "$kubectl_ctx" ]; then
    if [ -n "$output" ]; then
        output="${output} ${COLOR_SEP}•${COLOR_RESET} "
    fi
    output="${output}${COLOR_K8S}k8s:${kubectl_ctx}${COLOR_RESET}"
fi

# Context remaining
if [ -n "$ctx_remaining" ]; then
    if [ -n "$output" ]; then
        output="${output} ${COLOR_SEP}•${COLOR_RESET} "
    fi
    # Round to integer
    ctx_int=$(printf "%.0f" "$ctx_remaining")
    output="${output}${COLOR_CTX}ctx:${ctx_int}%${COLOR_RESET}"
fi

# Print the status line using printf
printf "%b\n" "$output"
