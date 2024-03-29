from __future__ import annotations
from PyQt5.QtCore import QAbstractListModel, QModelIndex, Qt, pyqtSlot
from datetime import date
import kanaban_entity
import kanban_board
import kanban_board_persistance


class KanbanBoardModel(QAbstractListModel):
    TitleRole = Qt.UserRole + 1
    DescriptionRole = Qt.UserRole + 2
    DeadlineRole = Qt.UserRole + 3
    ColorRole = Qt.UserRole + 4
    IsReadyRole = Qt.UserRole + 5
    CreatedDateRole = Qt.UserRole + 6
    DoneDateRole = Qt.UserRole + 7

    def __init__(self, board_handler, status: int, parent=None):
        super(KanbanBoardModel, self).__init__(parent)
        self.status = status
        self.board_index = 1
        self.board_handler = board_handler
        self.original_data = board_handler.get_kanban_board(self.board_index).board
        self.kanban_board = [x for x in self.original_data if x.status == status]
        self.filterColor = 0
        self.filterState = 0

    def data(self, index, role=Qt.DisplayRole):
         row = index.row()
         if role == KanbanBoardModel.TitleRole:
             return self.kanban_board[row].title
         if role == KanbanBoardModel.DescriptionRole:
             return self.kanban_board[row].description
         if role == KanbanBoardModel.DeadlineRole:
             return self.kanban_board[row].deadline
         if role == KanbanBoardModel.ColorRole:
             return self.kanban_board[row].color
         if role == KanbanBoardModel.IsReadyRole:
             return self.kanban_board[row].isReady
         if role == KanbanBoardModel.CreatedDateRole:
             return self.kanban_board[row].creation_date
         if role == KanbanBoardModel.DoneDateRole:
             return self.kanban_board[row].done_date
    
    def rowCount(self, parent=QModelIndex()):
        return sum(1 for d in self.kanban_board if d.status == self.status)
   
    def roleNames(self):
        return {
            KanbanBoardModel.TitleRole: b'title',
            KanbanBoardModel.DescriptionRole: b'description',
            KanbanBoardModel.DeadlineRole: b'deadline',
            KanbanBoardModel.ColorRole: b'mycolor',
            KanbanBoardModel.IsReadyRole: b'isReady',
            KanbanBoardModel.CreatedDateRole: b'createdDate',
            KanbanBoardModel.DoneDateRole: b'doneDate'
        }
     
    @pyqtSlot(int, bool)
    def setBoardIndex(self, board_index, reloadData):
        self.board_index = board_index
        if reloadData:
            self.board_handler.load(self.board_index)
        self.original_data = self.board_handler.get_kanban_board(self.board_index).board
        self.beginResetModel();
        self.kanban_board.clear();
        self._filter();
        self.endResetModel();

    @pyqtSlot()
    def unFilter(self):
        self.filterColor = 0
        self.filterState = 0
        self.resetModel(False)

    @pyqtSlot(int)
    def filter(self, color):
        self.filterColor = color
        self.filterState = 1
        self.resetModel(False)

    @pyqtSlot(int)
    def outFilter(self, color):
        self.filterColor = color
        self.filterState = 2
        self.resetModel(False)

    @pyqtSlot(result=int)
    def getBoardIndex(self):
        return self.board_index 

    @pyqtSlot(int, result=int)
    def deleteItem(self, original_index: int):
        val = self._remove_item_from_original_data(original_index)
        if val == 0:
            return 0
        self.resetModel()
        return 1 

    @pyqtSlot(str, str, str, int)
    def addData(self, title, description, deadline, color):
        entity = kanaban_entity.KanabanEntity(title,
                                             description,
                                             deadline,
                                             self.status,
                                             color,
                                             False,
                                             date.today().strftime("%d/%m/%Y"),
                                             "") 
        self.original_data.insert(0, entity)
        self.resetModel()
    
    @pyqtSlot(int, str, str, str, int, bool)
    def changeData(self, original_index, title, description, deadline, color, isReady):
        item = self.original_data[original_index]
        containing = [x for x in self.kanban_board if id(x) == id(item)]
        if len(containing) == 0:
            return
             
        item.title = title
        item.description = description
        item.deadline = deadline
        item.color = color
        item.isReady = isReady
        self.resetModel()
    
    @pyqtSlot(int, str, str)
    def changeInternalData(self, original_index, createdDate, doneDate):
        item = self.original_data[original_index]
        containing = [x for x in self.kanban_board if id(x) == id(item)]
        if len(containing) == 0:
            return
             
        item.creation_date = createdDate
        item.done_date = doneDate

    @pyqtSlot(result=int)
    def getStatus(self):
        return self.status

    @pyqtSlot(int, int)
    def setStatus(self, row: int, status: int):
        if self.kanban_board[row].status != status:
            self.kanban_board[row].isReady = False
            # set done date dragged in done    
            if status == 3:
                self.kanban_board[row].done_date = date.today().strftime("%d/%m/%Y")
            else:
                self.kanban_board[row].done_date = ""
        self.kanban_board[row].status = status

    @pyqtSlot()
    def resetModel(self, save=True):
        self.beginResetModel();
        self.kanban_board.clear();
        self._filter();
        self.endResetModel();
        if save:
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
 
    @pyqtSlot()
    def archive(self):
        kanban_board_persistance.archive(self.board_index, self.kanban_board)
        for i in range(len(self.kanban_board)):
            self._remove_item_from_original_data(self.getOriginalIndex(i))
        self.resetModel()

    def swapPositions(self, lst, pos1, pos2):
        item = lst[pos1]
        item.status = self.status
        lst.remove(item)
        if pos1 > pos2:
            lst.insert(pos2, item)
        else:
            lst.insert(pos2, item)

    def _filter(self):
        if self.filterState == 1:
            self.kanban_board = [x for x in self.original_data if x.status == self.status and x.color == self.filterColor]
        elif self.filterState == 2:
            self.kanban_board = [x for x in self.original_data if x.status == self.status and not x.color == self.filterColor]
        else:
            self.kanban_board = [x for x in self.original_data if x.status == self.status] 

    def _remove_item_from_original_data(self, original_index: int):
        item = self.original_data[original_index]
        containing = [x for x in self.kanban_board if id(x) == id(item)]
        if len(containing) == 0:
            return 0
        del self.original_data[original_index]
