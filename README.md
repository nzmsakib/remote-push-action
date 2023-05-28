# remote-push-action
This repository contains documentation on how to sync a git repository to a remote host directory with ssh.
# 4 secrets are needed.
1. SSH_HOST = `IP_ADDRESS_OF_THE_HOST`
2. SSH_USER = `SSH_USERNAME`
3. SSH_PRIVATE_KEY = `SSH_PRIVATE_KEY_ASSOCIATED_WITH_SSH_USER`
4. REMOTE_DIR = ~/`DIRECTORY_WHERE_THE_CODE_SHOULD_BE_PLACED_ON_THE_SERVER`
add these secrets to your repository and you are good to go. Here is the link to the action:
`https://github.com/<username>/<repo>/settings/secrets/actions`

Then add the following to your workflow file:
`action.yml`: # Path: .github/workflows/main.yml

Then copy the `gitsync.sh` file to your user directory on the remote host. Make sure to make it executable by running `chmod +x gitsync.sh` on the remote host.

Now you are good to go. Whenever you push to your repository, the code will be synced to the remote host.

Additionally if you want to run scripts after every clone and pull, you can do so in the two files `post-clone.sh` and `post-pull.sh` respectively. These files should be placed in repository root directory. Make sure to make them executable by running `chmod +x post-clone.sh` and `chmod +x post-pull.sh` on the remote host (if needed).