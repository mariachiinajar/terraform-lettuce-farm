#!/bin/bash

# Set variables
export HOSTNAME=$(hostname)
export PUBLIC_IPV4=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
export LOCAL_IPV4=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_TYPE=$(curl http://169.254.169.254/latest/meta-data/instance-type)
export ACCESS_CATEGORY="public"

if [ -z "$PUBLIC_IPV4" ]
then 
    ACCESS_CATEGORY="private"
    # echo This instance is $ACCESS_CATEGORY
else
    ACCESS_CATEGORY="public"
fi

# Install and run Apache server
yum update -y 
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Inject data to the index page.
echo "<h1>Hello. You are accessing a <span style='color: red; font-weight: bold;'>$ACCESS_CATEGORY</span> instance:<br></h1>" >> /var/www/html/index.html

echo "<h3>Instance Profile</h3>" >> /var/www/html/index.html
echo "Hostname:      $HOSTNAME<br>" >> /var/www/html/index.html
echo "Instance ID:   $INSTANCE_ID<br>" >> /var/www/html/index.html
echo "Instance type: $INSTANCE_TYPE<br><br>" >> /var/www/html/index.html

echo "Public IP:  <span style='color: red'>$PUBLIC_IPV4</span><br>" >> /var/www/html/index.html
echo "Private IP: <span style='color: red'>$LOCAL_IPV4</span>" >> /var/www/html/index.html

