#!/bin/bash

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
MONGO_URI="mongodb+srv://abhisonwal051993:HbDFMb71e2JYIQYz@cluster0.u8mv6.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
JWT_SECRET="your-secret-key"
EOF

# Install backend dependencies
sudo npm install --force
pm2 start server.js -i max --name backend
pm2 save

# Install frontend dependencies and build React app
cd ../frontend
sudo npm install --legacy-peer-deps
sudo npm run build

# Move frontend build to serve with Nginx
sudo mv build /var/www/frontend

# Copy Nginx Configure File to sites-available 
sudo cp config/nginx.conf /etc/nginx/sites-available/


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
