from abc import ABC, abstractmethod
from pathlib import Path
from typing import Callable
from .runner_args import RunnerArgs


class BaseCommand(ABC):
    def __init__(self, args: RunnerArgs):
        self.args = args
        self.base_path = Path(__file__).parent.parent
        self.ansible_path = self.base_path.joinpath("ansible")
        self.keys_path = self.ansible_path.joinpath("keys")
        self.inventory_path = self.ansible_path.joinpath(self.args.inventory)
        self.ssh_path = Path.home().joinpath(".ssh")
        
    @property
    @abstractmethod
    def _action_to_method(self) -> "dict[str, Callable[[], None]]":
        raise NotImplementedError()

    def run(self):
        action_mapping = self._action_to_method
        if self.args.action not in action_mapping:
            raise Exception(f"Invalid action: '{self.args.action}'")
        action_mapping[self.args.action]()
