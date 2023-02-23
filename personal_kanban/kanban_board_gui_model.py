from __future__ import annotations
from PyQt5.QtCore import QAbstractListModel, QModelIndex, Qt, pyqtSlot
import kanaban_entity
import kanban_board
import kanban_board_persistance


class KanbanBoardModel(QAbstractListModel):
    TitleRole = Qt.UserRole + 1
    DescriptionRole = Qt.UserRole + 2
    DeadlineRole = Qt.UserRole + 3

    def __init__(self, board_handler, status: int, parent=None):
        super(KanbanBoardModel, self).__init__(parent)
        self.status = status
        self.board_index = 1
        self.board_handler = board_handler
        self.original_data = board_handler.get_kanban_board(self.board_index).board
        self.kanban_board = [x for x in self.original_data if x.status == status]

    def data(self, index, role=Qt.DisplayRole):
         row = index.row()
         if role == KanbanBoardModel.TitleRole:
             return self.kanban_board[row].title
         if role == KanbanBoardModel.DescriptionRole:
             return self.kanban_board[row].description
         if role == KanbanBoardModel.DeadlineRole:
             return self.kanban_board[row].deadline
    
    def rowCount(self, parent=QModelIndex()):
        return sum(1 for d in self.kanban_board if d.status == self.status)
   
    def roleNames(self):
        return {
            KanbanBoardModel.TitleRole: b'title',
            KanbanBoardModel.DescriptionRole: b'description',
            KanbanBoardModel.DeadlineRole: b'deadline'
        }
     
    @pyqtSlot(int, bool)
    def setBoardIndex(self, board_index, reloadData):
        self.board_index = board_index
        if reloadData:
            self.board_handler.load(self.board_index)
        self.original_data = self.board_handler.get_kanban_board(self.board_index).board
        self.beginResetModel();
        self.kanban_board.clear();
        self.kanban_board = [x for x in self.original_data if x.status == self.status]
        self.endResetModel();

    @pyqtSlot(result=int)
    def getBoardIndex(self):
        return self.board_index 

    @pyqtSlot(int, result=int)
    def deleteItem(self, original_index: int):
        item = self.original_data[original_index]
        containing = [x for x in self.kanban_board if id(x) == id(item)]
        if len(containing) == 0:
            return 0
        del self.original_data[original_index]
        self.resetModel()
        return 1 

    @pyqtSlot(str, str, str)
    def addData(self, title, description, deadline):
        entity = kanaban_entity.KanabanEntity(title, description, deadline, self.status) 
        self.original_data.insert(0, entity)
        self.resetModel()
    
    @pyqtSlot(int, str, str, str)
    def changeData(self, original_index, title, description, deadline):
        item = self.original_data[original_index]
        containing = [x for x in self.kanban_board if id(x) == id(item)]
        if len(containing) == 0:
            return
             
        item.title = title
        item.description = description
        item.deadline = deadline
        self.resetModel()

    @pyqtSlot(result=int)
    def getStatus(self):
        return self.status

    @pyqtSlot(int, int)
    def setStatus(self, row: int, status: int):
        self.kanban_board[row].status = status

    @pyqtSlot()
    def resetModel(self):
        self.beginResetModel();
        self.kanban_board.clear();
        self.kanban_board = [x for x in self.original_data if x.status == self.status]
        self.endResetModel();
        self.board_handler.save(self.board_index)

    @pyqtSlot(int, result=int)
    def getOriginalIndex(self, row: int):
        item = self.kanban_board[row]
        index = -1
        for i in range(0, len(self.original_data)):
            if id(self.original_data[i]) == id(item):
                index = i
        return index
    
    @pyqtSlot(int, int, int, int)
    def addByDrop(self, original_source: int, original_target: int, local_source: int, local_target: int):
        item = self.original_data[original_source] 

        # adapt positions in original data
        self.swapPositions(self.original_data, original_source, original_target)
        if original_source == original_target:
            return False
        elif local_source > local_target:
            end = local_target
        else:
            end = local_target + 1

        self.resetModel()

    @pyqtSlot(int, int, int, int)
    def removeByDrop(self, original_source: int, original_target: int, local_source: int, local_target: int):
        self.beginRemoveRows(QModelIndex(), local_source, local_source)
        self.endRemoveRows()
 
    def swapPositions(self, lst, pos1, pos2):
        item = lst[pos1]
        item.status = self.status
        lst.remove(item)
        if pos1 > pos2:
            lst.insert(pos2, item)
        else:
            lst.insert(pos2, item)

