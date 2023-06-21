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

# check if the directory is provided
if [ -z "$dir" ]; then
    echo "Directory is not provided!"
    exit 1
fi

# check if the directory exists
if [[ ! -d ~/$dir ]]; then
    echo "Directory does not exist!"
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
# get basename of the directory
dirname=$(basename "$dir")

# Generate datetime string
datetime=$(date +%Y%m%d%H%M%S)

# Zip file name with datetime appended
zipfile="~/backup/$dirname-$datetime.zip"

# Create the zip file
zip -r "$zipfile" ~/$dir
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
    # Empty the directory
    cd ~ && rm -rf ~/$dir
    # clone the repository in the directory
    echo "Cloning the repository..."
    git clone $repo_ssh ~/$dir && cd ~/$dir
    # other scripts to run after clone
    # post-clone.sh is a script that is run after the clone which is in the repository
    if [ -e "post-clone.sh" ]; then
        # Make the file executable
        chmod +x post-clone.sh

        echo "Running post-clone script..."
        bash post-clone.sh

        # Make the file not executable
        chmod -x post-clone.sh
    else
        echo "No post-clone script found!"
    fi
    # finally done
    echo "Done!"
    # otherwise pull the changes
else
    echo "Pulling the changes..."
    git pull
    # other scripts to run after pull
    # post-pull.sh is a script that is run after the pull which is in the repository
    # check if the file exists
    if [ -e "post-pull.sh" ]; then
        # Make the file executable
        chmod +x post-pull.sh

        echo "Running post-pull script..."
        bash post-pull.sh

        # Make the file not executable
        chmod -x post-pull.sh
    else
        echo "No post-pull script found!"
    fi
    echo "Done!"
fi

# remove the private key file and known hosts
echo "Removing the private key..."
rm ~/.ssh/$private_key_file ~/.ssh/known_hosts
echo "Done!"

# exit
exit 0