# Extra

## Autocomplete

The _run.py_ script supports autocomplete for Bash.
The autocomplete script is in the _util_ folder.
To enable it, copy it to _/etc/bash_completion.d/_.

```shell
# Copy the autocomplete script
sudo cp util/autocomplete.sh /etc/bash_completion.d/terraform-ansible
```

```shell
# You may need to source the autocomplete script
echo "source /etc/bash_completion.d/terraform-ansible" >> ~/.bashrc
```

## Connect with wireguard

After running the ansible main playbook, all the configuration files for wireguard will be in the _ansible/teams_ folder.
It is possible to use those to connect to the VPN.

```shell
# Copy the configuration file to the wireguard folder
sudo cp ansible/teams/<team_name>-<i>.conf /etc/wireguard/wg0.conf
# Connect to the VPN
sudo wg-quick up wg0
```
