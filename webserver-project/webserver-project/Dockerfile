# Use a small, official base image
FROM nginx:alpine

# Copy our custom website into Nginx's default serving directory
COPY html/ /usr/share/nginx/html/

# Document the port the container listens on
EXPOSE 80

# Basic health check so `docker ps` reports healthy/unhealthy status
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1
