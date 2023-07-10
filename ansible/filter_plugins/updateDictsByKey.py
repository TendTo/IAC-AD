#!/usr/bin/python

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Callable


class FilterModule:
    """Update a list of dictionaries filter plugin for Ansible"""

    def filters(self) -> "dict[str, Callable]":
        return {"updateDictsByKey": self.updateDictsByKey}

    def updateDictsByKey(
        self,
        dicts: "list[dict]",
        primary_dict: "dict",
        update_dict: "dict",
    ) -> "list[dict]":
        updated_dicts: "list[dict]" = []

        for d in dicts:
            updated_d = d.copy()
            for key, value in updated_d.items():
                # If for all keys in the primary dict, the value is the same as the value in the updated dict
                if all(
                    [
                        primary_dict[key] == updated_d.get(key, None)
                        for key in primary_dict
                    ]
                ):
                    updated_d.update(update_dict)
            updated_dicts.append(updated_d)

        return updated_dicts
