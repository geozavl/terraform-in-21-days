#! /bin/bash

yum update -y
yum install -y httpd git
echo "That is $(hostname)" > /var/www/html/index.html
systemctl enable --now httpd
