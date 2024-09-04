#!/bin/bash
set -eo pipefail

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --brew-packages=*)
      BREW_PACKAGES="${arg#*=}"
      ;;
    --apt-packages=*)
      APT_PACKAGES="${arg#*=}"
      ;;
    --pipx-packages=*)
      PIPX_PACKAGES="${arg#*=}"
      ;;
    --go-packages=*)
      GO_PACKAGES="${arg#*=}"
      ;;
  esac
done

function filter_packages() {
  local packages=()
  for package in ${1//,/ }; do
    if ! which "$package" &>/dev/null; then
      packages+=("$package")
    fi
  done
  echo "${packages[*]}"
}

function install_brew_packages() {
  if ! which -s brew ; then
    echo "Homebrew is not installed. Attempting to install it..."
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  fi

  if [ -n "$BREW_PACKAGES" ]; then
    echo "Checking Homebrew packages..."
    BREW_PACKAGES=$(filter_packages "$BREW_PACKAGES")
    if [ -n "$BREW_PACKAGES" ]; then
      echo "Installing Homebrew packages: $BREW_PACKAGES"
      brew install "$BREW_PACKAGES"
    else
      echo "No new Homebrew packages to install"
    fi
  else
    echo "No Homebrew packages specified"
  fi
}

function install_apt_packages() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      if [ -n "$APT_PACKAGES" ]; then
        echo "Checking apt packages..."
        APT_PACKAGES=$(filter_packages "$APT_PACKAGES")
        if [ -n "$APT_PACKAGES" ]; then
          echo "Installing apt packages: $APT_PACKAGES"
          sudo apt-get install -y "$APT_PACKAGES"
        else
          echo "No new apt packages to install"
        fi
      else
        echo "No apt packages specified"
      fi
    else
      echo "apt-get is not installed. Please install it and try again."
      exit 1
    fi
  fi
}

function install_pipx_packages() {
  # Install pipx if not already
  if ! command -v pipx >/dev/null 2>&1; then
    echo "pipx is not installed. Attempting to install it..."
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get install -y pipx
    elif command -v brew >/dev/null 2>&1; then
      brew install pipx
    else
      echo "Unable to download pipx."
      exit 1
    fi
  fi

  # Install pipx packages
  if [ -n "$PIPX_PACKAGES" ]; then
    PIPX_PACKAGES=$(filter_packages "$PIPX_PACKAGES")
    if [ -n "$PIPX_PACKAGES" ]; then
      echo "Installing pipx packages: $PIPX_PACKAGES"
      for package in $PIPX_PACKAGES; do
        pipx install "$package"
      done
      pipx ensurepath
    else
      echo "No new pipx packages to install"
    fi
  else
    echo "No pipx packages specified"
  fi
}

install_go_packages() {
  if command -v go >/dev/null 2>&1; then
    echo "Installing Go packages..."
    IFS=',' read -ra PACKAGES <<< "$GO_PACKAGES"
    for package in "${PACKAGES[@]}"; do
      package_name=$(echo "$package" | awk -F'/' '{print $NF}' | awk -F'@' '{print $1}')
      echo "Checking $package_name"
      if ! which "$package_name" &>/dev/null; then
        echo "Installing $package"
        go install "$package"
      else
        echo "$package_name is already installed"
      fi
    done
  else
    echo "Go is not installed. Please install it and try again."
    exit 1
  fi
}

if [ -n "$BREW_PACKAGES" ]; then install_brew_packages; fi
if [ -n "$APT_PACKAGES" ]; then install_apt_packages; fi
if [ -n "$PIPX_PACKAGES" ]; then install_pipx_packages; fi
if [ -n "$GO_PACKAGES" ]; then install_go_packages; fi

echo "All dependencies checked and installed successfully."
