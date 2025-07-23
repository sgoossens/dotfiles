#!/bin/bash

# Dotfiles installation script
# Installs dotfiles to their proper locations in the home directory

# Get the current shell name (basename of $SHELL or $0)
CURRENT_SHELL=$(basename "${SHELL:-$0}")

# Function to install a dotfile with backup
install_dotfile() {
    local source_file="$1"
    local target_file="$2"
    
    if [[ -f "$source_file" ]]; then
        echo "Installing $source_file to $target_file..."
        
        # Create backup if target already exists
        if [[ -f "$target_file" ]]; then
            echo "Backing up existing $target_file to ${target_file}.backup"
            cp "$target_file" "${target_file}.backup"
        fi
        
        # Copy the dotfile to its target location
        cp "$source_file" "$target_file"
        echo "Installed $target_file"
        return 0
    else
        echo "Warning: $source_file not found"
        return 1
    fi
}

# Function to setup gitconfig
setup_gitconfig() {
    install_dotfile "./gitconfig" ~/.gitconfig
}

# Install common dotfiles that work across shells
echo "Installing common dotfiles..."
install_dotfile "./aliases" ~/.aliases
install_dotfile "./gitignore" ~/.gitignore
install_dotfile "./gitmessage" ~/.gitmessage
install_dotfile "./vimrc" ~/.vimrc
install_dotfile "./vimrc.bundles" ~/.vimrc.bundles
install_dotfile "./tmux.conf" ~/.tmux.conf
install_dotfile "./ctags" ~/.ctags
install_dotfile "./agignore" ~/.agignore
install_dotfile "./gemrc" ~/.gemrc
install_dotfile "./railsrc" ~/.railsrc
install_dotfile "./psqlrc" ~/.psqlrc
install_dotfile "./asdfrc" ~/.asdfrc
install_dotfile "./rspec" ~/.rspec
install_dotfile "./hushlogin" ~/.hushlogin

# Install vim directory if it exists
if [[ -d "./vim" ]]; then
    echo "Installing vim configuration directory..."
    if [[ -d ~/.vim ]]; then
        echo "Backing up existing ~/.vim to ~/.vim.backup"
        mv ~/.vim ~/.vim.backup
    fi
    cp -r ./vim ~/.vim
    echo "Installed ~/.vim directory"
fi

# Install vim-plug if vimrc.bundles exists
if [[ -f "./vimrc.bundles" ]]; then
    echo "Installing vim-plug plugin manager..."
    
    # Create autoload directory if it doesn't exist
    mkdir -p ~/.vim/autoload
    
    # Download vim-plug
    if command -v curl >/dev/null 2>&1; then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "vim-plug installed successfully"
        
        # Install vim plugins
        echo "Installing vim plugins..."
        vim +PlugInstall +qall
        echo "Vim plugins installed"
    elif command -v wget >/dev/null 2>&1; then
        wget -O ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "vim-plug installed successfully"
        
        # Install vim plugins
        echo "Installing vim plugins..."
        vim +PlugInstall +qall
        echo "Vim plugins installed"
    else
        echo "Warning: Neither curl nor wget found. Please install vim-plug manually:"
        echo "curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        echo "Then run: vim +PlugInstall +qall"
    fi
fi

# Detect shell and install appropriate configuration files
case "$CURRENT_SHELL" in
    "zsh")
        echo "Detected zsh shell - installing zsh configurations"
        install_dotfile "./zshenv" ~/.zshenv
        install_dotfile "./zprofile" ~/.zprofile
        install_dotfile "./zshrc" ~/.zshrc
        ;;
    "bash")
        echo "Detected bash shell - installing bash configurations"
        install_dotfile "./bashrc" ~/.bashrc
        ;;
    "sh")
        echo "Detected sh shell (POSIX) - installing bash configurations for compatibility"
        install_dotfile "./bashrc" ~/.bashrc
        ;;
    *)
        echo "Unknown or unsupported shell: $CURRENT_SHELL"
        echo "Installing bash configurations as fallback..."
        install_dotfile "./bashrc" ~/.bashrc
        ;;
esac

# Setup Git configuration
setup_gitconfig

echo ""
echo "Dotfiles installation complete for $CURRENT_SHELL!"
echo "Please restart your terminal or run 'source ~/.${CURRENT_SHELL}rc' to apply changes."