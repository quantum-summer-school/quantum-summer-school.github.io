#!/bin/bash

# ========================================
# Cross-Platform Conda Environment Creator - Linux/Mac Version 
# ========================================
# This script creates a conda environment with Python 3.10 and installs pip dependencies
# Works by properly detecting and initializing conda installation
# Only requires conda/anaconda to be installed - no separate Python installation needed

# ========================================
# CONFIGURATION - EDIT THESE VARIABLES
# ========================================

# Environment name (change this if you want a different name)
ENVIRONMENT_NAME="quantum_env"

# Python version (change if you need a different version)
PYTHON_VERSION="3.10"

# Pip dependencies (add your packages here)
PIP_DEPENDENCIES=(
    "numpy"
    "pandas"
    "qiskit"
    "matplotlib"
    "qiskit-machine-learning"
    "qiskit-aer"
    "pennylane"
    "pennylane-qiskit"
    "seaborn"
    "scqubits"
    "ipyvuetify"
    "sccircuitbuilder"
    "qiskit-metal"
    "pyside2"
    "geopandas"
    "perceval-quandela"
)

# ========================================
# SCRIPT LOGIC - DO NOT EDIT BELOW
# ========================================

echo "Creating conda environment with Python $PYTHON_VERSION"
echo "Environment name: $ENVIRONMENT_NAME"
echo ""

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Function to open browser
open_browser() {
    local url="$1"
    local os_type=$(detect_os)
    
    if [[ "$os_type" == "macos" ]]; then
        open "$url" 2>/dev/null
    elif [[ "$os_type" == "linux" ]]; then
        xdg-open "$url" 2>/dev/null
    fi
}

# Find Anaconda/Miniconda installation
CONDA_ROOT=""
CONDA_EXE=""
ACTIVATE_SCRIPT=""

echo "Searching for conda installation..."

# Check common installation paths for different operating systems
OS_TYPE=$(detect_os)

if [[ "$OS_TYPE" == "macos" ]]; then
    # macOS common paths
    COMMON_PATHS=(
        "$HOME/anaconda3"
        "$HOME/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
        "/usr/local/anaconda3"
        "/usr/local/miniconda3"
        "/Applications/anaconda3"
        "/Applications/miniconda3"
    )
elif [[ "$OS_TYPE" == "linux" ]]; then
    # Linux common paths
    COMMON_PATHS=(
        "$HOME/anaconda3"
        "$HOME/miniconda3"
        "/opt/anaconda3"
        "/opt/miniconda3"
        "/usr/local/anaconda3"
        "/usr/local/miniconda3"
        "/anaconda3"
        "/miniconda3"
    )
else
    # Default paths for unknown systems
    COMMON_PATHS=(
        "$HOME/anaconda3"
        "$HOME/miniconda3"
    )
fi

# Check each common path
for path in "${COMMON_PATHS[@]}"; do
    if [[ -d "$path" && -f "$path/bin/conda" ]]; then
        CONDA_ROOT="$path"
        CONDA_EXE="$path/bin/conda"
        if [[ -f "$path/etc/profile.d/conda.sh" ]]; then
            ACTIVATE_SCRIPT="$path/etc/profile.d/conda.sh"
        fi
        break
    fi
done

# If not found in common paths, try to find conda in PATH
if [[ -z "$CONDA_EXE" ]]; then
    if command -v conda &> /dev/null; then
        CONDA_EXE=$(which conda)
        if [[ -n "$CONDA_EXE" ]]; then
            # Get the conda root directory
            CONDA_ROOT=$(dirname $(dirname "$CONDA_EXE"))
            if [[ -f "$CONDA_ROOT/etc/profile.d/conda.sh" ]]; then
                ACTIVATE_SCRIPT="$CONDA_ROOT/etc/profile.d/conda.sh"
            fi
        fi
    fi
fi

