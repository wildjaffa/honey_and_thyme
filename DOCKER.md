# Docker Setup for Honey and Thyme

This project includes Docker configuration for building and deploying the Flutter web application.

## Quick Start

### Local Development

```bash
# Build and run with Docker Compose
docker-compose up --build

# Or build and run manually
docker build -t honey-and-thyme .
docker run -p 8080:80 honey-and-thyme
```

The application will be available at `http://localhost:8080`

## Docker Configuration

### Files

- `Dockerfile` - Multi-stage build for Flutter web app with nginx
- `nginx.conf` - Custom nginx configuration with CORS support
- `version_assets.sh` - Script to version main.dart.js for cache busting
- `.dockerignore` - Excludes unnecessary files from build context
- `docker-compose.yml` - Local development setup

### Features

- **Multi-stage build**: Optimized image size
- **Asset versioning**: Automatic cache busting for main.dart.js
- **CORS support**: Configured for proxy environments
- **Zip file downloads**: Proper headers for file downloads
- **Health checks**: Built-in health monitoring

## GitHub Actions

### Automatic Build and Push

The project includes GitHub Actions workflows that automatically:

1. **Build and Push** (`docker-build.yml`):

   - Triggers on pushes to `main` and pull requests
   - Builds Docker image with multi-platform support (amd64, arm64)
   - Pushes to GitHub Container Registry (GHCR)
   - Uses GitHub Actions cache for faster builds
   - Tags images with branch name, SHA, and latest

2. **Deploy** (`deploy.yml`):
   - Manual deployment workflow
   - Supports staging and production environments
   - Can be triggered manually or on releases

### Image Tags

Images are tagged with:

- `latest` - Latest build from main branch
- `main` - Latest build from main branch
- `main-{sha}` - Specific commit builds
- `pr-{number}` - Pull request builds

### Usage

```bash
# Pull the latest image
docker pull ghcr.io/your-username/honeyAndThyme-Flutter:latest

# Run the image
docker run -p 8080:80 ghcr.io/your-username/honeyAndThyme-Flutter:latest
```

## Environment Variables

The application can be configured with environment variables:

```bash
# Example docker-compose with environment variables
version: '3.8'
services:
  honey-and-thyme:
    image: ghcr.io/your-username/honeyAndThyme-Flutter:latest
    ports:
      - "8080:80"
    environment:
      - NGINX_HOST=your-domain.com
      - NGINX_PORT=80
```

## Production Deployment

### Using Docker Compose

```bash
# Production docker-compose
docker-compose -f docker-compose.prod.yml up -d
```

### Using Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: honey-and-thyme
spec:
  replicas: 3
  selector:
    matchLabels:
      app: honey-and-thyme
  template:
    metadata:
      labels:
        app: honey-and-thyme
    spec:
      containers:
        - name: honey-and-thyme
          image: ghcr.io/your-username/honeyAndThyme-Flutter:latest
          ports:
            - containerPort: 80
          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
```

## Troubleshooting

### Build Issues

- Ensure Flutter is properly configured for web builds
- Check that all dependencies are available
- Verify the versioning script has execute permissions

### Runtime Issues

- Check nginx logs: `docker logs <container-id>`
- Verify port mappings are correct
- Ensure CORS headers are properly configured for your environment

### Performance

- The image uses nginx:alpine for smaller size
- Static assets are cached for 1 year
- Gzip compression is enabled
- Multi-stage build reduces final image size
