import argparse
from enum import Enum

from typing import TYPE_CHECKING

if TYPE_CHECKING:

    class RunnerArgsNamespace(argparse.Namespace):
        command: str
        action: str
        provider: str
        inventory: str
        router_key: str
        server_key: str
        vulnbox_key: str
        yes: bool
        vault_password_file: str
        ask_vault_pass: bool
        dry_run: bool


class CommandEnum(Enum):
    ALL = "all"
    TERRAFORM = "terraform"
    CONNECT = "connect"
    ANSIBLE = "ansible"


class RunnerArgs:
    def __init__(self, args: "dict | None" = None):
        self.parser = argparse.ArgumentParser()
        self.subparsers = self.parser.add_subparsers(required=True, help="command to perform", dest="command")
        self.__general_options()
        self.__all_subcommand()
        self.__terraform_subcommand()
        self.__connect_subcommand()
        self.__ansible_subcommand()
        self.args: RunnerArgsNamespace = self.parser.parse_args(args)  # type: ignore

    def __general_options(self) -> "None":
        self.parser.add_argument(
            "-y",
            "--yes",
            action="store_true",
            help="automatically answer yes to any questions. Use with caution!",
        )
        self.parser.add_argument(
            "-i",
            "--inventory",
            type=str,
            default="inventory.yml",
            help="inventory file where to store the terraform outputs or where to get the information from",
        )
        self.parser.add_argument(
            "--router_key",
            type=str,
            default="router.pem",
            help="name of the private key to use to connect to the router instance",
        )
        self.parser.add_argument(
            "--server_key",
            type=str,
            default="server.pem",
            help="name of the private key to use to connect to the server instance",
        )
        self.parser.add_argument(
            "--vulnbox_key",
            type=str,
            default="vulnbox{}.pem",
            help="format of the name of the private key to use to connect to the vulnbox instance",
        )

    def __all_subcommand(self) -> "None":
        all_parser = self.subparsers.add_parser(
            CommandEnum.ALL.value, help="perform all the actions in the correct order"
        )
        all_parser.add_argument(
            "-p",
            "--provider",
            type=str,
            required=True,
            help="provider to use",
            choices=["aws", "azure", "openstack"],
        )
        all_parser.add_argument(
            "--ask-vault-pass",
            action="store_true",
            help="ansible will ask for a password to decrypt the vault with",
        )
        all_parser.add_argument(
            "--vault-password-file",
            type=str,
            help="ansible will use the provided file to decrypt the vault with",
        )
        all_parser.add_argument(
            "--dry-run",
            action="store_true",
            help="ansible will not perform any action, but will show what it would do",
        )

    def __terraform_subcommand(self) -> "None":
        terraform_parser = self.subparsers.add_parser(
            CommandEnum.TERRAFORM.value, help="check whether the service is up"
        )
        terraform_parser.add_argument(
            "action",
            type=str,
            help="action to perform on the terraform files",
            choices=["init", "apply", "destroy", "out"],
        )
        terraform_parser.add_argument(
            "-p",
            "--provider",
            type=str,
            required=True,
            help="provider to use.",
            choices=["aws", "azure", "openstack"],
        )
        terraform_parser.add_argument(
            "--dry-run",
            action="store_true",
            help="terraform will not perform any action, but will show what it would do",
        )

    def __connect_subcommand(self) -> "None":
        def validate_action(action: str) -> str:
            if action in ["router", "server", "fingerprint"] or action.isdigit():
                return action
            raise argparse.ArgumentTypeError("value must be either 'router', 'server', 'fingerprint' or a number")

        connect_parser = self.subparsers.add_parser(CommandEnum.CONNECT.value, help="connect to the service")
        connect_parser.add_argument(
            "action",
            type=validate_action,
            help="action regarding the connection with the remote instances. Must be either 'router', 'server', 'fingerprint' or the index of the vulnbox to connect to",
        )

    def __ansible_subcommand(self) -> "None":
        ansible_parser = self.subparsers.add_parser(
            CommandEnum.ANSIBLE.value, help="perform actions on the remote instances"
        )
        ansible_parser.add_argument(
            "action",
            type=str,
            help="action to perform on the remote instances",
            choices=["playbook", "up", "down"],
        )
        ansible_parser.add_argument(
            "--ask-vault-pass",
            action="store_true",
            help="ansible will ask for a password to decrypt the vault with",
        )
        ansible_parser.add_argument(
            "--vault-password-file",
            type=str,
            help="ansible will use the provided file to decrypt the vault with",
        )
        ansible_parser.add_argument(
            "--dry-run",
            action="store_true",
            help="ansible will not perform any action, but will show what it would do",
        )

    @property
    def command(self) -> "str":
        return self.args.command

    @property
    def action(self) -> "str":
        return self.args.action

    @property
    def provider(self) -> "str":
        return self.args.provider

    @property
    def inventory(self) -> "str":
        return self.args.inventory

    @property
    def router_key(self) -> "str":
        return self.args.router_key

    @property
    def server_key(self) -> "str":
        return self.args.server_key

    @property
    def vulnbox_key(self) -> str:
        return self.args.vulnbox_key

    @property
    def yes(self) -> "bool":
        return self.args.yes

    @property
    def vault_password_file(self) -> "str":
        return self.args.vault_password_file

    @property
    def ask_vault_pass(self) -> "bool":
        return self.args.ask_vault_pass

    @property
    def dry_run(self) -> "bool":
        return self.args.dry_run
