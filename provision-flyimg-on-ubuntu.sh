#!/bin/bash
#
# Commented provisioning script for a flyimg server
# Created for Ubuntu 16 but works with 14 and possibly with other distributions
# This script is intended to be used as a root user
# This script should be ideally invoqued by a Cloud-init script 
# 	Read more at: https://www.digitalocean.com/community/tutorials/an-introduction-to-cloud-config-scripting#run-arbitrary-commands-for-more-control
# 	
# Original Gist at: https://gist.github.com/baamenabar/2a825178318d27fc20abfe5a413b45eb
# Author B. Agustin Amenabar L. @iminabar
# 

# The user must be the same set by the Cloud-init script
nixusr="ubuntu"

#sudo apt install docker.io git apt-utils -y
#sudo usermod -aG docker ubuntu

# We clone the flyimg repo into the user's folder.
echo "cloning flyimg into " $(pwd)
#sudo -HEu $nixusr git clone https://github.com/flyimg/flyimg.git /home/$nixusr/serverboy
sudo -HEu $nixusr git clone --depth 1 --branch 1.1.15 https://github.com/flyimg/flyimg.git /home/$nixusr/serverboy

# List the repo's content to comfirm it's there.
cd serverboy
echo "...cloned! content is:"
ls -la

# Build the docker container
echo "sudo -u $nixusr docker build -t flyimg ."
sudo -u $nixusr docker build -t flyimg/flyimg-build:1.1.5 .
#sudo -u $nixusr docker build -t flyimg .
sleep 5

# Run the container, naming it "flyimg" and exposing it through port 80
echo "sudo -u $nixusr docker run -t -d -i -p 80:80 -v /home/$nixusr/flyimg:/var/www/html --name serverboy flyimg"
sudo -u $nixusr docker run -t -d -i -p 80:80 -v /home/$nixusr/serverboy:/var/www/html --name serverboy flyimg
sleep 5

# Update the container to restart always in case of stopping for any reason.
# Even after the server has restarted
echo "sudo -u $nixusr docker update --restart=always serverboy"
sudo -u $nixusr docker update --restart=always serverboy

# list the container(s)
echo "sudo -u $nixusr docker ps"
sudo -u $nixusr docker ps
sleep 10

# Run composer inside the container image to download all the dependencies the application needs.
echo "sudo -HEu $nixusr docker exec -i flyimg composer install"
sudo -HEu $nixusr docker exec -i serverboy composer install
sleep 5

sudo -u $nixusr mkdir /home/$nixusr/serverboy/web/uploads
sudo -u $nixusr mkdir /home/$nixusr/serverboy/var
sudo -u $nixusr mkdir /home/$nixusr/serverboy/var/tmp
sleep 5

sudo chown -R ubuntu:www-data /home/$nixusr/serverboy/web/uploads
sudo chown -R ubuntu:www-data /home/$nixusr/serverboy/var
sleep 5

sudo -u $nixusr rm /home/$nixusr/serverboy/src/Core/Views/Default/index.html
sudo -u $nixusr touch /home/$nixusr/serverboy/src/Core/Views/Default/index.html

echo $'\n Horray! Provisioning finished \n Happy Imaging.'
