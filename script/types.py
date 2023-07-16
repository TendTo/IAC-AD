from typing import Optional, TypedDict


class Host(TypedDict):
    ansible_host: str
    ansible_user: str
    ansible_ssh_private_key_file: str
    ansible_ssh_common_args: Optional[str]


class VulnboxHosts(TypedDict):
    vulnbox1: Host
    vulnbox2: Host


class ChildrenVulnbox(TypedDict):
    hosts: VulnboxHosts


class Children(TypedDict):
    vulnbox: ChildrenVulnbox


class AllHosts(TypedDict):
    router: Host
    server: Host


class AdVulnbox(TypedDict):
    services_owner: str
    services_path: str


class Ad(TypedDict):
    timezone: str
    round_time: int
    default_score: int
    flag_lifetime: int
    vulnbox: AdVulnbox


class Team(TypedDict):
    name: str
    players: int


class Player(TypedDict):
    ip_format: str
    subnet: str
    team_mask_offset: int
    port: Optional[int]


class Open(TypedDict):
    year: int
    month: int
    day: int
    hour: int
    minute: int


class WireguardRouter(TypedDict):
    private_ip: str
    port: int
    ip: str
    subnet: str
    start: Open
    open: Open


class Server(TypedDict):
    port: int
    ip: str
    subnet: str


class Wireguard(TypedDict):
    network: str
    router: WireguardRouter
    vulnbox: Player
    player: Player
    server: Server


class Vars(TypedDict):
    ansible_ssh_timeout: int
    wireguard: Wireguard
    teams: list[Team]
    ad: Ad


class All(TypedDict):
    hosts: AllHosts
    children: Children
    vars: Vars


class InventoryDict(TypedDict):
    all: All
