#!/bin/bash

# Fail script on errors and undefined variables
set -euo pipefail

# Update package list and install dependencies
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git nginx unzip

# Install Node.js 18 and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify Node.js and npm installation
node -v
npm -v

# Install PM2 for process management
sudo npm install -g pm2
pm2 update

# Clone the MERN stack project from GitHub
cd /home/ubuntu
git clone https://github.com/iiamabhishek/mern-chat-app.git mern-app
cd mern-app

# Create a .env file in the backend directory
cd backend
sudo tee .env > /dev/null <<EOF
PORT=5000
MONGO_URI="mongodb-name"
JWT_SECRET="your-secret-key"
NODE_ENV="production"
EOF

# Install backend dependencies
npm install --force
pm2 start server.js -i max --name backend
pm2 save

# Install frontend dependencies and build React app
cd ../frontend

npm install --legacy-peer-deps
npm run build

# Move frontend build with proper permissions
sudo cp -R build /var/www/frontend
sudo chown -R www-data:www-data /var/www/frontend

# Secure Nginx configuration
sudo cp config/nginx.conf /etc/nginx/sites-available/
sudo sed -i 's/# server_tokens off;/server_tokens off;/g' /etc/nginx/nginx.conf

# Enable the Nginx configuration and restart Nginx
sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/
sudo nginx -t

# Unlink default nginx configuration 
sudo unlink /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Allow traffic on ports 80 and 443
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# Auto-Restart Services on Reboot
pm2 save
pm2 startup
sudo systemctl enable nginx


echo "MERN stack setup is complete!"
