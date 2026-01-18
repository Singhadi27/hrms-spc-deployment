#!/bin/bash

# Script to add repositories to deployment directory
set -e

echo "Adding repositories to deployment directory..."

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: Please run this script from the hrms-spc-deployment directory"
    exit 1
fi

# Check if parent directory has the repositories
if [ ! -d "../hrms-backend" ] || [ ! -d "../hrms-spc" ]; then
    echo "Error: hrms-backend and hrms-spc not found in parent directory"
    echo "Please ensure you're running this from hrms/hrms-spc-deployment/"
    exit 1
fi

echo "Copying hrms-backend..."
cp -r ../hrms-backend ./
echo "Copying hrms-spc..."
cp -r ../hrms-spc ./

echo "Removing unnecessary files (node_modules, .git, etc.)..."
rm -rf hrms-backend/node_modules 2>/dev/null || true
rm -rf hrms-backend/.git 2>/dev/null || true
rm -rf hrms-backend/.env* 2>/dev/null || true
rm -rf hrms-spc/node_modules 2>/dev/null || true
rm -rf hrms-spc/.git 2>/dev/null || true
rm -rf hrms-spc/.env* 2>/dev/null || true

echo "✅ Repositories added successfully!"
echo ""
echo "Next steps:"
echo "1. Commit these changes: git add . && git commit -m 'Add application repositories'"
echo "2. Push to GitHub: git push origin main"
echo "3. Deploy on EC2: clone repo and run ./deploy-simple.sh"