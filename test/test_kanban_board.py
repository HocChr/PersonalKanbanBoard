from __future__ import annotations
import unittest
from datetime import datetime

from personal_kanban import kanban_board
from personal_kanban import kanaban_entity 

class TestKanbanBoard(unittest.TestCase):

    def test_append_entity(self):
        # arrange
        board = kanban_board.KanbanBoard()
        lenBefore = len(board.board)
        entity = kanaban_entity.KanabanEntity("", "", "2023,2,3")

        # act
        board.append_entity(entity)

        # assert 
        self.assertEqual(lenBefore, 0)
        self.assertEqual(len(board.board), 1)

    def test_get_entity_by_id(self):
        # arrange
        board = kanban_board.KanbanBoard()
        entity = kanaban_entity.KanabanEntity("", "", "2023,2,3")
        entity2 = kanaban_entity.KanabanEntity("test", "descr.", "2023,2,4")
        board.append_entity(entity)
        board.append_entity(entity2)

        # act
        entity_out = board.get_entity_by_id(1)

        # assert 
        self.assertEqual(entity_out, entity2)
        self.assertNotEqual(entity_out, entity)

    def test_get_entity_by_id_index_out_of_range(self):
        # arrange
        board = kanban_board.KanbanBoard()
        entity = kanaban_entity.KanabanEntity("", "", "2023,2,3")
        entity2 = kanaban_entity.KanabanEntity("test", "descr.", "2023,2,4")
        board.append_entity(entity)
        board.append_entity(entity2)

        # act & assert
        with self.assertRaises(Exception):
            entity_out = board.get_entity_by_id(2)


if __name__ == '__main__':
    unittest.main()
