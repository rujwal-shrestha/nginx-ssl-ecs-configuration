#!/bin/sh

# Define the path to your default.conf file
default_conf_file="/etc/nginx/conf.d/default.conf"

# Define the line to add to the default.conf file
include_line="include /etc/nginx/efs-mount/server/*.conf;"

# Create the default.conf file and add the line
echo "$include_line" | tee "$default_conf_file"
echo "Added the line to $default_conf_file"

# Start NGINX
nginx -g "daemon off;" &

# Define the path to the directory to monitor
watch_dir="/etc/nginx/efs-mount/server/"

# Function to reload NGINX configuration
reload_nginx() {
    echo "NGINX configuration files changed. Reloading NGINX..."
    nginx -s reload
}

# Run the inotifywait command in the background and execute reload_nginx on changes
inotifywait -e modify,create,delete -m -r "$watch_dir" | while read path action file; do
    reload_nginx
done
