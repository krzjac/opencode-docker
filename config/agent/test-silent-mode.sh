#!/bin/bash

echo "Testing silent plugin mode..."
echo ""

# Test regular se pushover (for comparison)
echo "1. Regular se pushover (verbose):"
se pushover "Regular test" "Test" 0 magic "" ""

echo ""
echo "----------------------------------------"
echo ""

# Test with silent redirect
echo "2. Silent se pushover (suppressed):"
se pushover "Silent test" "Test" 0 magic "" "" >/dev/null 2>&1
echo "   (Output suppressed - notification sent silently)"

echo ""
echo "Plugin will use method #2 - completely silent"
echo "You'll receive notifications but see no console output!"
