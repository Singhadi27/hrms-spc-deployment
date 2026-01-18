# 🚀 HRMS Self-Contained Deployment

This repository contains everything needed to deploy the HRMS (Human Resource Management System) application to AWS EC2. It automatically clones and deploys both the backend and frontend components.

## 📋 What's Included

- **Backend API** (`hrms-backend`) - Node.js/Express application
- **Frontend UI** (`hrms-spc`) - React application with nginx
- **Docker Compose** - Orchestrates all services
- **Automated Cloning** - Fetches latest code from GitHub during deployment
- **EC2 Optimized** - Configured for cloud deployment

## 🛠️ EC2 Deployment Steps

### Prerequisites
- AWS EC2 instance (t3.medium recommended)
- Docker & Docker Compose installed on EC2
- Git installed
- Security groups configured (ports 22, 80, 443)

### One-Command EC2 Deployment

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP

# Clone this deployment repository
git clone https://github.com/Singhadi27/hrms-spc-deployment.git
cd hrms-spc-deployment

# Deploy everything (this clones repos and starts services)
./deploy.sh
```

That's it! Your application will be running at `http://YOUR_EC2_PUBLIC_IP`

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

## ⚙️ EC2 Configuration

### Environment Variables

Before deployment, configure your environment for EC2:

```bash
# Edit the .env file (created automatically)
nano hrms-backend/.env
```

Required variables for EC2:
```bash
# Database - Use MongoDB Atlas for EC2
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/hrms

# Security - Generate a strong secret
JWT_SECRET=your-super-secure-jwt-secret-change-this-in-production-32-chars-min

# CORS - Configure for your EC2 public IP and domain
CORS_ORIGIN=http://YOUR_EC2_PUBLIC_IP,http://YOUR_EC2_PUBLIC_IP:80,https://yourdomain.com
FRONTEND_URL=http://YOUR_EC2_PUBLIC_IP

# Email Configuration (optional but recommended)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
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

## 🌐 EC2 Access Points

After deployment on EC2:
- **Frontend**: http://YOUR_EC2_PUBLIC_IP (nginx on port 80)
- **Backend API**: http://YOUR_EC2_PUBLIC_IP:5001
- **Health Check**: http://YOUR_EC2_PUBLIC_IP:5001/health

**Note**: Port 5001 is exposed internally. For production, consider using a reverse proxy or load balancer.

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

### EC2-Specific Issues

**Port 80 already in use:**
```bash
sudo netstat -tulpn | grep :80
sudo systemctl stop httpd  # Stop Apache if running
```

**Docker permission denied:**
```bash
sudo usermod -a -G docker ec2-user
# Logout and login again
exit
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

**Cannot connect to EC2:**
- Check Security Groups allow ports 22, 80
- Verify your IP is allowed for SSH (22)
- Use correct key pair (.pem file)

**Database connection failed:**
- Use MongoDB Atlas (cloud) instead of local MongoDB
- Check connection string format
- Verify network connectivity from EC2

**Build fails on t2.micro:**
- Upgrade to t3.medium or larger instance
- t2.micro has insufficient memory for Docker builds

**Application not accessible:**
```bash
# Check if services are running
docker-compose ps

# Check EC2 security groups
# Ensure HTTP (80) is open to 0.0.0.0/0

# Test from EC2 instance
curl http://localhost
curl http://localhost:5001/health
```

**Build fails:**
```bash
# Clear Docker cache
docker system prune -f

# Check available disk space
df -h

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

## 🚀 AWS EC2 Production Deployment

### Step-by-Step EC2 Setup:

1. **Launch EC2 Instance:**
   ```bash
   # Instance Details:
   # - AMI: Amazon Linux 2
   # - Instance Type: t3.medium (2 vCPU, 4GB RAM)
   # - Storage: 20GB gp3
   # - Security Group: Allow SSH (22), HTTP (80), HTTPS (443)
   ```

2. **Connect and Setup:**
   ```bash
   # SSH into your instance
   ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP

   # Update system
   sudo yum update -y

   # Install Docker
   sudo amazon-linux-extras install docker -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -a -G docker ec2-user

   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose

   # Install Git
   sudo yum install -y git

   # Logout and login again
   exit
   ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
   ```

3. **Deploy Application:**
   ```bash
   # Clone and deploy
   git clone https://github.com/Singhadi27/hrms-spc-deployment.git
   cd hrms-spc-deployment

   # Configure environment
   nano hrms-backend/.env  # Add your production settings

   # Deploy
   ./deploy.sh
   ```

### AWS EC2 Specific Requirements:
- **Instance Type**: t3.medium or larger (t2.micro won't work for Docker builds)
- **Security Groups**:
  - SSH (22) - restrict to your IP only
  - HTTP (80) - 0.0.0.0/0
  - HTTPS (443) - 0.0.0.0/0 (if using SSL)
- **Storage**: 20GB minimum
- **Region**: Choose closest to your users

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

## 🎉 EC2 Deployment Success!

Your HRMS application is now deployed on AWS EC2 with a single command! The system automatically handles code cloning, dependency installation, and service orchestration.

**Your application is live at: http://YOUR_EC2_PUBLIC_IP**

### Next Steps for Production:
1. **Add a Domain**: Use Route 53 to point a domain to your EC2 IP
2. **SSL Certificate**: Use AWS Certificate Manager or Let's Encrypt
3. **Database**: Set up MongoDB Atlas for production data
4. **Backup**: Configure automated backups
5. **Monitoring**: Set up CloudWatch alarms