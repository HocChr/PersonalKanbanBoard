from __future__ import annotations
import sys

from PyQt5.QtGui import QGuiApplication, QFont, QIcon
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtCore import *

import kanban_board_gui_model 
import kanban_board
import kanaban_entity
import kanban_board_persistance
import json
import os
import subprocess

kanban_persistance = kanban_board_persistance.KanbanBoardHandler()
kanban_persistance.load(1)

# create the models for the columns. todo: make it dynamic for exteranl configuration of user specified columns
kanban_board_gui_model_todo =  kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 0)
kanban_board_gui_model_ready = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 1)
kanban_board_gui_model_doing = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 2)
kanban_board_gui_model_done = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 3)

class Burndown(QObject):
    def __init__(self):
        QObject.__init__(self)

    def _write_selection(self):
        selection = []
        selection.extend(kanban_board_gui_model_todo.kanban_board)
        selection.extend(kanban_board_gui_model_ready.kanban_board)
        selection.extend(kanban_board_gui_model_doing.kanban_board)
        selection.extend(kanban_board_gui_model_done.kanban_board)

        kanban_board_persistance.write_selection_to_file(selection)

    @pyqtSlot()
    def runChart(self):
        self._write_selection()
        dirname = os.path.normpath(os.path.join(os.getcwd(), "burndown/burndown_model.exe"))
        subprocess.call([dirname])

app = QGuiApplication(sys.argv)
font = QFont("Segoe UI Variable")
app.setFont(font)
app.setWindowIcon(QIcon("kanban_icon_small.ico"))
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('kanbanBoardModelTodo', kanban_board_gui_model_todo)
engine.rootContext().setContextProperty('kanbanBoardModelReady', kanban_board_gui_model_ready)
engine.rootContext().setContextProperty('kanbanBoardModelDoing', kanban_board_gui_model_doing)
engine.rootContext().setContextProperty('kanbanBoardModelDone', kanban_board_gui_model_done)
burndown = Burndown()
engine.rootContext().setContextProperty("burndown", burndown)
engine.quit.connect(app.quit)
engine.load('personal_kanban\main.qml')

sys.exit(app.exec())
