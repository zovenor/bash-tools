Install scripts:

- Terminate all screens by name:
```shell
sudo curl -fsSL https://raw.githubusercontent.com/zovenor/bash-tools/main/terminate-all-screens.sh -o /usr/local/bin/terminate-all-screens
sudo chmod +x /usr/local/bin/terminate-all-screens
source ~/.bashrc
```

- Get child pid by parent pid and child comm:
```shell
sudo curl -fsSL https://raw.githubusercontent.com/zovenor/bash-tools/main/child-pid.sh -o /usr/local/bin/child-pid
sudo chmod +x /usr/local/bin/child-pid
source ~/.bashrc
```

- Get screen pid:
```shell
sudo curl -fsSL https://raw.githubusercontent.com/zovenor/bash-tools/main/screen-pid.sh -o /usr/local/bin/screen-pid
sudo chmod +x /usr/local/bin/screen-pid
source ~/.bashrc
```
