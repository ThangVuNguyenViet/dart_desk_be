# Serverpod Deployment Reference

## Overview

Serverpod operates as a Dart-compiled native application compatible with any platform supported by the Dart tooling. You can deploy using containerization (Docker), manual compilation, or managed hosting services.

## Server Requirements

### System Requirements
- Platform: Any OS supported by Dart (Linux, macOS, Windows, etc.)
- Dart Runtime: Latest stable Dart SDK
- Database: PostgreSQL (version 12 or higher recommended)
- Memory: Minimum 512MB RAM (varies based on load)
- Storage: Adequate space for application and database

### Network Requirements
- Open ports for server communication
- HTTPS/TLS certificate for production
- Load balancer (optional, for high availability)

## Port Configuration

The Serverpod server uses three default ports:

- **Port 8080**: Primary connection point for generated clients
- **Port 8081**: Serverpod Insights tooling access (recommend IP restrictions)
- **Port 8082**: Built-in web server

**Production Security:**
- Only expose port 8080 publicly
- Restrict port 8081 to internal networks or VPN
- Configure firewall rules appropriately

## Essential Configuration

### 1. Database Configuration

Update `config/production.yaml` with production database settings:

```yaml
database:
  host: your-db-host.example.com
  port: 5432
  name: your_database
  user: your_db_user
```

### 2. Passwords Configuration

Securely deploy `config/passwords.yaml` to your server:

```yaml
database: your_secure_db_password
api_key: your_api_keys
# Add other sensitive credentials
```

**Security Best Practices:**
- Never commit `passwords.yaml` to version control
- Use environment variables or secret management services
- Encrypt at rest
- Rotate credentials regularly

### 3. Environment Configuration

Set up environment-specific configurations:
- Development: `config/development.yaml`
- Staging: `config/staging.yaml`
- Production: `config/production.yaml`

## Deployment Methods

### Method 1: Serverpod Cloud (Managed Hosting)

**Current Status:** Private beta

**Features:**
- Zero configuration deployment
- Automatic scaling
- Built-in monitoring
- Managed database
- SSL certificates included
- Deployment in minutes

**Getting Started:**
1. Complete the Serverpod Cloud application form
2. Receive beta access credentials
3. Deploy via CLI or dashboard
4. Monitor through Serverpod Cloud console

**Benefits:**
- No infrastructure management
- Automatic updates
- Built-in backups
- Professional support

### Method 2: Docker Deployment

**Prerequisites:**
- Docker installed
- Docker Compose
- Container registry access (Docker Hub, AWS ECR, etc.)

**Steps:**

1. **Build Docker Image:**
```bash
cd server
docker build -t your-app-name:latest .
```

2. **Create Docker Compose File:**
```yaml
version: '3.8'
services:
  server:
    image: your-app-name:latest
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    environment:
      - SERVERPOD_ENV=production
    depends_on:
      - postgres

  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: your_database
      POSTGRES_USER: your_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

3. **Deploy:**
```bash
docker-compose up -d
```

**Docker Best Practices:**
- Use multi-stage builds for smaller images
- Tag images with version numbers
- Use health checks
- Configure resource limits
- Implement logging drivers

### Method 3: Manual Deployment

**Prerequisites:**
- Dart SDK installed on server
- PostgreSQL database
- Reverse proxy (nginx/Apache) for HTTPS

**Steps:**

1. **Compile Application:**
```bash
cd server
dart compile exe bin/main.dart -o serverpod_server
```

2. **Transfer Files:**
```bash
# Transfer compiled binary and config files
scp serverpod_server user@server:/opt/serverpod/
scp -r config user@server:/opt/serverpod/
```

3. **Set Up Systemd Service:**
```ini
[Unit]
Description=Serverpod Server
After=network.target

[Service]
Type=simple
User=serverpod
WorkingDirectory=/opt/serverpod
ExecStart=/opt/serverpod/serverpod_server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

4. **Start Service:**
```bash
sudo systemctl enable serverpod
sudo systemctl start serverpod
```

### Method 4: Terraform Deployment

Serverpod provides community Terraform scripts for automated infrastructure provisioning.

**Supported Platforms:**
- AWS
- Google Cloud Platform
- Azure
- DigitalOcean

