from .runner_args import RunnerArgs
from .terraform import Terraform
from .ansible import Ansible
from .connect import Connect


class All:
    def __init__(self, args: RunnerArgs) -> None:
        self.terraform = Terraform(args)
        self.connect = Connect(args)
        self.ansible = Ansible(args)

    def run(self):
        self.terraform.apply()
        self.connect.fingerprint()
        self.ansible.playbook()
