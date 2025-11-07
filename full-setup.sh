#!/bin/bash

# Check if project name is provided
PROJECT=${1:-lingking-purple}

if [ ! -d "/workspace/$PROJECT" ]; then
    echo "❌ Error: Project '$PROJECT' not found in /workspace/"
    echo ""
    echo "Available projects:"
    ls -1 /workspace/
    echo ""
    echo "Usage: full-setup.sh <project-name>"
    echo "Example: full-setup.sh lingking-purple"
    exit 1
fi

echo "🚀 Starting full setup for $PROJECT project..."

# Navigate to workspace
cd /workspace/$PROJECT

echo "📦 Installing frontend dependencies..."
cd front
npm install --legacy-peer-deps

echo "📦 Installing backend dependencies..."
cd ../back
npm install --legacy-peer-deps

echo ""
echo "✅ Setup complete for $PROJECT!"
echo ""
echo "🎯 To start the application:"
echo "   Backend:  cd /workspace/$PROJECT/back && node serverSSL.js"
echo "   Frontend: cd /workspace/$PROJECT/front && npm run start"
echo ""
echo "🌐 Backend will run on port 3000"
echo "🌐 Frontend will run on port 4200"