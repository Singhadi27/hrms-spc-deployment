# 🚀 HRMS Self-Contained Deployment

This repository contains everything needed to deploy the HRMS (Human Resource Management System) application. It automatically clones and deploys both the backend and frontend components.

## 📋 What's Included

- **Backend API** (`hrms-backend`) - Node.js/Express application
- **Frontend UI** (`hrms-spc`) - React application with nginx
- **Docker Compose** - Orchestrates all services
- **Automated Cloning** - Fetches latest code from GitHub during deployment

## 🛠️ Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Git installed
- At least 4GB RAM, 2 CPU cores recommended

### One-Command Deployment

```bash
# Clone this deployment repository
git clone https://github.com/Singhadi27/hrms-spc-deployment.git
cd hrms-spc-deployment

# Deploy everything (this clones repos and starts services)
./deploy.sh
```

That's it! Your application will be running at `http://localhost`

## 📁 Project Structure

```
hrms-spc-deployment/
├── docker-compose.yml      # Main orchestration
├── Dockerfile.clone        # Clones repositories during build
├── deploy.sh              # Deployment script
├── README.md              # This file
├── hrms-backend/          # Auto-cloned during deployment
└── hrms-spc/             # Auto-cloned during deployment
```

## 🎯 Deployment Commands

```bash
# Deploy application
./deploy.sh

# Update to latest version
./deploy.sh update

# View logs
./deploy.sh logs

# Stop services
./deploy.sh stop

# Clean up everything
./deploy.sh cleanup
```

## ⚙️ Configuration

### Environment Variables

Before first deployment, configure your environment:

```bash
# Edit the .env file (created automatically)
nano hrms-backend/.env
```

Required variables:
```bash
# Database
MONGODB_URI=mongodb://your-connection-string

# Security
JWT_SECRET=your-super-secure-secret

# CORS (auto-configured for local development)
CORS_ORIGIN=http://localhost,http://localhost:80
```

### Production Deployment

For production, update these settings:

1. **Database**: Use MongoDB Atlas or AWS DocumentDB
2. **Domain**: Configure nginx for your domain
3. **SSL**: Add SSL certificates
4. **Security**: Restrict CORS origins to your domain only

## 🔧 How It Works

1. **Clone Phase**: `Dockerfile.clone` clones the latest code from:
   - `https://github.com/7UpadhyayKrishna/hrms-backend`
   - `https://github.com/7UpadhyayKrishna/hrms-spc`

2. **Build Phase**: Docker builds images for backend and frontend

3. **Deploy Phase**: Docker Compose orchestrates all services

4. **Network**: Services communicate via Docker network

## 🌐 Access Points

After deployment:
- **Frontend**: http://localhost (nginx on port 80)
- **Backend API**: http://localhost:5001
- **Health Check**: http://localhost:5001/health

## 🔍 Troubleshooting

### Check Service Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f hrms-backend
docker-compose logs -f hrms-spc
```

### Common Issues

**Port 80 already in use:**
```bash
sudo netstat -tulpn | grep :80
sudo systemctl stop httpd  # Stop Apache if running
```

**Permission denied:**
```bash
sudo usermod -a -G docker $USER
# Logout and login again
```

**Database connection failed:**
- Check MongoDB connection string
- Ensure MongoDB is running and accessible
- Verify network connectivity

**Build fails:**
```bash
# Clear Docker cache
docker system prune -f
# Try again
./deploy.sh update
```

## 🔄 Updating

To update to the latest version:

```bash
./deploy.sh update
```

This will:
1. Stop all services
2. Remove old code
3. Clone fresh repositories
4. Rebuild and restart services

## 🚀 Production Deployment

For AWS EC2 or other cloud platforms:

```bash
# On your server
git clone https://github.com/Singhadi27/hrms-spc-deployment.git
cd hrms-spc-deployment

# Configure environment
nano hrms-backend/.env  # Add production settings

# Deploy
./deploy.sh
```

### AWS EC2 Specific:
- Instance type: t3.medium or larger
- Security groups: Allow ports 22, 80, 443
- Storage: 20GB minimum

## 📊 Monitoring

### Basic Monitoring
```bash
# Container resource usage
docker stats

# System resources
htop  # Install with: sudo apt install htop

# Application logs
./deploy.sh logs
```

### Health Checks
```bash
# Frontend
curl http://localhost

# Backend
curl http://localhost:5001/health

# Database connection
docker-compose exec hrms-backend node -e "require('./src/config/database').connectDB()"
```

## 🔒 Security Notes

- Change default JWT secret in production
- Use HTTPS in production
- Restrict database access to application only
- Regular security updates
- Monitor logs for suspicious activity

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs: `./deploy.sh logs`
3. Ensure all prerequisites are met
4. Check GitHub repository URLs are accessible

## 🎉 Success!

Your HRMS application is now deployed with a single command! The system automatically handles code cloning, dependency installation, and service orchestration.