#!/bin/bash
# Automated Web Server Setup Script
# Installs Apache (on Debian/Ubuntu) and sets up a simple web page

echo "🌐 Starting Web Server Setup..."

# Update system
sudo apt update -y

# Install Apache
sudo apt install apache2 -y

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Create a simple HTML page
echo "<h1>Welcome to Praveen's Cloud Project 🚀</h1>" | sudo tee 
/var/www/html/index.html

# Restart Apache
sudo systemctl restart apache2

echo "✅ Web server setup completed!"
echo "👉 Visit http://localhost or your server's IP in a browser."
