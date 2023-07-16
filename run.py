#!/usr/bin/env python3
from script import All, RunnerArgs, Terraform, Ansible, Connect, CommandEnum


class Runner:
    COMMAND_DICTS: "dict[str, type[All] | type[Terraform] | type[Connect] | type[Ansible]]" = {
        CommandEnum.ALL.value: All,
        CommandEnum.TERRAFORM.value: Terraform,
        CommandEnum.CONNECT.value: Connect,
        CommandEnum.ANSIBLE.value: Ansible,
    }

    def __init__(self):
        self.args = RunnerArgs()

    def run(self) -> "None":
        if self.args.command in self.COMMAND_DICTS:
            command = self.COMMAND_DICTS[self.args.command](self.args)
            command.run()


if __name__ == "__main__":
    Runner().run()
