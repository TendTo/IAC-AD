import os
import subprocess
from typing import Callable
from .runner_args import RunnerArgs
from .base_command import BaseCommand


class Ansible(BaseCommand):
    def __init__(self, args: RunnerArgs) -> None:
        super().__init__(args)
        self.ansible_command = ["ansible-playbook", "-i", self.args.inventory]
        if self.args.ask_vault_pass:
            self.ansible_command.append("--ask-vault-pass")
        if self.args.vault_password_file:
            self.ansible_command.extend(["--vault-password-file", self.args.vault_password_file])
        if self.args.dry_run:
            self.ansible_command.append("--check")

    @property
    def _action_to_method(self) -> "dict[str, Callable[[], None]]":
        return {
            "playbook": self.playbook,
            "up": self.up,
            "down": self.down,
        }

    def playbook(self) -> "None":
        os.chdir(self.ansible_path)
        subprocess.run(self.ansible_command + ["main.yml"])

    def up(self) -> "None":
        os.chdir(self.ansible_path)
        subprocess.run(self.ansible_command + ["wireguard_up.yml"])

    def down(self) -> "None":
        os.chdir(self.ansible_path)
        subprocess.run(self.ansible_command + ["wireguard_down.yml"])
