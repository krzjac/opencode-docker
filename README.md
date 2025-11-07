# OpenCode Docker Environment

Complete Docker environment for OpenCode development with support for multiple Angular projects.

## Features

- **Multi-project support**: lingking-purple, students-blue, teachers-blue
- **Automatic dependency resolution**: Handles peer dependencies and npm configuration
- **Development servers**: Frontend (4200) and Backend (3000) 
- **OpenCode integration**: Pre-configured with all necessary agents and plugins

## What's Included

- OpenCode CLI (`opencode-ai` package)
- Your `opencode.json` configuration
- All custom agents from `.config/opencode/agent/`
- All plugins from `.config/opencode/plugin/`
- Plugin dependencies
- Three Angular projects with automatic setup

## Quick Start

```bash
# Build the image
docker build -t opencode-docker-image:latest .

# Run with default project (lingking-purple)
docker run -p 4200:4200 -p 3000:3000 opencode-docker-image:latest

# Run with teachers-blue project
echo "3" | docker run -p 4200:4200 -p 3000:3000 -i opencode-docker-image:latest
```

## Projects

1. **lingking-purple** - Default Angular project
2. **students-blue** - Student management application  
3. **teachers-blue** - Teacher management application (with peer dependency fixes)

## Recent Fixes

### Teachers-Blue Peer Dependency Resolution (v23+)

- **Problem**: Missing peer dependencies `jspdf@2.5.1` and `white-web-sdk@>=2.16.52`
- **Solution**: Dockerfile automatically patches package.json during build
- **Result**: Teachers-blue now compiles successfully without errors

## Access Points

- **Frontend**: http://localhost:4200
- **Backend**: http://localhost:3000
- **Preview**: http://krzjacb.ddns.net/preview/4200

## Build the Image

```bash
docker build -t opencode-docker-image:latest .
```

## Run the Container

### Basic Usage

```bash
docker run -it -v "$(pwd)":/workspace opencode-docker-image:latest /bin/sh
```

Or use the helper script:

```bash
./run.sh
```

### With Environment Variables

If you need to pass API keys or other environment variables:

```bash
docker run -it \
  -v "$(pwd)":/workspace \
  -e ANTHROPIC_API_KEY="your-key" \
  -e OPENAI_API_KEY="your-key" \
  opencode-custom \
  /bin/sh
```

## Container Structure

```
/workspace/
├── lingking-purple/
├── students-blue/
└── teachers-blue/
    ├── front/          # Angular frontend
    └── back/           # Node.js backend
```

## Logs

- Frontend: `/var/log/opencode/frontend.log`
- Backend: `/var/log/opencode/backend.log`
- Setup: `/var/log/opencode/setup.log`

## Inside the Container

Once inside the container, you can run OpenCode:

```bash
opencode
```

## Save/Export the Image

To save the image to a file:

```bash
docker save opencode-docker-image:latest > opencode-docker-image.tar
```

To load it on another machine:

```bash
docker load < opencode-docker-image.tar
```

## Push to Docker Hub (Optional)

1. Tag the image:
```bash
docker tag opencode-docker-image:latest your-username/opencode-docker:latest
```

2. Push to Docker Hub:
```bash
docker push your-username/opencode-docker:latest
```

## Development

All changes are automatically committed to:
- **Docker configuration**: https://github.com/krzjac/opencode-docker
- **Project source**: https://github.com/krzjac/lswebapp-teacher-blue
