#!/bin/bash

# Setup script for OpenCode Completion Notification Plugin

echo "Setting up OpenCode Completion Notification Plugin..."

# Create plugin directory if it doesn't exist
PLUGIN_DIR="$HOME/.config/opencode/plugin"
mkdir -p "$PLUGIN_DIR"

# Copy the plugin file
CURRENT_DIR="$(pwd)"
if [ -f "$CURRENT_DIR/completion-notification-temp.js" ]; then
    cp "$CURRENT_DIR/completion-notification-temp.js" "$PLUGIN_DIR/completion-notification.js"
    echo "✓ Plugin installed to $PLUGIN_DIR/completion-notification.js"
else
    echo "✗ Error: completion-notification-temp.js not found in current directory"
    exit 1
fi

# Verify installation
if [ -f "$PLUGIN_DIR/completion-notification.js" ]; then
    echo "✓ Plugin installation verified"
    echo ""
    echo "Plugin installed successfully!"
    echo "The plugin will be automatically loaded when you restart OpenCode."
else
    echo "✗ Error: Plugin installation failed"
    exit 1
fi