# If still not found, show detailed error message
if [[ -z "$CONDA_EXE" ]]; then
    echo "=========================================="
    echo "ERROR: Could not find Anaconda/Miniconda installation"
    echo "=========================================="
    echo ""
    echo "Conda is required to run this script but was not found on your system."
    echo ""
    echo "Please install either Anaconda or Miniconda first:"
    echo ""
    
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "** DOWNLOAD LINKS FOR MACOS **"
        echo ""
        echo "1. Anaconda Distribution (Recommended for beginners)"
        echo "   - Full package with 300+ pre-installed packages"
        echo "   - Includes Jupyter, Spyder, and other tools"
        echo "   - Download from: https://www.anaconda.com/download"
        echo "   - Look for 'Download for macOS' button"
        echo ""
    elif [[ "$OS_TYPE" == "linux" ]]; then
        echo "** DOWNLOAD LINKS FOR LINUX **"
        echo ""
        echo "1. Anaconda Distribution (Recommended for beginners)"
        echo "   - Full package with 300+ pre-installed packages"
        echo "   - Includes Jupyter, Spyder, and other tools"
        echo "   - Download from: https://www.anaconda.com/download"
        echo "   - Look for 'Download for Linux' button"
        echo ""
    else
        echo "** DOWNLOAD LINKS **"
        echo ""
        echo "Visit: https://www.anaconda.com/download"
        echo "Or: https://docs.conda.io/en/latest/miniconda.html"
    fi
    
    echo ""
    echo "** INSTALLATION INSTRUCTIONS **"
    echo ""
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "For macOS:"
        echo "1. Download the .pkg installer from the link above"
        echo "2. Double-click the downloaded file to run the installer"
        echo "3. Follow the installation wizard (accept default settings)"
        echo "4. Restart your terminal or run: source ~/.bash_profile"
        echo "5. Run this script again"
    elif [[ "$OS_TYPE" == "linux" ]]; then
        echo "For Linux:"
        echo "1. Download the .sh installer from the link above"
        echo "2. Open terminal and navigate to download folder"
        echo "3. Run: bash Anaconda3-*.sh (or Miniconda3-*.sh)"
        echo "4. Follow the installation prompts (accept default settings)"
        echo "5. Restart your terminal or run: source ~/.bashrc"
        echo "6. Run this script again"
    else
        echo "1. Download the appropriate installer for your system"
        echo "2. Follow the installation instructions"
        echo "3. Restart your terminal"
        echo "4. Run this script again"
    fi
    
    echo ""
    echo "** TROUBLESHOOTING **"
    echo ""
    echo "If you already have Anaconda/Miniconda installed:"
    echo "- Try running: conda --version"
    echo "- Check if conda is in your PATH: echo \$PATH"
    echo "- You might need to initialize conda: conda init"
    echo "- Restart your terminal after initialization"
    echo ""
    echo "Common installation paths checked:"
    for path in "${COMMON_PATHS[@]}"; do
        echo "  - $path"
    done
    echo ""
    
    echo "Press Enter to open the download page in your browser..."
    read -r
    open_browser "https://www.anaconda.com/download"
    exit 1
fi

# Conda found
echo "Found conda installation at: $CONDA_ROOT"
echo "Using conda executable: $CONDA_EXE"
if [[ -n "$ACTIVATE_SCRIPT" ]]; then
    echo "Using activation script: $ACTIVATE_SCRIPT"
fi
echo ""

# Initialize conda environment if activation script exists
if [[ -n "$ACTIVATE_SCRIPT" ]]; then
    echo "Initializing conda environment..."
    source "$ACTIVATE_SCRIPT"
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to initialize conda environment"
        echo "Continuing without initialization..."
    fi
fi

# Display conda version
echo "Checking conda installation..."
"$CONDA_EXE" --version
echo ""

# Check if environment already exists
if "$CONDA_EXE" env list | grep -q "^$ENVIRONMENT_NAME "; then
    echo ""
    echo "Environment '$ENVIRONMENT_NAME' already exists"
    read -p "Do you want to remove and recreate it? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
    echo "Removing existing environment..."
    "$CONDA_EXE" env remove -n "$ENVIRONMENT_NAME" -y
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Failed to remove existing environment"
        exit 1
    fi
fi

# Create conda environment with Python and pip
echo "Creating conda environment '$ENVIRONMENT_NAME' with Python $PYTHON_VERSION..."
"$CONDA_EXE" create -n "$ENVIRONMENT_NAME" python="$PYTHON_VERSION" pip -y
if [[ $? -ne 0 ]]; then
    echo "ERROR: Failed to create conda environment"
    exit 1
fi

echo "Environment created successfully"
echo ""

# Install pip dependencies if any are specified
if [[ ${#PIP_DEPENDENCIES[@]} -gt 0 ]]; then
    echo "Installing pip dependencies..."
    echo "Dependencies: ${PIP_DEPENDENCIES[*]}"
    echo ""
    
    # Use conda run to install packages in the specific environment
    "$CONDA_EXE" run -n "$ENVIRONMENT_NAME" pip install "${PIP_DEPENDENCIES[@]}"
    if [[ $? -ne 0 ]]; then
        echo "WARNING: Some packages may have failed to install"
        echo "You can manually install them later using:"
        echo "  conda activate $ENVIRONMENT_NAME"
        echo "  pip install [package_name]"
    else (
        echo "All dependencies installed successfully"
    )
else
    echo "No pip dependencies specified, skipping package installation"
fi

echo ""
echo "=========================================="
echo "Environment setup completed successfully!"
echo "=========================================="
echo ""
echo "Environment name: $ENVIRONMENT_NAME"
echo "Python version: $PYTHON_VERSION"
echo ""
echo "To activate your environment:"
echo "  conda activate $ENVIRONMENT_NAME"
echo ""
echo "To deactivate:"
echo "  conda deactivate"
echo ""
echo "To remove the environment:"
echo "  conda env remove -n $ENVIRONMENT_NAME"
echo ""
echo "To list all environments:"
echo "  conda env list"
echo ""
echo "Press Enter to continue..."
read -r
