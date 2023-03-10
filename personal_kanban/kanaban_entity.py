from __future__ import annotations
from datetime import datetime

class KanabanEntity:
    """The Entity of a Kanaban Board"""
    def __init__(self, title: str, description: str, deadline: str, status: int) -> None:
        self.title = title
        self.description = description
        self.deadline = deadline
        self.status = status
