#!/bin/bash

set -e

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"

}
# Check if Flutter is already installed
if [[ -d "$HOME/.flutter" ]]; then
  log "Flutter is already installed. Skipping setup"
  exit 0
fi

download_url="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.3-stable.tar.xz"

log "Downloading Flutter SDK..."

if ! curl -L -o flutter.tar.xz "$download_url"; then
  log "Error: Failed to download Flutter SDK. Please check your internet connection and try again."
  exit 1
fi

# Verify the download
if [[ ! -f flutter.tar.xz ]]; then
  log "Error: flutter.tar.xz not found after download. Download may have failed."
  exit 1
fi

log "Extracting the flutter sdk"

# Extract the Flutter SDK
log "Extracting Flutter SDK..."
if ! tar -xf flutter.tar.xz -C $HOME; then
  log "Error: Failed to extract Flutter SDK."
  rm flutter.tar.xz
  exit 1
fi

# Move Flutter to .flutter directory
if [[ -d "$HOME/flutter" ]]; then
  mv "$HOME/flutter" "$HOME/.flutter"
else
  log "Error: Flutter directory not found after extraction."
  exit 1
fi

rm flutter.tar.xz

# Install required packages
log "Installing required packages..."
if ! sudo dnf install -y clang cmake ninja-build pkgconf-pkg-config gtk3-devel lzma-sdk-devel; then
  log "Error: Failed to install required packages. Please check your system's package manager."
  exit 1
fi

# Add Flutter to PATH for different shells
log "Adding Flutter to PATH..."
echo 'export PATH="$HOME/.flutter/bin:$PATH"' >>~/.bashrc
echo 'export PATH="$HOME/.flutter/bin:$PATH"' >>~/.zshrc
echo 'fish_add_path $HOME/.flutter/bin' >>~/.config/fish/config.fish

# Source the updated bashrc
source ~/.bashrc

log "Running flutter doctor..."
if ! flutter doctor; then
  log "Warning: flutter doctor reported issues. Please review the output above."
fi

log "Flutter installation completed. Please restart your terminal or source your shell configuration file to use Flutter."
