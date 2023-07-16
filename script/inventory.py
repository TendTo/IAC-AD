from typing import TYPE_CHECKING
from pathlib import Path
import yaml

if TYPE_CHECKING:
    from typing import Literal
    from .types import InventoryDict, All, VulnboxHosts, Host, Wireguard
    from .runner_args import RunnerArgs

INVENTORY = {
    "all": {
        "hosts": {
            "router": {
                "ansible_host": "0.0.0.0",
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "./keys/router.pem",
            },
            "server": {
                "ansible_host": "0.0.0.0",
                "ansible_user": "ubuntu",
                "ansible_ssh_private_key_file": "./keys/server.pem",
                "ansible_ssh_common_args": '-o ProxyCommand="ssh -i ./keys/router.pem -W %h:%p ubuntu@0.0.0.0"',
            },
        },
        "children": {"vulnbox": {"hosts": {}}},
        "vars": {
            "wireguard": {
                "network": "10.0.0.0/8",
                "router": {
                    "private_ip": "0.0.0.0",
                    "port": 51820,
                    "ip": "10.0.0.1",
                    "subnet": "10.0.0.1/32",
                    "out_interface": "eth0",
                    "start": {"year": 2023, "month": 7, "day": 15, "hour": 12, "minute": 10},
                    "open": {"year": 2023, "month": 7, "day": 15, "hour": 12, "minute": 15},
                },
                "vulnbox": {"port": 51820, "ip_format": "10.60.%d.1", "subnet": "10.60.0.0/16", "team_mask_offset": 8},
                "player": {"ip_format": "10.80.%d.%d", "subnet": "10.80.0.0/16", "team_mask_offset": 8},
                "server": {"port": 51820, "ip": "10.10.0.1", "subnet": "10.10.0.0/16"},
            },
            "teams": [{"name": "catania", "players": 1}, {"name": "palermo", "players": 2}],
            "ad": {
                "timezone": "Europe/Rome",
                "round_time": 60,
                "default_score": 2500,
                "flag_lifetime": 5,
                "vulnbox": {"services_owner": "root", "services_path": "/root/services/"},
            },
        },
    }
}


class Inventory:
    SSH_COMMON_ARGS = '-o ProxyCommand="ssh -i ./keys/{key} -W %h:%p  ubuntu@{ip}"'

    def __init__(self, args: "RunnerArgs") -> "None":
        self.args = args
        self.inventory_path = Path(__file__).parent.parent.joinpath("ansible", args.inventory)
        self.__inventory: "InventoryDict" = INVENTORY  # type: ignore

    def load(self) -> "None":
        if Path(self.inventory_path).exists():
            with open(self.inventory_path, "r", encoding="utf-8") as f:
                inventory: "InventoryDict" = yaml.load(f, Loader=yaml.SafeLoader)
                self.__inventory.update(inventory)

    def dump(self) -> "None":
        with open(self.inventory_path, "w", encoding="utf-8") as f:
            yaml.dump(self.__inventory, f, default_flow_style=False)

    def set_server_host(self, server_ip: "str", router_ip: "str") -> "None":
        server = self.__inventory["all"]["hosts"]["server"]
        server["ansible_host"] = server_ip
        server["ansible_ssh_common_args"] = self.SSH_COMMON_ARGS.format(key=self.args.router_key, ip=router_ip)
        server["ansible_ssh_private_key_file"] = f"./keys/{self.args.server_key}"

    def add_vulnbox_host(self, vulnbox_index: "int", vulnbox_ip: "str", router_ip: "str") -> "None":
        vulnbox_id = f"vulnbox{vulnbox_index}"
        vulnbox_key = self.args.vulnbox_key.format(vulnbox_index)
        vulnbox: "Host" = {}  # type: ignore

        vulnbox["ansible_host"] = vulnbox_ip
        vulnbox["ansible_ssh_common_args"] = self.SSH_COMMON_ARGS.format(key=self.args.router_key, ip=router_ip)
        vulnbox["ansible_ssh_private_key_file"] = f"./keys/{vulnbox_key}"
        vulnbox["ansible_user"] = "ubuntu"

        self.__inventory["all"]["children"]["vulnbox"]["hosts"][vulnbox_id] = vulnbox

    @property
    def inventory(self) -> "All":
        return self.__inventory["all"]

    @property
    def vulnbox_hosts(self) -> "VulnboxHosts":
        return self.__inventory["all"]["children"]["vulnbox"]["hosts"]

    @property
    def router_host(self) -> "Host":
        return self.__inventory["all"]["hosts"]["router"]

    @property
    def server_host(self) -> "Host":
        return self.__inventory["all"]["hosts"]["server"]

    @property
    def wireguard(self) -> "Wireguard":
        return self.__inventory["all"]["vars"]["wireguard"]

    @property
    def router_ip(self) -> "str":
        return self.router_host["ansible_host"]

    @property
    def server_ip(self) -> "str":
        return self.server_host["ansible_host"]

    @property
    def vulnbox_ips(self) -> "list[str]":
        return [host["ansible_host"] for host in self.vulnbox_hosts.values()] # type: ignore

    def get_vulnbox_ip(self, vulnbox_index: "int") -> "str":
        return self.vulnbox_hosts[f"vulnbox{vulnbox_index}"]["ansible_host"]

    def get_host(self, host: "Literal['router', 'server']") -> "Host":
        return self.__inventory["all"]["hosts"][host]

    def __str__(self) -> "str":
        return yaml.dump(self.__inventory, sort_keys=False)
