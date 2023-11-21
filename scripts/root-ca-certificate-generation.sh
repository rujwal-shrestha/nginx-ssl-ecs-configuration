#!/bin/bash

# Create a directory to store the root ca certificate
mkdir -p root_ca_certificate

# Check if the configuration file exists
if [ ! -f ca_data.txt ]; then
    echo "Configuration file 'ca_data.txt' not found."
    exit 1
fi

# Loop through each line in the configuration file
while IFS=' ' read name email
do
    user_name=$(echo $name)
    user_email=$(echo $email)

    # Generate a private key
    openssl genpkey -algorithm RSA -out root_ca_certificate/${user_name}_key.pem

    # Create a self-signed certificate (valid for 365 days)
    openssl req -x509 -new -key root_ca_certificate/${user_name}_key.pem -out root_ca_certificate/${user_name}_cert.pem -days 365 -subj "/CN=$user_name/emailAddress=$user_email"
done < ca_data.txt
