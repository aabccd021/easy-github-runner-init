#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ||  [ -z "$5" ]; then
  echo "Usage: $0 <root_host> <user_host> <runner_name> <repo_url> <token>" 
  echo "Example: $0 contabo contabo-gh contabo \"https://github.com/aabccd021/private-management\" ABCDEF123456789"
  exit 1
fi

set -eu

root_host="$1"
user_host="$2"
runner_name="$3"
repo_url="$4"
token="$5"

user_host_name=$(ssh -G "$user_host" | awk '/^user / { print $2 }')

if [ -z "$user_host_name" ]; then
  echo "Could not determine username for $user_host"
  exit 1
fi

repo_dirname=$(echo "$repo_url" | sed -e 's/https:\/\/github.com\///g')

ssh "$user_host" "
  rm -rf ~/runners/$repo_dirname 
  mkdir -p ~/runners/$repo_dirname
  cd ~/runners/$repo_dirname
  curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
  echo '29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz' | shasum -a 256 -c
  tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
  ./config.sh --url $repo_url --token $token --name $runner_name --replace --unattended
"

ssh "$root_host" "
  cd /home/$user_host_name/runners/$repo_dirname
  echo "installing service"
  ./svc.sh install
  echo "starting service"
  ./svc.sh start
  echo "service started"
" 

echo "Done! Runner $runner_name for $repo_url is now running on $user_host"

