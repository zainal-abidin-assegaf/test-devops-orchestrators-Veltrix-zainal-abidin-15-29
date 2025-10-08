#!/bin/bash
timestamp=$(date +"%Y%m%d_%H%M%S")

# Ensure the 'logs' directory exists
mkdir -p logs

# Redirect all output (stdout + stderr) to both terminal and log file
exec > >(tee -a logs/setup_$timestamp.log) 2>&1

echo "[Swap Optimizer Setup] Starting setup..."

# Detect OS and install Node.js if missing
OS="$(uname -s)"

detect_and_install_node() {
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo "[INFO] Node.js already installed: $(node -v)"
        echo "[INFO] npm version: $(npm -v)"
        return
    fi

    echo "[INFO] Node.js or npm not found. Attempting installation..."

    case "$OS" in
        Linux*)
            if [ -f /etc/debian_version ]; then
                echo "[INFO] Installing Node.js via apt..."
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt install -y nodejs
            elif [ -f /etc/redhat-release ]; then
                echo "[INFO] Installing Node.js via yum..."
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
            else
                echo "[WARN] Unsupported Linux distro. Please install Node.js manually."
                exit 1
            fi
            ;;
        Darwin*)
            if command -v brew &>/dev/null; then
                echo "[INFO] Installing Node.js via Homebrew..."
                brew install node
            else
                echo "[ERROR] Homebrew not found. Please install Node.js manually."
                exit 1
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "[INFO] Detected Windows (Git Bash or WSL). Please install Node.js manually from https://nodejs.org/"
            exit 1
            ;;
        *)
            echo "[ERROR] Unknown OS: $OS"
            exit 1
            ;;
    esac
}

detect_node_version() {
    NODE_VERSION=$(node -v)
    NODE_VERSION_MAJOR=$(node -v | grep -oE '[0-9]+' | head -1)

    if [ "$NODE_VERSION_MAJOR" -ge 18 ]; then
        echo "Node.js version $(node -v) is 18 or higher."
    else
        echo "[INFO] ⚠️ Node.js version $(node -v) is below 18."
        exit 1
    fi
}

detect_and_install_node

detect_node_version

# Install dependencies
echo "[INFO] Installing Node.js dependencies..."
npm install

# Prepare .env file
if [ ! -f .env ]; then
    if [ -f .env_example ]; then
        cp .env_example .env
        echo "[INFO] Copied .env_example to .env"
        echo "[WARN] Update your INFURA_URL in .env before proceeding."
    else
        echo "[ERROR] No .env or .env_example found. Cannot continue."
        exit 1
    fi
fi

echo "[Swap Optimizer Setup] Setup complete."
npm run dev