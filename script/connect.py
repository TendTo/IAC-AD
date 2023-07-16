import os
import subprocess
from typing import Callable

from .runner_args import RunnerArgs
from .base_command import BaseCommand
from .inventory import Inventory


class Connect(BaseCommand):
    def __init__(self, args: RunnerArgs) -> None:
        super().__init__(args)
        self.inventory = Inventory(self.args)
        self.inventory.load()

    def run(self):
        if self.args.action in self._action_to_method:
            self._action_to_method[self.args.action]()
        elif self.args.action.isdigit():
            self.vulnbox(int(self.args.action))
        else:
            raise Exception(f"Invalid action: '{self.args.action}'")

    @property
    def _action_to_method(self) -> "dict[str, Callable[[], None]]":
        return {
            "server": self.server,
            "router": self.router,
            "fingerprint": self.fingerprint,
        }

    def fingerprint(self) -> "None":
        os.chdir(self.keys_path)
        output = subprocess.check_output(["ssh-keyscan", self.inventory.router_ip])
        with open(self.ssh_path.joinpath("known_hosts"), "ab") as f:
            f.write(output)
        output = subprocess.check_output(
            [
                "ssh",
                "-i",
                self.args.router_key,
                f"ubuntu@{self.inventory.router_ip}",
                "ssh-keyscan",
                "-t",
                "rsa",
                self.inventory.server_ip,
                *self.inventory.vulnbox_ips,
            ]
        )
        with open(self.ssh_path.joinpath("known_hosts"), "ab") as f:
            f.write(output)

    def router(self) -> "None":
        os.chdir(self.keys_path)
        subprocess.run(
            [
                "ssh",
                "-i",
                self.args.router_key,
                f"ubuntu@{self.inventory.router_ip}",
            ]
        )

    def server(self) -> "None":
        os.chdir(self.keys_path)
        print(self.keys_path)
        subprocess.run(
            [
                "ssh",
                "-i",
                self.args.server_key,
                "-o",
                f"ProxyCommand=ssh -i {self.args.router_key} -W %h:%p ubuntu@{self.inventory.router_ip}",
                f"ubuntu@{self.inventory.server_ip}",
            ]
        )

    def vulnbox(self, vulnbox_idx: "int") -> "None":
        os.chdir(self.keys_path)
        subprocess.run(
            [
                "ssh",
                "-o",
                f"ProxyCommand=ssh -i {self.args.router_key} -W %h:%p ubuntu@{self.inventory.router_ip}",
                "-i",
                self.args.vulnbox_key.format(self.args.action),
                f"ubuntu@{self.inventory.get_vulnbox_ip(vulnbox_idx)}",
            ]
        )
