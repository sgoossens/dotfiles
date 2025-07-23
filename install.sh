#!/bin/bash

# Dotfiles installation script
# Automatically sources the appropriate shell configuration based on the current shell

# Get the current shell name (basename of $SHELL or $0)
CURRENT_SHELL=$(basename "${SHELL:-$0}")

# Function to source a file if it exists
source_if_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo "Sourcing $file for $CURRENT_SHELL shell..."
        source "$file"
        return 0
    fi
    return 1
}

# Function to setup gitconfig
setup_gitconfig() {
    local gitconfig_file="./gitconfig"
    if [[ -f "$gitconfig_file" ]]; then
        echo "Setting up Git configuration..."
        if [[ -f ~/.gitconfig ]]; then
            echo "Backing up existing ~/.gitconfig to ~/.gitconfig.backup"
            cp ~/.gitconfig ~/.gitconfig.backup
        fi
        cp "$gitconfig_file" ~/.gitconfig
        echo "Git configuration installed to ~/.gitconfig"
        return 0
    else
        echo "Warning: gitconfig file not found"
        return 1
    fi
}

# Detect shell and source appropriate configuration
case "$CURRENT_SHELL" in
    "zsh")
        echo "Detected zsh shell"
        # Source zsh configurations in order of precedence
        source_if_exists "./zshenv" || echo "Warning: zshenv not found"
        source_if_exists "./zprofile" || echo "Warning: zprofile not found" 
        source_if_exists "./zshrc" || echo "Warning: zshrc not found"
        # Source common aliases
        source_if_exists "./aliases" || echo "Warning: aliases not found"
        ;;
    "bash")
        echo "Detected bash shell"
        source_if_exists "./bashrc" || echo "Warning: bashrc not found"
        # Source common aliases
        source_if_exists "./aliases" || echo "Warning: aliases not found"
        ;;
    "sh")
        echo "Detected sh shell (POSIX)"
        # For sh, try to source the most compatible configuration
        source_if_exists "./bashrc" || echo "Warning: bashrc not found"
        # Source common aliases
        source_if_exists "./aliases" || echo "Warning: aliases not found"
        ;;
    *)
        echo "Unknown or unsupported shell: $CURRENT_SHELL"
        echo "Attempting to source bashrc as fallback..."
        source_if_exists "./bashrc" || echo "Warning: bashrc not found"
        # Source common aliases
        source_if_exists "./aliases" || echo "Warning: aliases not found"
        ;;
esac

# Setup Git configuration (shell-independent)
setup_gitconfig

echo "Shell configuration loaded for $CURRENT_SHELL"