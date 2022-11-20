#!/bin/bash

# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update
# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':

sudo apt-get -y install postgresql

sudo apt-get install sshpass

## INSTALL and ENABLE CITUS
curl https://install.citusdata.com/community/deb.sh > add-citus-repo.sh

sudo bash add-citus-repo.sh

# install the server and initialize db

sudo apt-get -y install postgresql-15-citus-11.1

# preload citus extension
sudo pg_conftool 15 main set shared_preload_libraries citus

sudo systemctl restart postgresql

sudo pg_conftool 15 main set listen_addresses '*'

# start the db server
sudo service postgresql restart

# and make it start automatically when computer does
sudo update-rc.d postgresql enable


# add the citus extension
sudo -i -u postgres psql -c "CREATE EXTENSION citus;"

sudo mkdir -p /logs/archive
sudo chown postgres:postgres -R /logs/

echo "postgres connection"

echo 'postgres:postgres' | sudo chpasswd

# Change sshd config so that it allows password authentication
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Change sshd config so it challenges for password
sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
# Restart sshd
sudo systemctl restart sshd


# Get the fingerprint of the key from postgres
ssh-keyscan -H postgres@localhost >> ~/.ssh/known_hosts
# Generate ssh key
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
# Copy the key to postgress 
sshpass -p 'postgres' ssh-copy-id postgres@localhost







