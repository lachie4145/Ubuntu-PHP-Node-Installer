#!/bin/bash

PHP_VERSION="8.2.3" #Do not change this unless you know what you are doing

NODE_VERSION="v18.14.2" #Do not change this unless you know what you are doing

COMMON_PACKAGES=(
    "curl"
    "vim"
)

PHP_PACKAGES=(
    "pkg-config"
    "build-essential"
    "gcc"
    "autoconf"
    "re2c"
    "bison"
    "libsqlite3-dev"
    "libpq-dev"
    "libonig-dev"
    "libfcgi-dev"
    "libfcgi0ldbl"
    "libjpeg-dev"
    "libpng-dev"
    "libssl-dev"
    "libxml2-dev"
    "libcurl4-openssl-dev"
    "libxpm-dev"
    "libgd-dev"
    "libmysqlclient-dev"
    "libfreetype6-dev"
    "libxslt1-dev"
    "libpspell-dev"
    "libzip-dev"
    "libgccjit-10-dev"
)

COLOR_END="\033[0m"

COLOURS=(
    "black" "\033[30m"
    "red" "\033[31m"
    "green" "\033[32m"
    "yellow" "\033[33m"
    "blue" "\033[34m"
    "purple" "\033[35m"
    "cyan" "\033[36m"
    "white" "\033[37m"
)

function get_text_color() {
    for ((i=0; i<${#COLOURS[@]}; i+=2)); do
        if [ "$1" == "${COLOURS[$i]}" ]; then
            echo -e "${COLOURS[$i+1]}"
        fi
    done
}

function echo_green() {
    echo -e "$(get_text_color "green")$1$COLOR_END"
}

function run_apt() {
    sudo apt install $1 -y
}

function append_to_bashrc() {

    #LINES_TO_ADD=("Here")
    #append_to_bashrc "${LINES_TO_ADD[@]}"

    local arr=("$@")
    arr=("" "${arr[@]}" "")

    local bashrc_file="$HOME/.bashrc"
    for element in "${arr[@]}"; do
        echo "$element" >> "$bashrc_file" 
    done
    source "$bashrc_file"
}

function check_packages(){ 
  packages=("$@")
  missing=()
  for package in "${packages[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "ok installed"; then
        missing+=("$package")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing Packages: ${missing[@]}"
    exit 0
  fi
}

function command_does_not_exists() {
    if command -v "$1" &> /dev/null; then
        return 1  # command does not exist
    else
        return 0  # command exists
    fi
}

function echo_spacer() {
    echo -e "$(get_text_color "yellow")------------------------------------------------------------------------$COLOR_END"
}

function install_confirm() {
    read -p "Are you sure you want to install? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
}

function print_starting_message() {
    echo_green "Starting Ubuntu setup"
    echo_spacer
    echo_green "Installing the following packages and versions"
    echo -e "$(get_text_color "blue")Installing apt packages:$COLOR_END $(get_text_color "yellow")"${COMMON_PACKAGES[@]}" $COLOR_END"
    echo -e "$(get_text_color "blue")Installing PHP version:$COLOR_END $(get_text_color "yellow")"${PHP_VERSION}" $COLOR_END"
    echo -e "$(get_text_color "blue")Installing Node version:$COLOR_END $(get_text_color "yellow")"${NODE_VERSION}" $COLOR_END"
    echo_spacer
    echo -e "$(get_text_color "green")This will take a awhile, sit back and wait...$COLOR_END"
    echo -e "$(get_text_color "green")You can check the progress in the console$COLOR_END"
    install_confirm
    echo_spacer
}

# Define function to run update and upgrade
function update_upgrade() {
    echo_green "Updating and Upgrading..."
    sudo apt update -y
    sudo apt upgrade -y
    echo_spacer
}

function install_phpup_install_version() {
    echo_green "Installing PHP"
    # Check for all php packages
    check_packages "${PHP_PACKAGES[@]}"

    #Check if phpup is installed
    if command_does_not_exists "phpup"; then
        #install phpup
        echo_green "Installing PHPUP"
        curl -fsSL https://phpup.vercel.app/install | bash

        source "$HOME/.bashrc"
    fi

    # Install PHP Version
    echo_green "Installing PHP $PHP_VERSION"
    phpup install "$PHP_VERSION"

    # Set PHP Version
    echo_green "Setting PHPUP Default $PHP_VERSION"
    phpup default "$PHP_VERSION"
    phpup use "$PHP_VERSION"

    # Install Composer
    composer_install_setup

    echo_spacer
}

function composer_install_setup() {
    echo_green "Installing Composer"
    # Check if composer is installed
    if command_does_not_exists "composer"; then
        #install composer
        echo_green "Installing Composer"
        sudo apt install composer -y >> /dev/null
    fi

    LARAVEL_PATH="$HOME/.config/composer/vendor/laravel/installer/bin/laravel"

    #check if file exists at path LARAVEL_PATH
    if [ -f "$LARAVEL_PATH" ]; then
        echo_green "Laravel is already installed"
    else
        laravel_global_install
    fi

    # Set Composer bin path
    echo_green "Setting Composer bin path"

    BIN_PATH=(
        "export PATH=\"\$HOME/.config/composer/vendor/bin:\$PATH\""
    )

    append_to_bashrc "${BIN_PATH[@]}"
}

function laravel_global_install() {
    echo_green "Installing Laravel"
    # Check if laravel is installed
    if command_does_not_exists "laravel"; then
        #install laravel
        echo_green "Installing Laravel"
        composer global require laravel/installer
    fi
}

function nvm_export() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm
}

function install_nvm_with_latest() {
    echo_green "Installing NVM and Node"
    # Check for all nodejs packages

    nvm_export

    # Check if nvm is installed
    if command_does_not_exists "nvm"; then
        #install nvm
        echo_green "Installing NVM"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    fi

    nvm_export
    source "$HOME/.bashrc"

    # Install Node Version
    nvm install "$NODE_VERSION"
    nvm alias default "$NODE_VERSION"
    nvm use "$NODE_VERSION"

    echo_spacer
}

# Define function to install apt packages
function install_apt_packages() {
    # Install Common Packages
    echo_green "Installing Common Packages"
    PKGS=$(printf " %s" "${COMMON_PACKAGES[@]}")
    run_apt "$PKGS"

    # Install PHP Packages
    PKGS=$(printf " %s" "${PHP_PACKAGES[@]}")
    run_apt "$PKGS"
    echo_spacer
}


function on_end() {
    echo_green "Cleaning up..."
    echo_green "Ubuntu setup complete"
    echo_spacer
}


# Run show start message
print_starting_message

# Run update and upgrade
update_upgrade

# Install apt packages
install_apt_packages

#install phpup
install_phpup_install_version

#install nvm
install_nvm_with_latest

# Run on_end function at the end
on_end
