#!/bin/bash

if command -v git >/dev/null 2>&1; then
    echo "git installed: $(git --version)"
else
    echo "git not installed yet."

    # detect os
    OS="$(uname -s)"

    case "$OS" in
        Linux*)
            echo "This is a Linux system."
            if command -v apt >/dev/null 2>&1; then
                sudo apt update -y && sudo apt install git -y
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install git -y
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install git -y
            else
                echo "No supported package manager found. Please install Git manually."
                exit 1
            fi
            ;;
        Darwin*)
            echo "This is a macOS system."
            if command -v brew >/dev/null 2>&1; then
                echo "Installing git using Homebrew ..."
                brew install git
            else
                echo "Homebrew not installed"
                exit 1
            fi
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            echo "This is a Windows system (running Bash via Cygwin, MinGW, or MSYS)."
            echo "Please install git manually from authorized published"
            exit 1

            ;;
        *)
            echo "Unknown operating system: $OS"
            exit 1
            ;;
    esac
fi

REPO_URL="https://github.com/zainal-abidin-assegaf/test-devops-orchestrators-Veltrix-zainal-abidin-15-29.git"
REPO_DIR="test-devops-orchestrators"

# Step 1: Clone or update the repository
if [ -d "$REPO_DIR/.git" ]; then
    echo "[+] Repository exists. Pulling latest changes..."
    cd "$REPO_DIR" && git pull
else
    echo "[+] Cloning repository..."
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR" || { echo "Failed to enter directory"; exit 1; }
fi

# Step 2: Make scripts executable
echo "[+] Granting execution permissions..."
chmod +x setup.sh start.sh

# Step 3: Run setup.sh
echo "[+] Running setup.sh..."
./setup.sh

echo "Setup is completed"