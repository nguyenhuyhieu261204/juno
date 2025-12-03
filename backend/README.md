# Docker Setup for Juno Backend

This Dockerfile creates an optimized container image for the Juno backend API with multi-stage build to minimize image size.

## Prerequisites

Before building the Docker image, ensure you have:

- Docker installed on your system
- The project source code in the `backend` directory
- A MongoDB instance available (either local, remote, or via docker-compose)

## Building the Docker Image

To build the Docker image, run the following command from the project root:

```bash
cd backend
docker build -t juno-backend .
```

## Running the Container

To run the container, you need to provide the required environment variables:

```bash
docker run -d \
  --name juno-backend \
  -p 8000:8000 \
  -e NODE_ENV=production \
  -e PORT=8000 \
  -e MONGO_URI=mongodb://your-mongo-host:27017/juno \
  -e SESSION_SECRET=your-very-secure-session-secret-here \
  -e SESSION_EXPIRES_IN=1d \
  -e GOOGLE_CLIENT_ID=your-google-client-id \
  -e GOOGLE_CLIENT_SECRET=your-google-client-secret \
  -e GOOGLE_CALLBACK_URL=http://localhost:8000/api/auth/google/callback \
  -e FRONTEND_ORIGIN=http://localhost:3000 \
  -e FRONTEND_GOOGLE_CALLBACK_URL=http://localhost:3000/google/callback \
  juno-backend
```

## Environment Variables

The following environment variables are required for the application to run properly:

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Node.js environment (development/production) | production |
| `PORT` | Port number for the application | 8000 |
| `MONGO_URI` | MongoDB connection string | Required |
| `SESSION_SECRET` | Secret key for session encryption | Required |
| `SESSION_EXPIRES_IN` | Session expiration time | 1d |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID | Required for Google auth |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret | Required for Google auth |
| `GOOGLE_CALLBACK_URL` | Google OAuth callback URL | http://localhost:8000/api/auth/google/callback |
| `FRONTEND_ORIGIN` | Frontend application origin | http://localhost:3000 |
| `FRONTEND_GOOGLE_CALLBACK_URL` | Frontend Google callback URL | http://localhost:3000/google/callback |

## Health Checks

The container includes health checks that monitor the application status:
- Liveness: Checks `/health/live` endpoint
- Startup time: About 5s before health checks begin

## Docker Compose (Optional)

For a complete setup with MongoDB, you can use docker-compose.yml (not included but can be created separately):

```yaml
version: '3.8'

services:
  backend:
    build: 
      context: ./
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - NODE_ENV=production
      - PORT=8000
      - MONGO_URI=mongodb://mongo:27017/juno
      - SESSION_SECRET=your-very-secure-session-secret-here
      - SESSION_EXPIRES_IN=1d
      - GOOGLE_CLIENT_ID=your-google-client-id
      - GOOGLE_CLIENT_SECRET=your-google-client-secret
      - GOOGLE_CALLBACK_URL=http://localhost:8000/api/auth/google/callback
      - FRONTEND_ORIGIN=http://localhost:3000
      - FRONTEND_GOOGLE_CALLBACK_URL=http://localhost:3000/google/callback
    depends_on:
      mongo:
        condition: service_healthy
    restart: unless-stopped

  mongo:
    image: mongo:7.0
    ports:
      - "27017:27017"
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
    restart: unless-stopped

volumes:
  mongo-data:
```

## Optimizations

This Docker image includes several optimizations:

1. **Multi-stage build**: Only production dependencies are included in the final image
2. **Alpine Linux**: Minimal base image for smaller size
3. **Non-root user**: Runs as nodejs user for security
4. **Dumb-init**: Proper signal handling for graceful shutdowns
5. **Health checks**: Built-in health monitoring
6. **Cache cleaning**: Ensures minimal image size

## Troubleshooting

### Container won't start
- Verify all required environment variables are provided
- Check that MongoDB is accessible at the specified URI
- Make sure port 8000 is available

### Health checks failing
- Ensure MongoDB is running and accessible
- Check application logs with `docker logs juno-backend`

### Memory issues
- The container should run in less than 200MB of RAM
- Adjust container memory limits if needed

## Security Notes

- The application runs as a non-root user (nodejs)
- Always use strong, unique values for SESSION_SECRET
- Use environment variables for configuration, not hardcoded values
- Enable SSL/TLS in production environments