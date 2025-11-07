#!/bin/bash
# OpenCode Container Startup Script
# This script handles project selection and setup

# Removed set -e temporarily for debugging

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
WORKSPACE="/workspace"
LOG_DIR="/var/log/opencode"
SETUP_LOG="$LOG_DIR/setup.log"
FRONTEND_LOG="$LOG_DIR/frontend.log"
BACKEND_LOG="$LOG_DIR/backend.log"

# Create log directory
mkdir -p "$LOG_DIR"

# Banner
clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}          ${MAGENTA}OpenCode Development Environment${NC}             ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Port assigned: ${YELLOW}${OPENCODE_PORT:-Not Set}${NC}"
echo -e "${GREEN}Workspace: ${YELLOW}${WORKSPACE}${NC}"
echo ""

# Function to list available projects
list_projects() {
    echo -e "${BLUE}Available projects:${NC}" >&2
    local i=1
    for dir in "$WORKSPACE"/*; do
        if [ -d "$dir" ]; then
            local project_name=$(basename "$dir")
            echo -e "  ${GREEN}$i)${NC} $project_name" >&2
            ((i++))
        fi
    done
}

# Function to select project
select_project() {
    list_projects
    
    echo "" >&2
    echo -n "Select project number (or press Enter for default 'lingking-purple'): " >&2
    
    # Read from stdin with timeout to avoid hanging
    read -r -t 30 selection || selection=""
    
    if [ -z "$selection" ]; then
        echo "lingking-purple"
        return
    fi
    
    # Validate input is a number
    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input. Using default 'lingking-purple'${NC}" >&2
        echo "lingking-purple"
        return
    fi
    
    # Get the project by number
    local i=1
    for dir in "$WORKSPACE"/*; do
        if [ -d "$dir" ]; then
            if [ "$i" -eq "$selection" ]; then
                basename "$dir"
                return
            fi
            ((i++))
        fi
    done
    
    # If invalid selection, return default
    echo -e "${RED}Invalid selection. Using default 'lingking-purple'${NC}" >&2
    echo "lingking-purple"
}

# Function to select agent
select_agent() {
    echo -e "${BLUE}Available agents:${NC}" >&2
    echo -e "  ${GREEN}1)${NC} Plan - Analysis and planning without making changes" >&2
    echo -e "  ${GREEN}2)${NC} Debug - Angular debugging workflow (v2)" >&2
    echo -e "  ${GREEN}3)${NC} Documentation - Feature documentation workflow" >&2
    echo -e "  ${GREEN}4)${NC} Implement - Angular implementation workflow" >&2
    echo "" >&2
    echo -n "Select agent number (or press Enter for default 'Plan'): " >&2
    
    # Read from stdin with timeout to avoid hanging
    read -r -t 30 selection || selection=""
    
    if [ -z "$selection" ]; then
        echo "plan"
        return
    fi
    
    # Validate input is a number
    if ! [[ "$selection" =~ ^[1-4]$ ]]; then
        echo -e "${RED}Invalid input. Using default 'Plan'${NC}" >&2
        echo "plan"
        return
    fi
    
    # Map selection to agent name
    case "$selection" in
        1) echo "plan" ;;
        2) echo "angular-debug-orchestrator-2" ;;
        3) echo "feature-doc-orchestrator" ;;
        4) echo "angular-implementor-orchestrator" ;;
        *) echo "plan" ;;
    esac
}

# Function to handle git workflow (pull and create feature branch)
handle_git_workflow() {
    local dir_type="$1"  # "frontend" or "backend"
    
    echo ">>> Handling git workflow for $dir_type..."
    
    # Check if it's a git repository
    if [ ! -d ".git" ]; then
        echo "⚠ Not a git repository, skipping git operations"
        return 0
    fi
    
    # Detect main branch name (main or master)
    echo ">>> Detecting main branch..."
    local main_branch=""
    if git show-ref --verify --quiet refs/heads/main; then
        main_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
        main_branch="master"
    else
        echo "⚠ Could not detect main/master branch"
        return 0
    fi
    echo "✓ Main branch detected: $main_branch"
    
    # Get current branch
    local current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    
    # Switch to main branch if not already on it
    if [ "$current_branch" != "$main_branch" ]; then
        echo ">>> Switching to $main_branch branch..."
        if git checkout "$main_branch" 2>&1; then
            echo "✓ Switched to $main_branch"
        else
            echo "⚠ Failed to switch to $main_branch"
            return 0
        fi
    fi
    
    # Pull latest changes
    echo ">>> Running git pull..."
    if git pull 2>&1; then
        echo "✓ Git pull completed"
    else
        echo "⚠ Git pull failed"
        return 0
    fi
    
    # Create feature branch with timestamp
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local feature_branch="feature/opencode-${dir_type}-${timestamp}"
    echo ">>> Creating feature branch: $feature_branch"
    if git checkout -b "$feature_branch" 2>&1; then
        echo "✓ Feature branch created and checked out: $feature_branch"
    else
        echo "⚠ Failed to create feature branch"
        return 0
    fi
    
    echo "✓ Git workflow completed for $dir_type"
    return 0
}

# Function to setup frontend in background
setup_frontend() {
    local project_dir="$1"
    local port="$2"
    local frontend_dir="$project_dir/front"
    
    {
        echo "=== Frontend Setup Started at $(date) ==="
        echo "Project: $project_dir"
        echo "Port: $port"
        echo ""
        
        if [ ! -d "$frontend_dir" ]; then
            echo "ERROR: Frontend directory not found: $frontend_dir"
            exit 1
        fi
        
        cd "$frontend_dir"
        
        # Handle git workflow
        handle_git_workflow "frontend"
        
        echo ""
        echo ">>> Installing npm dependencies..."
        if npm install --legacy-peer-deps 2>&1; then
            echo "✓ npm install completed"
        else
            echo "✗ npm install failed"
            exit 1
        fi
        
        echo ""
        echo ">>> Starting dev server on port $port..."
        echo "Running: npm run start -- --port $port"
        npm run start -- --port "$port" 2>&1
        
    } < /dev/null >> "$FRONTEND_LOG" 2>&1 &
    
    echo $! > "$LOG_DIR/frontend.pid"
}

# Function to setup backend in background
setup_backend() {
    local project_dir="$1"
    local backend_dir="$project_dir/back"
    
    {
        echo "=== Backend Setup Started at $(date) ==="
        echo "Project: $project_dir"
        echo ""
        
        if [ ! -d "$backend_dir" ]; then
            echo "ERROR: Backend directory not found: $backend_dir"
            exit 1
        fi
        
        cd "$backend_dir"
        
        # Handle git workflow
        handle_git_workflow "backend"
        
        echo ""
        echo ">>> Installing npm dependencies..."
        if npm install --legacy-peer-deps 2>&1; then
            echo "✓ npm install completed"
        else
            echo "✗ npm install failed"
            exit 1
        fi
        
        echo ""
        echo ">>> Starting backend server on port 3000..."
        PORT=3000 node serverSSL.js 2>&1
        
    } < /dev/null >> "$BACKEND_LOG" 2>&1 &
    
    echo $! > "$LOG_DIR/backend.pid"
}

# Function to show setup status
show_setup_status() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Setup tasks running in background...${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Frontend:${NC}"
    echo -e "  • Git workflow (checkout main, pull, create feature branch)"
    echo -e "  • npm install"
    echo -e "  • npm run start --port ${OPENCODE_PORT}"
    echo -e "  ${BLUE}Log: ${FRONTEND_LOG}${NC}"
    echo ""
    echo -e "${YELLOW}Backend:${NC}"
    echo -e "  • Git workflow (checkout main, pull, create feature branch)"
    echo -e "  • npm install"
    echo -e "  • node serverSSL.js"
    echo -e "  ${BLUE}Log: ${BACKEND_LOG}${NC}"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Useful commands:${NC}"
    echo -e "  ${BLUE}tail -f $FRONTEND_LOG${NC}  - Watch frontend logs"
    echo -e "  ${BLUE}tail -f $BACKEND_LOG${NC}   - Watch backend logs"
    echo -e "  ${BLUE}tail -f $SETUP_LOG${NC}     - Watch this setup log"
    echo -e "  ${BLUE}ps aux | grep node${NC}         - Check running processes"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Function to monitor setup progress
monitor_setup() {
    local max_wait=5
    local count=0
    
    echo -e -n "${YELLOW}Initializing background tasks"
    while [ $count -lt $max_wait ]; do
        echo -n "."
        sleep 1
        ((count++))
    done
    echo -e " ${GREEN}Done!${NC}"
}

# Main execution
main() {
    # Log startup
    echo "=== Container Startup at $(date) ===" >> "$SETUP_LOG"
    echo "OPENCODE_PORT: ${OPENCODE_PORT}" >> "$SETUP_LOG"
    
    # Select project
    SELECTED_PROJECT=$(select_project)
    PROJECT_DIR="$WORKSPACE/$SELECTED_PROJECT"
    
    echo ""
    echo -e "${GREEN}✓ Selected project: ${YELLOW}$SELECTED_PROJECT${NC}"
    echo "Selected project: $SELECTED_PROJECT" >> "$SETUP_LOG"
    
    # Select agent
    SELECTED_AGENT=$(select_agent)
    
    echo ""
    echo -e "${GREEN}✓ Selected agent: ${YELLOW}$SELECTED_AGENT${NC}"
    echo "Selected agent: $SELECTED_AGENT" >> "$SETUP_LOG"
    
    # Verify project exists
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}ERROR: Project directory does not exist: $PROJECT_DIR${NC}"
        exit 1
    fi
    
    # Setup port
    if [ -z "$OPENCODE_PORT" ]; then
        echo -e "${YELLOW}⚠ Warning: OPENCODE_PORT not set. Using default 4200${NC}"
        export OPENCODE_PORT=4200
    fi
    
    echo ""
    echo -e "${BLUE}Starting setup processes...${NC}"
    
    # Start frontend setup
    echo -e "${YELLOW}→ Starting frontend setup...${NC}"
    setup_frontend "$PROJECT_DIR" "$OPENCODE_PORT"
    echo "DEBUG: Frontend setup launched, PID: $(cat $LOG_DIR/frontend.pid 2>/dev/null || echo 'FAILED')" >> "$SETUP_LOG"
    
    # Start backend setup
    echo -e "${YELLOW}→ Starting backend setup...${NC}"
    setup_backend "$PROJECT_DIR"
    echo "DEBUG: Backend setup launched, PID: $(cat $LOG_DIR/backend.pid 2>/dev/null || echo 'FAILED')" >> "$SETUP_LOG"
    
    # Monitor initialization
    echo "DEBUG: About to call monitor_setup" >> "$SETUP_LOG"
    monitor_setup
    echo "DEBUG: monitor_setup completed" >> "$SETUP_LOG"
    
    # Show status
    echo "DEBUG: About to call show_setup_status" >> "$SETUP_LOG"
    show_setup_status
    echo "DEBUG: show_setup_status completed" >> "$SETUP_LOG"
    
    # Change to project directory
    cd "$PROJECT_DIR"
    
    # Get container ID for display
    CONTAINER_ID=$(hostname)
    
    # Set up cleanup trap
    echo "DEBUG: Setting up cleanup trap" >> "$SETUP_LOG"
    cleanup() {
        echo ""
        echo -e "${YELLOW}Shutting down services...${NC}"
        
        if [ -f "$LOG_DIR/frontend.pid" ]; then
            kill $(cat "$LOG_DIR/frontend.pid") 2>/dev/null || true
            rm "$LOG_DIR/frontend.pid"
        fi
        
        if [ -f "$LOG_DIR/backend.pid" ]; then
            kill $(cat "$LOG_DIR/backend.pid") 2>/dev/null || true
            rm "$LOG_DIR/backend.pid"
        fi
        
        echo -e "${GREEN}Cleanup complete${NC}"
    }
    
    trap cleanup EXIT INT TERM
    
    # Save agent selection for later use
    echo "$SELECTED_AGENT" > "$LOG_DIR/selected_agent"
    
    # Show status
    echo ""
    echo -e "${GREEN}✓ Development servers are running in background${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Access your application:${NC}"
    echo -e "  ${BLUE}Frontend:${NC} http://localhost:$OPENCODE_PORT"
    echo -e "  ${BLUE}Backend:${NC}  http://localhost:3000"
    echo -e "  ${BLUE}Preview:${NC}  http://krzjacb.ddns.net/preview/$OPENCODE_PORT"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Selected agent: ${YELLOW}$SELECTED_AGENT${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Useful commands:${NC}"
    echo -e "  ${BLUE}tail -f $FRONTEND_LOG${NC}  - Watch frontend logs"
    echo -e "  ${BLUE}tail -f $BACKEND_LOG${NC}   - Watch backend logs"
    echo -e "  ${BLUE}docker exec -it $CONTAINER_ID opencode --agent $SELECTED_AGENT${NC}"
    echo -e "     └─ Launch OpenCode with selected agent"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo "DEBUG: Setup complete, launching OpenCode" >> "$SETUP_LOG"
    echo -e "${YELLOW}Container ready. Frontend/Backend running in background.${NC}"
    echo -e "${GREEN}Launching OpenCode with agent: ${YELLOW}$SELECTED_AGENT${NC}"
    echo ""
    
    # Launch OpenCode with the selected agent
    exec opencode --agent "$SELECTED_AGENT"
}

# Run main function
main
