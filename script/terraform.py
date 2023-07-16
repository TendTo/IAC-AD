import os
import subprocess
import json
from typing import Callable
from .runner_args import RunnerArgs
from .base_command import BaseCommand
from .inventory import Inventory


class Terraform(BaseCommand):
    def __init__(self, args: RunnerArgs) -> "None":
        super().__init__(args)
        self.terraform_path = self.base_path.joinpath("terraform", self.args.provider)
        if not self.terraform_path.exists():
            raise Exception(f"provider {self.args.provider} not found")

    @property
    def _action_to_method(self) -> "dict[str, Callable[[], None]]":
        return {
            "init": self.init,
            "apply": self.apply,
            "destroy": self.destroy,
            "out": self.out,
        }

    def init(self) -> "None":
        """Move to the folder terraform/provider and run terraform init"""
        os.chdir(self.terraform_path)
        subprocess.run(["terraform", "init"])

    def apply(self) -> "None":
        """Move to the folder terraform/provider and run terraform apply"""
        os.chdir(self.terraform_path)
        command = ["terraform", "apply" if not self.args.dry_run else "plan"]
        if self.args.yes:
            command.append("-auto-approve")
        subprocess.run(command)

    def destroy(self) -> "None":
        """Move to the folder terraform/provider and run terraform destroy"""
        if self.args.dry_run:
            print("Dry run, skipping destroy")
            return
        os.chdir(self.terraform_path)
        command = ["terraform", "destroy"]
        if self.args.yes:
            command.append("-auto-approve")
        subprocess.run(command)

    def __parse_out_ips(self) -> "None":
        inventory = Inventory(self.args)
        inventory.load()

        output = subprocess.check_output(["terraform", "output", "-raw", "public_ip_router"])
        public_router_ip = output.decode().strip()
        inventory.router_host["ansible_host"] = public_router_ip

        output = subprocess.check_output(["terraform", "output", "-raw", "private_ip_router"])
        private_router_ip = output.decode().strip()
        inventory.wireguard["router"]["private_ip"] = private_router_ip

        output = subprocess.check_output(["terraform", "output", "-raw", "private_ip_server"])
        private_server_ip = output.decode().strip()
        inventory.set_server_host(private_server_ip, public_router_ip)

        output = subprocess.check_output(["terraform", "output", "-json", "private_ip_vulnbox"])
        private_vulnbox_ip = json.loads(output)
        for i, ip in enumerate(private_vulnbox_ip, start=1):
            inventory.add_vulnbox_host(i, ip, public_router_ip)

        if self.args.dry_run:
            print(inventory)
            return

        inventory.dump()

    def __parse_out_keys(self) -> "None":
        self.keys_path.mkdir(exist_ok=True)
        output_keys: "dict[str, str]" = {}

        output = subprocess.check_output(["terraform", "output", "-json", "private_key_vulnbox"])
        keys = json.loads(output)
        for i, key in enumerate(keys, start=1):
            key_name = self.args.vulnbox_key.format(i)
            output_keys[key_name] = key

        for output_name, key_name in [
            ("private_key_router", self.args.router_key),
            ("private_key_server", self.args.server_key),
        ]:
            output = subprocess.check_output(["terraform", "output", "-raw", output_name])
            output_keys[key_name] = output.decode()

        if self.args.dry_run:
            print(output_keys)
            return

        for key_name, key in output_keys.items():
            key_path = self.keys_path.joinpath(key_name)
            with open(key_path, "w") as f:
                f.write(key)
            os.chmod(key_path, 0o600)

    def out(self) -> "None":
        os.chdir(self.terraform_path)
        self.__parse_out_ips()
        self.__parse_out_keys()
