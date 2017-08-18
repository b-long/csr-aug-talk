#!/usr/bin/env bash

# Enter the security credentials for "my-ansible-user" below
ACCESS_KEY_ID=""
SECRET_ACCESS_KEY=""

# =====================================
# Do not edit anything below this line 
# =====================================

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "$PS1" ] ; then
    echo -e "This script must be sourced. Use \"source configure.sh\" instead."
    exit
fi

touch ~/.profile
source ~/.profile

# Determine if setup was already performed
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  # Override the AWS credentials if they exist
  mkdir -p ~/.aws
  echo "[default]" > ~/.aws/credentials  
  echo "aws_access_key_id = $ACCESS_KEY_ID" >> ~/.aws/credentials
  echo "aws_secret_access_key = $SECRET_ACCESS_KEY" >> ~/.aws/credentials
  
  echo "export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID" >> ~/.profile
  echo "export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY" >> ~/.profile
fi

source ~/.profile

echo "Installing Ansible roles"

pushd ansible-code

ansible-galaxy install -r requirements.yml

popd

echo "Finished installing Ansible roles"

printf "\nAwesome!  The Ansible control machine is now configured. \n"
