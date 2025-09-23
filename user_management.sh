#!/bin/bash
# User Management Script

echo "Choose an option:"
echo "1. Create a new user"
echo "2. Delete a user"
echo "3. List all users"
read choice

case $choice in
  1)
    read -p "Enter username: " username
    sudo useradd $username
    echo "User $username created."
    ;;
  2)
    read -p "Enter username: " username
    sudo userdel $username
    echo "User $username deleted."
    ;;
  3)
    cut -d: -f1 /etc/passwd
    ;;
  *)
    echo "Invalid option"
    ;;
esac
