#!/usr/bin/env python3
import random
import string
from typing import TYPE_CHECKING
import requests
import bs4
import names
from checklib import BaseChecker, Status

if TYPE_CHECKING:
    from typing import NoReturn

SERVICE_NAME = "Notes"

class Checker(BaseChecker):
    def create_note(self, title: str, content: str, private: bool) -> "int | NoReturn":
        note_data = {}
        note_data["title"] = title
        note_data["content"] = content
        if private:
            note_data["private"] = ""

        resp = requests.post(f"http://{self.team_ip}:8080/new", data=note_data)
        if resp.status_code != 200:
            self.quit(Status.DOWN, f"Bad create note status code: {resp.status_code}")

        parts = resp.url.split("/view/")
        if len(parts) != 2:
            self.quit(Status.DOWN, "Invalid create note redirect")

        try:
            return int(parts[1])
        except ValueError:
            self.quit(Status.DOWN, "Invalid create note id")

    def view_note(self, note_id: int) -> "tuple[str, str] | NoReturn":
        resp = requests.get(f"http://{self.team_ip}:8080/view/{note_id}")
        if resp.status_code != 200:
            self.quit(Status.DOWN, f"Bad view note status code: {resp.status_code}")

        html = bs4.BeautifulSoup(resp.text, features="html.parser")
        title_elem = html.select_one("div.container > h1")
        content_elem = html.select_one("div.container > p")
        if not title_elem or not content_elem:
            self.quit(Status.DOWN, "Invalid view note page")

        return title_elem.text.strip(), content_elem.text.strip()

    def check(self) -> "None | NoReturn":
        resp = requests.get(f"http://{self.team_ip}:8080")
        if resp.status_code != 200:
            self.quit(Status.DOWN, f"Bad index page status code: {resp.status_code}")

        note_title = names.get_random_name()
        note_content = "".join(
            random.choices(string.ascii_letters + string.digits, k=64)
        )
        note_id = self.create_note(note_title, note_content, False)

        view_note_title, view_note_content = self.view_note(note_id)
        if view_note_title != note_title or view_note_content != note_content:
            self.quit(Status.DOWN, "Invalid note title or content")

    def put(self) -> "NoReturn":
        note_title = names.get_random_name()
        note_id = self.create_note(note_title, self.flag, True)
        self.quit(Status.OK, str(note_id))

    def get(self) -> "None | NoReturn":
        _, note_content = self.view_note(int(self.flag_id))
        if note_content != self.flag:
            self.quit(Status.DOWN, "No flag in note content")


def main():
    checker = Checker()
    checker.run()


if __name__ == "__main__":
    main()
