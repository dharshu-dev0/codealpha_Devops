# Task 4: Web Server using Docker

A simple custom web page served via **Nginx** running inside a **Docker container**.

## Project structure
```
webserver-project/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
└── html/
    └── index.html
```

## 1. Build the image
```bash
cd webserver-project
docker build -t my-custom-webserver .
```
Expected output ends with:
```
=> exporting to image
=> => naming to docker.io/library/my-custom-webserver
```

## 2. Run the container
```bash
docker run -d --name custom-site -p 8080:80 my-custom-webserver
```
Output: a container ID hash is printed.

**Or, using Docker Compose (does build + run in one step):**
```bash
docker compose up -d --build
```

## 3. View it in the browser
Open: **http://localhost:8080**

You should see a dark page with a green "CONTAINER RUNNING" badge and the heading
"Hello from my custom Docker web server!"

## 4. Check container lifecycle & status
```bash
docker ps
```
```
CONTAINER ID   IMAGE                 STATUS                   PORTS                  NAMES
7f2a9c8e3d1b   my-custom-webserver   Up 10 seconds (healthy)  0.0.0.0:8080->80/tcp   custom-site
```

## 5. Monitor health & logs
```bash
docker stats custom-site      # live CPU/memory usage
docker logs -f custom-site    # live request logs
docker inspect custom-site    # full container details
```

## 6. Stop / remove
```bash
docker stop custom-site
docker rm custom-site
docker rmi my-custom-webserver
```

## Best practices applied here
- Used `nginx:alpine` — a small official base image
- Added a `HEALTHCHECK` so Docker reports container health status
- Used `.dockerignore` to keep the build context clean
- Named container/image meaningfully instead of relying on defaults
- Included `docker-compose.yml` for reproducible, one-command startup
