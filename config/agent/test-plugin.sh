#!/bin/bash

echo "Testing OpenCode Completion Notification Plugin..."
echo ""
echo "Step 1: Testing se pushover command directly..."
se pushover "Test notification from OpenCode plugin setup" "Plugin Test" 1 "magic" "" ""

echo ""
echo "Step 2: Plugin installation status..."
if [ -f "$HOME/.config/opencode/plugin/completion-notification.js" ]; then
    echo "✓ Plugin file exists"
    echo "  Location: $HOME/.config/opencode/plugin/completion-notification.js"
    echo "  Size: $(wc -c < $HOME/.config/opencode/plugin/completion-notification.js) bytes"
else
    echo "✗ Plugin file not found"
fi

echo ""
echo "Step 3: Checking plugin syntax..."
if command -v node >/dev/null 2>&1; then
    node --check "$HOME/.config/opencode/plugin/completion-notification.js" 2>&1
    if [ $? -eq 0 ]; then
        echo "✓ Plugin syntax is valid"
    else
        echo "✗ Plugin syntax has errors"
    fi
else
    echo "⚠ Node.js not available for syntax check"
fi

echo ""
echo "Test complete!"
echo ""
echo "Next steps:"
echo "1. Restart OpenCode to load the plugin"
echo "2. The plugin will automatically send notifications when:"
echo "   - The agent completes a response (session.idle event)"
echo "   - A message processing is done (message.done event)"
echo ""
echo "To monitor plugin activity, check the OpenCode logs for:"
echo "   - 'CompletionNotificationPlugin initialized!'"
echo "   - 'Sending Pushover notification:' messages"
