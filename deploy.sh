#!/bin/bash

# HRMS Deployment Script
# This script clones all required repositories and deploys the application

set -e  # Exit on any error

echo "🚀 Starting HRMS Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker and Docker Compose are installed
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

# Create .env file if it doesn't exist
create_env_file() {
    if [ ! -f "hrms-backend/.env" ]; then
        print_warning "Creating .env file template..."

        cat > hrms-backend/.env << EOL
# HRMS Backend Environment Variables
NODE_ENV=production
PORT=5001

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/hrms

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-change-this-in-production
JWT_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost,http://localhost:80,http://localhost:5173
FRONTEND_URL=http://localhost

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
        print_warning "Especially: MONGODB_URI, JWT_SECRET, and email settings"
    fi
}

# Main deployment function
deploy() {
    print_status "Starting deployment process..."

    # Check dependencies
    check_dependencies

    # Create .env if needed
    create_env_file

    # Clean up any existing containers
    print_status "Cleaning up existing containers..."
    docker-compose down --remove-orphans 2>/dev/null || true

    # Build and start services
    print_status "Building and starting services..."
    print_status "This may take a few minutes to clone repositories and build images..."

    if docker-compose up --build -d; then
        print_status "Deployment successful!"
        print_status "Waiting for services to be ready..."

        # Wait for services to start
        sleep 10

        # Check service status
        if docker-compose ps | grep -q "Up"; then
            print_status "Services are running!"
            docker-compose ps

            # Test the application
            print_status "Testing application health..."
            if curl -s http://localhost > /dev/null 2>&1; then
                print_status "✅ Frontend is accessible at http://localhost"
            else
                print_warning "⚠️  Frontend may still be starting up..."
            fi

            if curl -s http://localhost:5001/health > /dev/null 2>&1; then
                print_status "✅ Backend API is accessible at http://localhost:5001"
            else
                print_warning "⚠️  Backend API may still be starting up..."
            fi

            echo ""
            print_status "🎉 Deployment completed successfully!"
            echo ""
            echo "Application URLs:"
            echo "  Frontend: http://localhost"
            echo "  Backend API: http://localhost:5001"
            echo ""
            echo "To view logs: docker-compose logs -f"
            echo "To stop: docker-compose down"
            echo "To restart: docker-compose restart"

        else
            print_error "Some services failed to start. Check logs with: docker-compose logs"
            exit 1
        fi

    else
        print_error "Deployment failed. Check the logs above for details."
        exit 1
    fi
}

# Update function to pull latest changes
update() {
    print_status "Updating application..."

    # Stop services
    docker-compose down

    # Remove existing repos to force fresh clone
    rm -rf hrms-backend hrms-spc

    # Deploy again
    deploy
}

# Show usage
usage() {
    echo "HRMS Deployment Script"
    echo ""
    echo "Usage:"
    echo "  $0                # Deploy the application"
    echo "  $0 update         # Update to latest version"
    echo "  $0 stop           # Stop all services"
    echo "  $0 logs           # Show service logs"
    echo "  $0 cleanup        # Remove all containers and images"
    echo ""
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "update")
        update
        ;;
    "stop")
        print_status "Stopping services..."
        docker-compose down
        print_status "Services stopped."
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "cleanup")
        print_status "Cleaning up containers and images..."
        docker-compose down --remove-orphans
        docker system prune -f
        print_status "Cleanup completed."
        ;;
    "help"|"-h"|"--help")
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac