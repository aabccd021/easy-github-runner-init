#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ||  [ -z "$5" ]; then
  echo "Usage: $0 <root_host> <user_host> <runner_name> <repo_url> <token>" 
  echo "Example: $0 contabo contabo-gh contabo \"aabccd021/private-management\" ABCDEF123456789"
  exit 1
fi

set -eu

root_host="$1"
user_host="$2"
runner_name="$3"
repo_path="$4"
token="$5"

user_host_username=$(ssh -G "$user_host" | awk '/^user / { print $2 }')

if [ -z "$user_host_username" ]; then
  echo "Could not determine username for $user_host"
  exit 1
fi

repo_url="https://github.com/$repo_path"
echo "Installing runner $runner_name for $repo_url"

ssh "$user_host" "
  rm -rf ~/runners/$repo_path 
  mkdir -p ~/runners/$repo_path
  cd ~/runners/$repo_path
  curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
  echo '29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz' | shasum -a 256 -c
  tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
  ./config.sh --url $repo_url --token $token --name $runner_name --replace --unattended
" \
&& ssh "$root_host" "
  cd /home/$user_host_username/runners/$repo_path
  ./svc.sh uninstall
  ./svc.sh install "$user_host_username" #https://github.com/actions/runner/issues/1864#issuecomment-1124660990
  ./svc.sh start
" \
&& echo "Successfully installed runner $runner_name for $repo_url" \
&& echo "Check the runner status on $repo_url/settings/actions/runners"
