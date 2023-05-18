from __future__ import annotations
from datetime import datetime


# Todo chho: the state should be an enum class, not an integer

class KanabanEntity:
    """The Entity of a Kanaban Board"""
    def __init__(self, title: str,
                 description: str,
                 deadline: str,
                 status: int,
                 color: int,
                 isReady: bool,
                 creation_date: datetime,
                 done_date: datetime) -> None:
        self.title = title
        self.description = description
        self.deadline = deadline
        self.status = status
        self.color = color
        self.isReady = isReady
        self.creation_date = creation_date
        self.done_date = done_date
