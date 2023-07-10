#!/usr/bin/python

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Callable


class FilterModule:
    """Update a list of dictionaries filter plugin for Ansible"""

    def filters(self) -> "dict[str, Callable]":
        return {"updateDictsByIdx": self.updateDictsByIdx}

    def updateDictsByIdx(
        self,
        dicts: "list[dict]",
        idx: "int",
        update_dict: "dict",
    ) -> "list[dict]":
        updated_dicts: "list[dict]" = []

        for i, d in enumerate(dicts):
            updated_d = d.copy()
            if i == idx:
                updated_d.update(update_dict)
            updated_dicts.append(updated_d)

        return updated_dicts
