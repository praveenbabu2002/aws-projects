# Docker WebApp

This project shows how to build a Docker image that hosts a simple static web page.

### Commands to Run
```bash
docker build -t docker-webapp .
docker run -d -p 8080:80 docker-webapp