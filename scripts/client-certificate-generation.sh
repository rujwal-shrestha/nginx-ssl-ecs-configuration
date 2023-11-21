#!/bin/bash

# Create a directory to store the client certificates
mkdir -p client_certificates

# Check if the configuration file exists
if [ ! -f user_data.txt ]; then
    echo "Configuration file 'user_data.txt' not found."
    exit 1
fi

# Loop through each line in the configuration file
while IFS=' ' read name email
do
    user_name=$(echo $name | xargs)
    user_email=$(echo $email | xargs)

    # Generate a private key
    openssl genpkey -algorithm RSA -out client_certificates/${user_name}_key.pem

    # Create a CSR with the email address attribute
    openssl req -new -key client_certificates/${user_name}_key.pem -out client_certificates/${user_name}_csr.pem -subj "/CN=$user_name/emailAddress=$user_email"

    # Create a self-signed certificate (valid for 365 days)
    openssl x509 -req -in client_certificates/${user_name}_csr.pem -signkey $ROOT_CA_PEM_FILE -out client_certificates/${user_name}_cert.pem -days 365
done < user_data.txt
