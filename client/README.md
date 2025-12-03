# Docker Setup for Juno Client (React App)

This Dockerfile creates an optimized container image for the Juno React client application. The container builds the static assets and serves them using nginx.

## Prerequisites

Before building the Docker image, ensure you have:

- Docker installed on your system
- The project source code in the `client` directory
- Node.js and npm (for local development, not required for Docker build)

## Building the Docker Image

To build the Docker image, run the following command from the client directory:

```bash
cd client
docker build -t juno-client .
```

## Running the Container

To run the container in standalone mode:

```bash
docker run -d \
  --name juno-client \
  -p 80:80 \
  juno-client
```

To run with environment-specific configurations (when connecting to backend API):

```bash
docker run -d \
  --name juno-client \
  -p 80:80 \
  --env-file .env.production \
  juno-client
```

## Environment Configuration

For production, you may need to configure environment variables. Create a `.env.production` file with:

```
VITE_API_URL=http://your-backend-domain.com/api
VITE_GOOGLE_CLIENT_ID=your-google-client-id
```

Note: Since this is a static build, environment variables need to be replaced during build time. For runtime environment configurations, you may need to implement a different approach or use a reverse proxy.

## Multi-container Setup with Docker Compose

For a complete setup with the backend, you can use a docker-compose.yml file:

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./client
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    environment:
      - VITE_API_URL=http://localhost/api
    networks:
      - app-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - NODE_ENV=production
      - PORT=8000
      - MONGO_URI=mongodb://mongo:27017/juno
      # ... other backend env variables
    depends_on:
      mongo:
        condition: service_healthy
    networks:
      - app-network

  mongo:
    image: mongo:7.0
    volumes:
      - mongo-data:/data/db
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
    healthcheck:
      test: echo 'db.runCommand("ping").ok' | mongosh localhost:27017/test --quiet
      interval: 10s
      timeout: 10s
      retries: 5
      start_period: 40s
    networks:
      - app-network

volumes:
  mongo-data:

networks:
  app-network:
    driver: bridge
```

## Nginx Configuration Features

The nginx configuration includes:

1. **SPA Routing**: Properly handles client-side routing by redirecting to index.html
2. **Gzip Compression**: Enables compression for faster loading
3. **Caching Headers**: Sets appropriate cache headers for static assets
4. **Security Headers**: Includes basic security headers
5. **Static Asset Optimization**: Proper MIME types and caching for assets

## Optimizations

This Docker image includes several optimizations:

1. **Multi-stage build**: Only the built static files are included in the final image
2. **Alpine Linux**: Minimal base image for smaller size
3. **Nginx**: Lightweight, fast web server optimized for serving static files
4. **Asset Caching**: Long-term caching for static assets
5. **Gzip Compression**: Enabled for text-based assets

## Health Checks

By default, this image doesn't include a health check since it's a static file server. For a more sophisticated setup, you could add:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```

## Troubleshooting

### Container won't start
- Verify the build completed successfully
- Check that port 80 is available on the host

### App not loading in browser
- Make sure you're accessing the correct port
- Check browser console for any error messages
- Verify that the API endpoints are accessible if the app makes API calls

### Build fails
- Ensure all dependencies are correctly specified in package.json
- Check that all referenced files exist in the source code

### Routing issues
- The nginx configuration should handle client-side routing properly
- If you have custom routing, you may need to adjust the nginx.conf

## Security Notes

- The container runs nginx as a non-root user (in the nginx:alpine image)
- Security headers are included for basic protections
- Static assets are served with appropriate cache headers
- Only necessary files are included in the final image

## Performance Tips

- The image uses Alpine Linux for a smaller footprint
- Gzip compression is enabled for text assets
- Static assets have long-term caching headers
- The image size is optimized by using multi-stage builds