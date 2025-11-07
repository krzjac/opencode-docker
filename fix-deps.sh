#!/bin/bash

# Check if project name is provided
PROJECT=${1:-lingking-purple}

if [ ! -d "/workspace/$PROJECT" ]; then
    echo "❌ Error: Project '$PROJECT' not found in /workspace/"
    echo ""
    echo "Available projects:"
    ls -1 /workspace/
    exit 1
fi

echo "🔧 Installing backend dependencies for $PROJECT..."

# Navigate to backend directory
cd /workspace/$PROJECT/back

# Install all dependencies with legacy peer deps flag
echo "Installing dependencies (using --legacy-peer-deps to resolve peer dependency conflicts)..."
npm install --legacy-peer-deps

echo "✅ Dependencies installed!"
echo ""
echo "🚀 You can now start the backend with:"
echo "   cd /workspace/$PROJECT/back && node serverSSL.js"