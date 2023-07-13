#!/usr/bin/env python3
import sys
from checklib import BaseChecker, Status
import random
import string
import os
import json
import re
from pwnlib.tubes.remote import remote

os.environ["PWNLIB_NOTERM"] = "1"

PORT = 5000
SERVICE_NAME = "Polls"


def get_random_string(
    n: "int", alph: "str" = string.ascii_letters + string.digits
) -> "str":
    return "".join([random.choice(alph) for _ in range(n)])


class Checker(BaseChecker):
    def check(self):
        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        user = get_random_string(random.randint(10, 16))
        password = get_random_string(random.randint(10, 16))
        description = get_random_string(random.randint(10, 20))
        n_options = random.randint(3, 7)
        options = [get_random_string(random.randint(5, 10)) for _ in range(n_options)]
        try:
            r.recvuntil(b": ")
            r.sendline(b"register")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"User registered correctly!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot register", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"create poll")
            r.recvuntil(b": ")
            r.sendline(description.encode())
            r.recvuntil(b": ")
            r.sendline(str(n_options).encode())
            for i in range(n_options):
                r.recvuntil(b": ")
                r.sendline(options[i].encode())
            resp = r.recvline()
            poll_id = resp.split()[-1].decode()
            assert b"Poll created!" in resp
        except Exception as e:
            self.quit(Status.DOWN, "Cannot create poll", str(e))

        r.close()

        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"login")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"Successfully logged in!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot login", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"access poll")
            resp = r.recvuntil(b": ")
            poll_id = re.findall(b"[0-9a-f]{16}", resp)[0]
            r.sendline(b"show")
            r.recvuntil(b": ")
            r.sendline(poll_id)
            assert description.encode() in r.recvuntil(b": ").replace(
                b" ", b""
            ).replace(b"\n", b"")
        except Exception as e:
            self.quit(Status.DOWN, "Cannot access poll", str(e))

        r.close()

        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"login")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"Successfully logged in!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot login", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"access poll")
            resp = r.recvuntil(b": ")
            poll_id = re.findall(b"[0-9a-f]{16}", resp)[0]
            r.sendline(b"share")
            r.recvuntil(b": ")
            r.sendline(poll_id)
            token = r.recvline().split()[-1].decode()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot share poll", str(e))

        r.close()

        user = get_random_string(random.randint(10, 16))
        password = get_random_string(random.randint(10, 16))

        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"register")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"User registered correctly!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot register", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"use token")
            resp = r.recvuntil(b": ")
            r.sendline(token.encode())
            assert b"OK" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot use sharing token", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"access poll")
            resp = r.recvuntil(b": ")
            poll_id = re.findall(b"[0-9a-f]{16}", resp)[0]
            r.sendline(b"show")
            r.recvuntil(b": ")
            r.sendline(poll_id)
            assert description.encode() in r.recvuntil(b": ").replace(
                b" ", b""
            ).replace(b"\n", b"")
        except Exception as e:
            self.quit(Status.DOWN, "Cannot access poll", str(e))

    def put(self):
        random.seed(self.flag)

        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        user = get_random_string(random.randint(10, 16))
        password = get_random_string(random.randint(10, 16))
        n_options = random.randint(3, 7)
        options = [get_random_string(random.randint(5, 10)) for _ in range(n_options)]
        try:
            r.recvuntil(b": ")
            r.sendline(b"register")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"User registered correctly!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot register", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"create poll")
            r.recvuntil(b": ")
            r.sendline(self.flag.encode())
            r.recvuntil(b": ")
            r.sendline(str(n_options).encode())
            for i in range(n_options):
                r.recvuntil(b": ")
                r.sendline(options[i].encode())
            resp = r.recvline()
            poll_id = resp.split()[-1].decode()
            assert b"Poll created!" in resp
        except Exception as e:
            self.quit(Status.DOWN, "Cannot create poll", str(e))

        return json.dumps({"poll_id": poll_id, "username": user})

    def get(self):
        random.seed(self.flag)

        try:
            r = remote(self.team_ip, PORT)
        except Exception as e:
            self.quit(Status.DOWN, "Cannot connect", str(e))

        user = get_random_string(random.randint(10, 16))
        password = get_random_string(random.randint(10, 16))

        try:
            r.recvuntil(b": ")
            r.sendline(b"login")
            r.recvuntil(b": ")
            r.sendline(user.encode())
            r.recvuntil(b": ")
            r.sendline(password.encode())
            assert b"Successfully logged in!" in r.recvline()
        except Exception as e:
            self.quit(Status.DOWN, "Cannot login", str(e))

        try:
            r.recvuntil(b": ")
            r.sendline(b"access poll")
            resp = r.recvuntil(b": ")
            poll_id = re.findall(b"[0-9a-f]{16}", resp)[0]
            r.sendline(b"show")
            r.recvuntil(b": ")
            r.sendline(poll_id)
            assert self.flag.encode() in r.recvuntil(b": ").replace(b" ", b"").replace(
                b"\n", b""
            )
        except Exception as e:
            self.quit(Status.DOWN, "Cannot access poll", str(e))


def main():
    checker = Checker()
    checker.run()


if __name__ == "__main__":
    main()
