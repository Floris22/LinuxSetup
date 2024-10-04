#!/bin/bash

# Variables
APPIMAGE_DOWNLOAD_DIR="$HOME/Downloads/cursor*.AppImage"
APPIMAGE_FILE=$(ls $APPIMAGE_DOWNLOAD_DIR 2>/dev/null) # Find the file(s) with the pattern

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Get current dir

APP_DIR="$HOME/Applications/cursor"
LOCAL_APP_DIR="$HOME/.local/share/applications"
CURSOR_DESKTOP_FILE="$LOCAL_APP_DIR/cursor.desktop"

# Creating the directories
mkdir -p "$APP_DIR"
mkdir -p "$LOCAL_APP_DIR"

# Check if the file exists after expansion
if [ -z "$APPIMAGE_FILE" ]; then
    echo
    echo "No AppImage found. Please download the cursor AppImage first"
    echo
    exit 1
fi

# Moving icon and appimage to the right directory
echo
echo "Cursor AppImage found, moving to the right directory"
echo

mv "$APPIMAGE_FILE" "$APP_DIR/"
# Ensure the cursor_icon.jpg exists before moving it
if [ -f "$DIR/cursor_icon.jpg" ]; then
    mv "$DIR/cursor_icon.jpg" "$APP_DIR/"
else
    echo "Warning: cursor_icon.jpg not found. Skipping icon move."
fi

echo
echo "AppImage and icon moved to $APP_DIR"
echo

# Creating .desktop file for cursor
APPIMAGE_NAME=$(basename "$APPIMAGE_FILE") # Get just the file name

cat > "$CURSOR_DESKTOP_FILE" <<EOL
[Desktop Entry]
Name=Cursor
Comment=VSCode AI editor
Exec="$APP_DIR/$APPIMAGE_NAME"
Icon="$APP_DIR/cursor_icon.jpg"
Type=Application
Categories=Development;
EOL

# Giving permissions to the files
chmod +x "$APP_DIR/$APPIMAGE_NAME"
chmod +x "$CURSOR_DESKTOP_FILE"

echo
echo "Cursor setup complete"
echo
