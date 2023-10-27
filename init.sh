#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
  echo "Usage: $0 <host> <runner_name> <repo_url> <token>" 
  echo "Example: $0 contabo-gh my-runner \"aabccd021/private-management\" ABCDEF123456789"
  exit 1
fi

set -eu

host="$1"
runner_name="$2"
repo_path="$3"
token="$4"

host_user=$(ssh -G "$host" | awk '/^user / { print $2 }')

if [ -z "$host_user" ]; then
  echo "Could not determine username for $host"
  exit 1
fi

repo_url="https://github.com/$repo_path"
echo "Installing runner $runner_name for $repo_url"

ssh "$host" "
  rm -rf ~/runners/$repo_path 
  mkdir -p ~/runners/$repo_path
  cd ~/runners/$repo_path
  curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz
  echo '29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz' | shasum -a 256 -c
  tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
  ./config.sh --url $repo_url --token $token --name $runner_name --replace --unattended
  ./svc.sh uninstall $host_user
  ./svc.sh install $host_user
  ./svc.sh start $host_user
" 
