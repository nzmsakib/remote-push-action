#!/usr/bin/bash

# set to terminate on error
set -e

# argument parsing
while [ $# -gt 0 ]; do
  case "$1" in
    --key=*)
      private_key="${1#*=}"
      ;;
    --key_file=*)
      private_key_file="${1#*=}"
      ;;
    --git=*)
      repo_ssh="${1#*=}"
      ;;
    --b=*)
      branch="${1#*=}"
      ;;
    --dir=*)
      dir=${1#*=}
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

# check if the private key is provided
if [ -z "$private_key" ]; then
    echo "Private key is not provided!"
    exit 1
fi

# check if the private key file is provided, if not set it to id_rsa
if [ -z "$private_key_file" ]; then
    private_key_file="id_rsa"
fi

# check if the repository is provided
if [ -z "$repo_ssh" ]; then
    echo "Repository is not provided!"
    exit 1
fi

# check if the branch is provided, if not set it to main
if [ -z "$branch" ]; then
    branch="main"
fi

# check if the directory is provided
if [ -z "$dir" ]; then
    echo "Directory is not provided!"
    exit 1
fi

# check if the directory exists
if [[ ! -d ~/$dir ]]; then
    echo "Directory does not exist on the remote server!"
    exit 1
fi

# update or create the private key file and set the permissions then add github.com to known hosts
echo "Updating the private key..."
echo "$private_key" > ~/.ssh/$private_key_file
chmod 600 ~/.ssh/$private_key_file
ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts
echo "Done!"

# make a zip backup of the $dir directory
echo "Making a backup of the directory..."
# Generate datetime string
datetime=$(date +%Y%m%d%H%M%S)

# Zip file name with datetime appended
zipfile="$dir-$datetime.zip"

# Create the zip file
zip -r ~/$zipfile ~/$dir
echo "Done!"

# open the directory
cd ~/$dir

# check if git initialized
if [ ! -d .git ]; then
    is_git_initialized=false
else
    is_git_initialized=true
    # get the repository url
    current_repo=$(git remote get-url --push origin)
fi

# if not initialized or the repository is not the same as the provided one
if [ "$is_git_initialized" = false ] || [ "$current_repo" != "$repo_ssh" ]; then
    # Empty the directory but keep the directory itself
    cd ~ && rm -rf ~/$dir
    mkdir ~/$dir
    # clone the repository in the directory
    echo "Cloning the repository..."
    git clone $repo_ssh ~/$dir && cd ~/$dir
    # Checkout the branch
    git checkout $branch
    echo "Clone Done!"
    # otherwise pull the changes
else
    echo "Pulling the changes..."
    git pull origin $branch
    echo "Done!"
fi

# Other scripts to run after the deploy 
# check if the file exists
if [ -e "post-deploy.sh" ]; then
    # Make the file executable
    chmod +x post-deploy.sh

    echo "Running post-deploy script..."
    bash post-deploy.sh

    # Make the file not executable
    chmod -x post-deploy.sh
else
    echo "No post-deploy script found!"
fi

# remove the private key file and known hosts
echo "Removing the private key..."
rm ~/.ssh/$private_key_file
echo "Done!"

# exit
exit 0