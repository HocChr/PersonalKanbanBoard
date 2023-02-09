from __future__ import annotations
from kanaban_entity import KanabanEntity


class KanbanBoard:
    """The Board itself"""
    def __init__(self) -> None:
        self.board = []

    def append_entity(self, entity: kanaban_entity.KanabanEntity) -> int:
        self.board.append(entity)

    def get_entity_by_id(self, id: int) -> KanbanEntity:
       return self.board[id] 

