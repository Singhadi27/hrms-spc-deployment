#!/bin/bash

# Simple HRMS Deployment Script (without buildx dependency)
set -e

echo "🚀 Starting Simple HRMS Deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're running as root and warn
if [ "$EUID" -eq 0 ]; then
    print_warning "Running as root. Consider using a regular user with sudo."
fi

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    print_status "Dependencies check passed!"
}

fic# Setup repositories (assume they're included in deployment)
setup_repos() {
    print_status "Setting up repositories..."

    # Check if repositories exist in deployment directory
    if [ -d "hrms-backend" ] && [ -d "hrms-spc" ]; then
        print_status "Repositories found in deployment directory!"
        print_status "Using included repositories (no GitHub cloning needed)"
        return 0
    fi

    # If not found, try to copy from parent directory (development setup)
    print_warning "Repositories not found in deployment directory, checking parent..."

    if [ -d "../hrms-backend" ]; then
        print_status "Copying backend from parent directory..."
        cp -r ../hrms-backend . 2>/dev/null || print_warning "Some files may not have copied (normal for dev setup)"
    else
        print_error "Backend repository not found"
        print_error "Please ensure hrms-backend is in the deployment directory or parent directory"
        exit 1
    fi

    if [ -d "../hrms-spc" ]; then
        print_status "Copying frontend from parent directory..."
        cp -r ../hrms-spc . 2>/dev/null || print_warning "Some files may not have copied (normal for dev setup)"
    else
        print_error "Frontend repository not found"
        print_error "Please ensure hrms-spc is in the deployment directory or parent directory"
        exit 1
    fi

    print_status "Repositories setup complete!"
}

# Create .env file if it doesn't exist
create_env_file() {
    if [ ! -f "hrms-backend/.env" ]; then
        print_warning "Creating .env file template..."

        cat > hrms-backend/.env << 'EOL'
# HRMS Backend Environment Variables
NODE_ENV=production
PORT=5001

# Database Configuration - UPDATE WITH YOUR MONGODB ATLAS URI
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/hrms

# JWT Configuration - CHANGE THIS SECRET IN PRODUCTION
JWT_SECRET=your-super-secure-jwt-secret-change-this-32-chars-minimum
JWT_EXPIRES_IN=7d

# CORS Configuration - UPDATE WITH YOUR EC2 PUBLIC IP
CORS_ORIGIN=http://YOUR_EC2_PUBLIC_IP,http://YOUR_EC2_PUBLIC_IP:80
FRONTEND_URL=http://YOUR_EC2_PUBLIC_IP

# Email Configuration (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_SECURE=false
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Other settings
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760
EOL

        print_warning "Please edit hrms-backend/.env with your actual configuration values!"
        print_warning "Required: MONGODB_URI, JWT_SECRET, CORS_ORIGIN with your EC2 IP"
        print_warning "Press Enter to continue after editing..."
        read -p ""
    fi
}

# Main deployment
deploy() {
    print_status "Starting simple deployment..."

    check_dependencies
    setup_repos
    create_env_file

    # Clean up any existing containers
    print_status "Cleaning up existing containers..."
    docker-compose down --remove-orphans 2>/dev/null || true

    # Build and start services
    print_status "Building and starting services..."
    print_status "This may take 5-10 minutes to build images..."

    # Use docker-compose without buildx
    export DOCKER_BUILDKIT=0

    if docker-compose up --build -d; then
        print_status "Deployment successful!"
        print_status "Waiting for services to be ready..."

        # Wait for services to start
        sleep 15

        # Check service status
        if docker-compose ps | grep -q "Up"; then
            print_status "Services are running!"
            docker-compose ps

            # Get EC2 public IP
            EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_EC2_PUBLIC_IP")

            echo ""
            print_status "🎉 Deployment completed successfully on EC2!"
            echo ""
            echo "Application URLs:"
            echo "  Frontend: http://$EC2_IP"
            echo "  Backend API: http://$EC2_IP:5001"
            echo ""
            echo "Management commands:"
            echo "  View logs: docker-compose logs -f"
            echo "  Stop: docker-compose down"
            echo "  Restart: docker-compose restart"

        else
            print_error "Some services failed to start. Check logs with: docker-compose logs"
            exit 1
        fi

    else
        print_error "Deployment failed. Check the logs above for details."
        print_error "Try running: docker-compose logs"
        exit 1
    fi
}

# Run deployment
deploy