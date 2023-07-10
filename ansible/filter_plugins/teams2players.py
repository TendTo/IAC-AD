#!/usr/bin/python

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import TypedDict, Callable

    class Team(TypedDict):
        name: str
        players: int

    class PlayerConf(TypedDict):
        team_name: str
        conf_file: str
        sk: str
        pk: str
        ip: str


class FilterModule:
    """Teams to players filter plugin for Ansible"""

    def filters(self) -> "dict[str, Callable]":
        return {"teams2players": self.teams2players}

    def teams2players(
        self, teams: "list[Team]", ip_format: "str | None" = None
    ) -> "list[PlayerConf]":
        player_confs: "list[PlayerConf]" = []

        for team_id, team in enumerate(teams, start=1):
            for i in range(1, team["players"] + 1):
                player_confs.append(
                    {
                        "team_name": team["name"],
                        "conf_file": f"{team['name']}-{i}.conf",
                        "sk": "",
                        "pk": "",
                        "ip": f"10.80.{team_id}.{i}"
                        if ip_format is None
                        else ip_format % (team_id, i),
                    }
                )

        return player_confs
