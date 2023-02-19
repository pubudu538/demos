# Envoy - Multiple TLS Domains (For Ingress Use Case)
This guide helps you to deploy Enovy proxy for multiple TLS domains

### Installation Prerequisites

- Docker
- Docker Compose

### Start Envoy

- Start the containers as follows.

   ```
   docker-compose up --detach
   ```

### Send a Reqest 

- Add an /etc/hosts entry for foo.com and bar.com and access the following URLs.

   ```
   https://bar.com:8443/docs
   https://foo.com:8443
   ```