**Resources:**
- Terraform scripts on GitHub
- Infrastructure as Code templates
- Automated scaling configurations

## Health Monitoring

### Health Check Endpoint

The server exposes a health check at:
```
http://your-server:8080/
```

**Usage:**
- Load balancer health checks
- Monitoring systems (Prometheus, Datadog, etc.)
- Uptime monitoring services
- Automated failover systems

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-11-28T10:00:00Z"
}
```

## Reverse Proxy Configuration

### Nginx Example

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/ssl/certs/your-cert.pem;
    ssl_certificate_key /etc/ssl/private/your-key.pem;

    # Client API
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Insights (restrict access)
    location /insights {
        allow 10.0.0.0/8;  # Internal network only
        deny all;
        proxy_pass http://localhost:8081;
    }
}
```

## Database Migration in Production

**Safe Migration Process:**

1. **Backup Database:**
```bash
pg_dump your_database > backup_$(date +%Y%m%d).sql
```

2. **Test Migration:**
```bash
# Test on staging environment first
dart bin/main.dart --apply-migrations --role maintenance
```

3. **Apply to Production:**
```bash
dart bin/main.dart --apply-migrations
```

4. **Verify:**
```bash
# Check application logs
# Verify health endpoint
# Test critical endpoints
```

## Monitoring & Logging

### Application Monitoring
- Use Serverpod Insights (port 8081)
- Configure external monitoring (New Relic, Datadog, etc.)
- Set up alerting for errors and performance issues

### Logging Configuration
```yaml
# config/production.yaml
logging:
  level: info
  format: json
  output: stdout
```

### Log Aggregation
- Centralize logs (ELK stack, CloudWatch, etc.)
- Set up log rotation
- Monitor error rates
- Track performance metrics

## Scaling Strategies

### Vertical Scaling
- Increase server resources (CPU, RAM)
- Optimize database queries
- Use caching effectively

### Horizontal Scaling
- Deploy multiple server instances
- Use load balancer for traffic distribution
- Implement session stickiness if needed
- Scale database with read replicas

### Caching
- Enable Redis for distributed caching
- Configure cache TTL appropriately
- Implement cache invalidation strategies

## Security Checklist

- [ ] HTTPS enabled with valid SSL certificate
- [ ] Firewall configured (only necessary ports open)
- [ ] Database connections encrypted
- [ ] passwords.yaml secured and not in version control
- [ ] Port 8081 (Insights) restricted to internal network
- [ ] Regular security updates applied
- [ ] Rate limiting configured
- [ ] Authentication implemented
- [ ] Input validation enabled
- [ ] CORS properly configured
- [ ] Database backups automated
- [ ] Monitoring and alerting active

## Performance Optimization

1. **Database Optimization**
   - Index frequently queried fields
   - Optimize query patterns
   - Use connection pooling
   - Monitor slow queries

2. **Caching Strategy**
   - Cache frequently accessed data
   - Use Redis for distributed caching
   - Implement cache warming

3. **Resource Management**
   - Configure worker pool sizes
   - Optimize memory usage
   - Monitor CPU utilization

## Troubleshooting

### Common Issues

**Server won't start:**
- Check database connectivity
- Verify configuration files
- Review application logs
- Ensure ports are available

**Performance degradation:**
- Monitor database performance
- Check memory usage
- Review slow endpoints
- Analyze query patterns

**Connection issues:**
- Verify firewall rules
- Check SSL certificates
- Review proxy configuration
- Test health endpoint

## Best Practices

1. **Use CI/CD pipelines** for automated deployments
2. **Implement blue-green deployments** for zero downtime
3. **Monitor application health** continuously
4. **Regular backups** of database and configurations
5. **Test migrations** on staging before production
6. **Document deployment process** for team
7. **Use secrets management** for sensitive data
8. **Implement rate limiting** to prevent abuse
9. **Set up alerts** for critical issues
10. **Regular security audits** and updates

## Resources

- **Deployment Strategy**: https://docs.serverpod.dev/deployments/deployment-strategy
- **Serverpod Cloud**: https://cloud.serverpod.dev/
- **Community Scripts**: https://github.com/serverpod/serverpod
- **Terraform Templates**: Community contributions on GitHub
