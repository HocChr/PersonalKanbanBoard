from __future__ import annotations
import sys

from PyQt5.QtGui import QGuiApplication, QFont, QIcon
from PyQt5.QtQml import QQmlApplicationEngine

import kanban_board_gui_model 
import kanban_board
import kanaban_entity
import kanban_board_persistance
import json
import os

kanban_persistance = kanban_board_persistance.KanbanBoardHandler()
kanban_persistance.load(1)

# create the models for the columns. todo: make it dynamic for exteranl configuration of user specified columns
kanban_board_gui_model_todo =  kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 0)
kanban_board_gui_model_ready = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 1)
kanban_board_gui_model_doing = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 2)
kanban_board_gui_model_done = kanban_board_gui_model.KanbanBoardModel(kanban_persistance, 3)


app = QGuiApplication(sys.argv)
font = QFont("Segoe UI Variable")
app.setFont(font)
app.setWindowIcon(QIcon("kanban_icon_small.ico"))
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('kanbanBoardModelTodo', kanban_board_gui_model_todo)
engine.rootContext().setContextProperty('kanbanBoardModelReady', kanban_board_gui_model_ready)
engine.rootContext().setContextProperty('kanbanBoardModelDoing', kanban_board_gui_model_doing)
engine.rootContext().setContextProperty('kanbanBoardModelDone', kanban_board_gui_model_done)
engine.quit.connect(app.quit)
engine.load('personal_kanban\main.qml')

sys.exit(app.exec())
