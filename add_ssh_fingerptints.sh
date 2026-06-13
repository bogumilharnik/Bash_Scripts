#!/bin/bash

# Path to the file containing the list of IP addresses or hostnames
HOSTS_FILE="_ssh_hosts"

# Check if the file exists
if [[ ! -f $HOSTS_FILE ]]; then
    echo "Hosts file not found!"
    exit 1
fi

# Read the file line by line
while IFS= read -r HOST; do
    # Skip empty lines or lines starting with #
    if [[ -z "$HOST" || "$HOST" =~ ^# ]]; then
        continue
    fi
    
    echo "Adding SSH fingerprint for $HOST"
    ssh-keyscan -H $HOST >> ~/.ssh/known_hosts
done < "$HOSTS_FILE"

echo "All fingerprints added."
