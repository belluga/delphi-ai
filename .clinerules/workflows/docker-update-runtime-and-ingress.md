---
name: docker-update-runtime-and-ingress
description: "Ensure Docker images, Compose stacks, and ingress configs stay aligned with documented API routes while keeping runtime cost and build performance under control."
---

# Workflow: Update Runtime & Ingress (DevOps)

## Purpose

Ensure Docker images, Compose stacks, and ingress configs stay aligned with documented API routes while keeping runtime cost and build performance under control.

## Triggers

- Changes to Laravel routes/API prefixes requiring ingress updates
- Dockerfile or docker-compose modifications
- Requests to improve build time, container size, or hosting cost

## Prerequisites

- [ ] `submodule_laravel-app_summary.md` reviewed for routing layout
- [ ] Current Docker/Compose files reviewed
- [ ] DevOps roadmap section reviewed
- [ ] Cost/build metrics understood

## Procedure

### Step 1: Persona Alignment

Run Persona Selection as **DevOps Engineer** and review roadmap items tied to ingress/runtime work.

### Step 2: Collect Diffs

List changes requested:
- Route changes (new prefixes, paths)
- Base image updates
- New services
- Resource limit changes
- Build optimizations

### Step 3: Apply Docker/Compose Changes

**Update Dockerfiles:**
```dockerfile
# Use minimal base images
FROM php:8.2-fpm-alpine AS base

# Multi-stage for smaller images
FROM base AS production
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
```

**Update docker-compose.yml:**
```yaml
services:
  laravel:
    build:
      context: ./laravel-app
      target: production
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
```

### Step 4: Ingress Parity

**Mirror Laravel routing groups into ingress:**

| Laravel Route Group | Nginx Location | Domain |
|---------------------|----------------|--------|
| Landlord API | `/api/landlord/` | main domain |
| Tenant API | `/api/v1/` | tenant domain |
| Tenant Admin | `/admin/api/v1/` | tenant domain |
| Account API | `/api/v1/accounts/` | tenant domain |

**Nginx configuration:**
```nginx
# Landlord routes (main domain only)
server {
    server_name api.example.com;
    
    location /api/landlord/ {
        proxy_pass http://laravel:8080;
    }
}

# Tenant routes (tenant domains)
server {
    server_name ~^(?<tenant>.+)\.example\.com$;
    
    location /api/v1/ {
        proxy_pass http://laravel:8080;
    }
    
    location /admin/api/v1/ {
        proxy_pass http://laravel:8080;
    }
}
```

### Step 5: Verification

```bash
# Build images
docker compose build

# Run smoke checks
docker compose up -d
curl http://localhost/api/v1/health
curl http://localhost/admin/api/v1/health

# Run pipeline stages
docker compose run --rm laravel composer test
```

### Step 6: Documentation + Roadmap

- Record change in DevOps section of roadmap
- Note cost/time impact
- Alert Flutter/Laravel personas if routes changed

### Step 7: Session Summary

Capture:
- Updates made
- Verification results
- Follow-up actions
- Cost impact

## Common Patterns

### Multi-stage Dockerfile
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine AS production
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
```

### Resource Limits
```yaml
services:
  flutter-web:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.1'
          memory: 64M
```

### Health Checks
```yaml
services:
  laravel:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Optimization Checklist

- [ ] Minimal base images used
- [ ] Multi-stage builds implemented
- [ ] Shared layers maximized
- [ ] Resource limits set
- [ ] Health checks configured
- [ ] Build cache optimized

## Outputs

- [ ] Updated Docker/Compose/ingress files
- [ ] DevOps roadmap entry with impact
- [ ] Notes to other personas if routes changed

## Validation Checklist

- [ ] Docker build succeeds
- [ ] Test commands pass
- [ ] Routes resolve correctly
- [ ] Ingress matches Laravel routing
- [ ] Roadmap entry exists