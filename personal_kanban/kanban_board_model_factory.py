
import kanban_board
import kanban_board_gui_model

class KanbanBoardModelFactory:
    def __init__(self, kanban_board):
        self.kanban_board = kanban_board

    def getTodoModel(self):
        data = [x for x in self.kanban_board if x.status == 0]
        return kanban_board_gui_model.KanbanBoardModel(data)

    def getReadyModel(self):
        data = [x for x in self.kanban_board if x.status == 1]
        return kanban_board_gui_model.KanbanBoardModel(data)

    def getDoingModel(self):
        data = [x for x in self.kanban_board if x.status == 2]
        return kanban_board_gui_model.KanbanBoardModel(data)
    
    def getDoneModel(self):
        data = [x for x in self.kanban_board if x.status == 3]
        return kanban_board_gui_model.KanbanBoardModel(data)
        
