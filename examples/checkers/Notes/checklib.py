from abc import ABC, abstractmethod
import sys
import requests
import os
import argparse
from enum import Enum

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import NoReturn

    class CheckerArgs(argparse.Namespace):
        action: str
        teamIp: str
        flagId: str
        flag: str
        vuln_number: int


class Status(Enum):
    OK = 101
    CORRUPT = 102
    MUMBLE = 103
    DOWN = 104
    ERROR = 110


class Action(Enum):
    CHECK = "check"
    PUT = "put"
    GET = "get"

    def __str__(self):
        return str(self.value)


class ArgumentParser(argparse.ArgumentParser):
    """Simple extension of the ArgumentParser class to change the exit core in case of error"""

    def error(self, message):
        """Method called when an error occurs in the parsing of the arguments

        Args:
            message: the error message
        """
        self.print_help(sys.stderr)
        self.exit(Status.ERROR.value, "%s: error: %s\n" % (self.prog, message))


class BaseChecker(ABC):
    def __init__(self, args: "dict | None" = None):
        try:
            self.args = self.parse_args(args)
            self.action = self.args.action
            self.team_ip = self.args.teamIp
            if self.action != Action.CHECK.value:
                self.flag_id = self.args.flagId
                self.flag = self.args.flag
                self.vuln_number = self.args.vuln_number
        except Exception as e:
            self.quit(Status.ERROR, "Invalid checker args", str(e))

    def run(self):
        try:
            if self.action == Action.CHECK.value:
                self.check()
            elif self.action == Action.PUT.value:
                self.put()
            elif self.action == Action.GET.value:
                self.get()
            else:
                self.quit(Status.ERROR, "Unknown action")
        except requests.RequestException as e:
            self.quit(Status.ERROR, "Unhandled checker error", str(e))
        self.quit(Status.OK)

    def parse_args(self, args: "dict | None" = None) -> "CheckerArgs":
        parser = ArgumentParser()
        subparsers = parser.add_subparsers(help="action to perform", dest="action")

        check_parser = subparsers.add_parser(
            Action.CHECK.value, help="check whether the service is up"
        )
        check_parser.add_argument("teamIp", type=str, help="ip address of the team")

        put_parser = subparsers.add_parser(
            Action.PUT.value, help="put the provided flag in the service"
        )
        put_parser.add_argument("teamIp", type=str, help="ip address of the team")
        put_parser.add_argument("flagId", type=str, help="flag id")
        put_parser.add_argument("flag", type=str, help="flag")
        put_parser.add_argument(
            "vuln_number", type=int, help="identifier for the vulnerability"
        )

        get_parser = subparsers.add_parser(
            Action.GET.value, help="get the provided flag from the service"
        )
        get_parser.add_argument("teamIp", type=str, help="ip address of the team")
        get_parser.add_argument("flagId", ype=str, help="flag id")
        get_parser.add_argument("flag", type=str, help="flag")
        get_parser.add_argument(
            "vuln_number", type=int, help="identifier for the vulnerability"
        )

        return parser.parse_args(args)  # type: ignore

    @abstractmethod
    def check(self) -> "None | NoReturn":
        pass

    @abstractmethod
    def put(self) -> "None | NoReturn":
        pass

    @abstractmethod
    def get(self) -> "None | NoReturn":
        pass

    def quit(
        self, exit_code: "int | Status", comment: str = "", debug: str = ""
    ) -> "NoReturn":
        if isinstance(exit_code, Status):
            exit_code = exit_code.value

        print(comment)
        print(debug, file=sys.stderr)
        exit(exit_code)
