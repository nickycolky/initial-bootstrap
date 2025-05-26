#!/bin/bash


echo "🚀 Starting initial Void Linux bootstrap script..."

echo "---------------------------------------------------"


GITHUB_REPO_URL="https://github.com/nickycolky/void-setup-scripts.git"

FONT_REPO_URL="https://github.com/nickycolky/my-nerd-fonts.git"


TARGET_FUNCTIONS_DIR="$HOME/.config/fish/functions"

FONT_TEMP_CLONE_PATH="/tmp/my-nerd-fonts-clone"

FONT_INSTALL_DIR="/usr/share/fonts/TTF"


CURRENT_USER=$(whoami)

echo "1. Installing necessary packages"

sudo xbps-install -y git fish-shell xtools-minimal eza nano libspa-bluetooth tlp tlp-rdw btop noto-fonts-emoji zramen fcitx5 fcitx5-chinese-addons fcitx5-configtool fd flatpak hblock

if [ $? -ne 0 ]; then

echo "❌ ERROR: Failed to install packages. Please check your internet connection and try again."

exit 1

fi

echo ""

chsh -s /usr/bin/fish

echo ""


echo "3. Cloning your GitHub repository '$GITHUB_REPO_URL'..."


mkdir -p "$TARGET_FUNCTIONS_DIR"

if [ $? -ne 0 ]; then

echo "❌ ERROR: Failed to create directory $TARGET_FUNCTIONS_DIR. Aborting clone."

exit 1

fi


# Ensure the directory is empty before cloning to avoid issues if it exists but isn't a git repo

if [ -d "$TARGET_FUNCTIONS_DIR/.git" ]; then

echo " Repository already exists in $TARGET_FUNCTIONS_DIR. Pulling latest changes..."

(cd "$TARGET_FUNCTIONS_DIR" && git pull)

if [ $? -ne 0 ]; then

echo "❌ WARNING: Failed to pull latest changes. Attempting to re-clone."

sudo rm -rf "$TARGET_FUNCTIONS_DIR"

mkdir -p "$TARGET_FUNCTIONS_DIR"

git clone "$GITHUB_REPO_URL" "$TARGET_FUNCTIONS_DIR"

fi

else

git clone "$GITHUB_REPO_URL" "$TARGET_FUNCTIONS_DIR"

fi



if [ $? -ne 0 ]; then

echo "❌ ERROR: Failed to clone the repository. Aborting..."

exit 1

fi

echo "✅ GitHub repository cloned successfully into $TARGET_FUNCTIONS_DIR."

echo ""


echo "4. Installing Nerd Fonts from '$FONT_REPO_URL'..."


if git clone --depth 1 "$FONT_REPO_URL" "$FONT_TEMP_CLONE_PATH"; then

echo " Cloned font repository."

else

echo "❌ ERROR: Failed to clone font repository. Aborting font installation."

exit 1

fi


sudo mkdir -p "$FONT_INSTALL_DIR"

# Use a for loop with find to copy files, which is more robust in Bash

find "$FONT_TEMP_CLONE_PATH" -name "*.ttf" -print0 | while IFS= read -r -d $'\0' font_file; do

sudo cp "$font_file" "$FONT_INSTALL_DIR"

if [ $? -ne 0 ]; then

echo "❌ ERROR: Failed to copy $font_file. Aborting font installation."

sudo rm -rf "$FONT_TEMP_CLONE_PATH"

exit 1 # Exit the subshell, not the main script

fi

done


if [ $? -eq 0 ]; then 

echo " Copied .ttf files to $FONT_INSTALL_DIR."

else

echo "❌ ERROR: Failed to copy font files. Aborting font installation."

sudo rm -rf "$FONT_TEMP_CLOCNE_PATH"

exit 1

fi



if sudo rm -rf "$FONT_TEMP_CLONE_PATH"; then

echo " Cleaned up temporary font clone."

else

echo "⚠️ WARNING: Failed to remove temporary font clone '$FONT_TEMP_CLONE_PATH'. Please delete it manually."

fi


if sudo fc-cache -f -v; then

echo "✅ Nerd fonts installed and cache rebuilt."

else

echo "❌ ERROR: Failed to rebuild font cache. Fonts might not appear immediately."

fi

echo ""


echo "---------------------------------------------------"

echo "🚀 Initial bootstrap complete!"

echo "Please log out and log back in to start your new fish shell session."

echo "Once logged in, you can continue your Void setup by running post-install"

echo "---------------------------------------------------"
