# easy-github-runner-init
Install github-runner as service on remote server.

## Requirements
- You have configured public key login as root user
- You have configured public key login as non-root user

# Example
In the following example, user have a server on IP 192.168.1.1,
configured `root` user login ssh host as `contabo-root`, and
configured non-root user login ssh host as `contabo-gh`.

```ssh_config
Host contabo-root
  HostName 192.168.1.1
  User root
  IdentityFile ~/.ssh/contabo
Host contabo-gh
  HostName 192.168.1.1
  User gh
  IdentityFile ~/.ssh/contabo-gh
```
The user is able to run `ssh contabo-root "echo ok"` and  `ssh contabo-gh "echo ok"`

Then the user can install github-runner and runs it as service by running following command:

```sh
curl -sSf "https://raw.githubusercontent.com/aabccd021/easy-github-runner-init/main/init.sh" \
    | sh -s contabo-root contabo-gh my-runner "https://github.com/username/repo" ABCDEF123456789
```

Where
- `contabo-root` is the root login host
- `contabo-gh` is the non-root login host
- `my-runner` is the runner name
- `"https://github.com/username/repo"` is the repo url
- `ABCDEF123456789` is the token you can get from `https://github.com/user/repo/settings/actions/runners/new`
