#!/bin/bash

cat << 'EOF'
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   🚀 OpenCode Development Container                     ║
║   Multi-Project Environment                             ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝

📁 Available Projects in /workspace/:
    • lingking-purple/       (front: lswebapp-lingking-purple)
    • students-blue/         (front: lswebapp-students-blue)
    • teachers-blue/         (front: lswebapp-teacher-blue)

📦 Quick Setup Options:
    full-setup.sh <project>  (Install dependencies for a project)
    fix-deps.sh <project>    (Fix dependencies for backend)
    
    Example: full-setup.sh lingking-purple
    
   Manual Setup:
    cd <project>/front && npm install --legacy-peer-deps
    cd <project>/back && npm install --legacy-peer-deps

📦 Run Commands:
   cd <project>/front && npm run start  (Start Angular dev server)
   cd <project>/back && npm start       (Start backend server)

📁 File manager:
   mc                                   (Midnight Commander)

🔐 Authentication: ✓ Configured

💡 Type 'opencode' to start coding!

EOF
