#! /usr/bin/env bash

DOTFILES_REPO=~/.mydotfiles
OH_MY_ZSH_DIR=~/.oh-my-zsh

main() {
    ask_for_sudo
    install_xcode_command_line_tools
    clone_dotfiles_repo
    cd ~/.mydotfiles
    install_homebrew
    install_packages_with_brewfile
    change_shell_to_zsh
    install_oh_my_zsh
    tune_oh_my_zsh
    set_zshrc
    configure_asdf
    configure_spacemacs
}

function ask_for_sudo() {
    info "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
        exit 1
    fi
}

function install_xcode_command_line_tools() {
    info "Installing Xcode command line tools"
    if softwareupdate --history | grep --silent "Command Line Tools"; then
        substep "Xcode command line tools already exists"
    else
        xcode-select --install
        read -n 1 -s -r -p "Press any key once installation is complete\n"

        if softwareupdate --history | grep --silent "Command Line Tools"; then
            success "Xcode command line tools installation succeeded"
        else
            error "Xcode command line tools installation failed"
            exit 1
        fi
    fi
}

function clone_dotfiles_repo() {
    info "Cloning dotfiles repository into ${DOTFILES_REPO}"
    if test -e $DOTFILES_REPO; then
        substep "${DOTFILES_REPO} already exists"
    else
        url=https://github.com/josemiguelo/dotfiles.git
        if git clone "$url" $DOTFILES_REPO && \
           git -C $DOTFILES_REPO remote set-url origin https://github.com/josemiguelo/dotfiles.git; then
            success "Dotfiles repository cloned into ${DOTFILES_REPO}"
        else
            error "Dotfiles repository cloning failed"
            exit 1
        fi
    fi
}

function install_homebrew() {
    info "Installing Homebrew"
    if hash brew 2>/dev/null; then
        substep "Homebrew already exists"
    else
        url=https://raw.githubusercontent.com/Homebrew/install/master/install
        if yes | /usr/bin/ruby -e "$(curl -fsSL ${url})"; then
            success "Homebrew installation succeeded"
        else
            error "Homebrew installation failed"
            exit 1
        fi
    fi
}

function install_packages_with_brewfile() {
    cd ./brew
    info "Installing Brewfile packages"
    # brew bundle is automatically installed when run
    brew bundle
    brew cleanup
    success "Brew installation succeeded"
    cd ..
}


function change_shell_to_zsh() {
    change_shell "zsh" "/bin/zsh"
}

# MacOS Catalina comes with zsh bundled by default.
# Maybe this is not necessary

# $1 simple shell name: fish, zsh, bash, etc.
# $2 shell path
function change_shell() {
    info "$1 shell setup"
    if grep --quiet $1 <<< "$SHELL"; then
        substep "$1 shell already exists"
    else
        user=$(whoami)
        substep "Adding $1 executable to /etc/shells"
        if grep --fixed-strings --line-regexp --quiet $2 /etc/shells; then
            substep "$1 executable already exists in /etc/shells"
        else
            if echo $2 | sudo tee -a /etc/shells > /dev/null;
            then
                substep "$1 executable successfully added to /etc/shells"
            else
                error "Failed to add $1 executable to /etc/shells"
                exit 1
            fi
        fi
        substep "Switching shell to $1 for \"${user}\""
        if sudo chsh -s $2 "$user"; then
            success "$1 shell successfully set for \"${user}\""
        else
            error "Please try setting $1 shell again"
        fi
    fi
}

function install_oh_my_zsh() {
    info "Verifying Oh My ZSH installation"
    if test -e $OH_MY_ZSH_DIR; then
        substep "${OH_MY_ZSH_DIR} already exists"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        success "Installing Oh My ZSH"
    fi
}

function tune_oh_my_zsh() {
    clone_or_skip_repo 	${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions \
	   		https://github.com/zsh-users/zsh-completions \
			"zsh-completions"

    clone_or_skip_repo 	${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    	    		https://github.com/zsh-users/zsh-syntax-highlighting.git \
    			"zsh-syntax-highlighting"

    clone_or_skip_repo 	${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    			https://github.com/zsh-users/zsh-autosuggestions \
    			"zsh-autosuggestions"
}

function clone_or_skip_repo() {
    info "Verifying $3 installation"
    if ! [[ -e $1 ]]; then
        git clone $2 $1
    	success "$3 was cloned successfully"
    else
    	substep "$3 already cloned"
    fi
}

function set_zshrc() {
    info "Removing .zshrc"
    rm -f ~/.zshrc
    ln -s ~/.mydotfiles/zsh/.zshrc ~/.zshrc
    chmod -R go-w ~/.oh-my-zsh
    success "New .zshrc file set up"
}

function configure_asdf() {
    info "Configuring asdf-vm"

    # installation
    if [ ! -d "$HOME/.asdf" ]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf
        substep "asdf has been cloned"
    else
        substep "asdf is already installed"
    fi
    source "$HOME/.asdf/asdf.sh"

    # adds ruby
    if hash ruby 2>/dev/null; then
        substep "ruby already configured"
    else
        install_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
        install_asdf_language "ruby"
        gem update --system
        number_of_cores=$(sysctl -n hw.ncpu)
        bundle config --global jobs $((number_of_cores - 1))
        success "ruby has been installed"
    fi

    # adds nodejs
    if hash node 2>/dev/null; then
        substep "nodejs already configured"
    else
        install_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
        bash "$HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring"
        install_asdf_language "nodejs"
        success "nodejs has been installed"
    fi
}

function configure_spacemacs() {
    info "Configuring spacemacs"

    # installing Spacemacs
    if [ ! -d "$HOME/.asdf" ]; then
        git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
        substep "Spacemacs has been cloned"
    else
        substep "Spacemacs is already installed"
    fi

    # setting up tabbar
    TABBAR_DIR=~/.emacs.d/private/tabbar
    if [ ! -d "$TABBAR_DIR" ]; then
        git clone https://github.com/kdoomsday/tabbar-layer "$TABBAR_DIR"
        substep "tabbar has been cloned"
    fi

    # linking dotfile
    substep "Removing .spacemacs"
    rm -f ~/.spacemacs
    substep "Linking new .spacemacs"
    ln -s ~/.mydotfiles/emacs/.spacemacs ~/.spacemacs
    success "Spacemacs all set up"
}

function install_asdf_language() {
    local language="$1"
    local version
    version="$(asdf list-all "$language" | grep -v "[a-z]" | tail -1)"

    if ! asdf list "$language" | grep -Fq "$version"; then
        asdf install "$language" "$version"
        asdf global "$language" "$version"
        substep "asdf language $name has been installed"
    fi
}

function install_asdf_plugin() {
    local name="$1"
    local url="$2"

    if ! asdf plugin-list | grep -Fq "$name"; then
        asdf plugin-add "$name" "$url"
        substep "asdf plugin $name has been installed"
    else
        asdf plugin-update "$name"
        substep "asdf plugin $name has been updated"
    fi
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function info() {
    echo
    coloredEcho "$1" blue "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}


main "$@"
