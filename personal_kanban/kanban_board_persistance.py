from __future__ import annotations

from collections import namedtuple
from pathlib import Path
import kanaban_entity
import kanban_board
import json
import os

file_names = {
    0: "undefined",
    1: "strategic.json",
    2: "coordination.json",
    3: "operational.json",
    4: "aai.json"
}

def customDataDecoder(dataDict):
        return namedtuple('X', dataDict.keys())(*dataDict.values())

def customDataDecoder(dataDict):
    return namedtuple('X', dataDict.keys())(*dataDict.values())

def _iterator_to_entity(it):
    return kanaban_entity.KanabanEntity(it.title,
                                        it.description,
                                        it.deadline,
                                        it.status,
                                        it.color,
                                        it.isReady,
                                        it.creation_date,
                                        it.done_date)


def write_selection_to_file(selection: []):
    with open('tmp.json', 'w', encoding ='utf8') as json_file:
        json.dump([obj.__dict__ for obj in selection], json_file)

def read_selection_from_file():
    board = kanban_board.KanbanBoard()
    with open('tmp.json', 'r') as f:
        data = json.load(f, object_hook=customDataDecoder)
        for it in data:
            entity = _iterator_to_entity(it)
            board.append_entity(entity)
    return board

def archive(board_index: int, selection: []):
    board = kanban_board.KanbanBoard()
    file_name = "archive_" + file_names[board_index]
    my_file = Path(file_name)
    if my_file.is_file():
        with open(file_name, 'r') as f:
            data = json.load(f, object_hook=customDataDecoder)
            for it in data:
                entity = _iterator_to_entity(it)
                board.append_entity(entity)

    board.board = selection + board.board
    with open(file_name, 'w', encoding ='utf8') as json_file:
        json.dump([obj.__dict__ for obj in board.board], json_file)

class KanbanBoardHandler:
    def __init__(self):
        self.index_to_file_paths = file_names 
        self._kanban_board = kanban_board.KanbanBoard()
       
    def load(self, board_index: int):
       self._kanban_board.board.clear()
       my_file = Path(self.index_to_file_paths[board_index])
       if my_file.is_file():
          if os.stat(self.index_to_file_paths[board_index]).st_size == 0:
              return
          with open(self.index_to_file_paths[board_index], 'r') as f:
              data = json.load(f, object_hook=customDataDecoder)
              for it in data:
                  entity = _iterator_to_entity(it)
                  self._kanban_board.append_entity(entity)

    def get_kanban_board(self, board_index: int, reload = False):
        if reload:
            self.load(board_index)
        return self._kanban_board
    
    def save(self, board_index):
        with open(self.index_to_file_paths[board_index], 'w', encoding ='utf8') as json_file:
           json.dump([obj.__dict__ for obj in self._kanban_board.board], json_file)

