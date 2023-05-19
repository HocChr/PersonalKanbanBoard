import random
from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtCharts import QtCharts
import datetime
from datetime import date, timedelta

import kanban_board_persistance

class MainWindow(QtWidgets.QMainWindow):
    def __init__(self, board_index: int):
        super(MainWindow, self).__init__()
        
        self.board_index = board_index
        self.kanban_persistance = kanban_board_persistance.KanbanBoardHandler()
        self.kanban_board = self.kanban_persistance.get_kanban_board(1, True) 

        self.start = QtCore.QDate(2023, 4, 1)
        self.end = QtCore.QDate(2023, 6, 30)
        self.min = 0
        self.max = len(self.kanban_board.board) 

        self.plot = QtCharts.QChart()
        # self.add_series("Magnitude (Column 1)", [0, 1])
        self.chart_view = QtCharts.QChartView(self.plot)
        self.setCentralWidget(self.chart_view)

        self.series = QtCharts.QLineSeries()
        self.series.setName("Ideal Chart")
        self.plot.addSeries(self.series)

        self.seriesNoDones = QtCharts.QLineSeries()
        self.seriesNoDones.setName("Burndown Chart")
        self.plot.addSeries(self.seriesNoDones)

        # Setting X-axis
        self.axis_x = QtCharts.QDateTimeAxis()
        #self.axis_x.setTickCount(10)
        self.axis_x.setLabelsAngle(70)
        self.axis_x.setFormat("dd/MM/yyyy")
        self.axis_x.setTitleText("Date")
        self.axis_x.setMin(self.start)
        self.axis_x.setMax(self.end)

        # Setting Y-axis
        self.axis_y = QtCharts.QValueAxis()
        self.axis_y.setTickCount(1)
        self.axis_y.setLabelFormat("%i")
        self.axis_y.setTitleText("Number Tasks")
        self.axis_y.setMax(self.max)
        self.axis_y.setMin(self.min)

        self.plot.setAxisX(self.axis_x, self.series)
        self.plot.setAxisY(self.axis_y, self.series)

        self.plot.setAxisX(self.axis_x, self.seriesNoDones)
        self.plot.setAxisY(self.axis_y, self.seriesNoDones)

        self.add_base_line()
        self.add_tasks()

    # Add points to the chart
    def add_base_line(self):
        dt = QtCore.QDateTime.currentDateTime()
        t0 = QtCore.QDateTime(self.start)
        t1 = QtCore.QDateTime(self.end)
        self.series.append(float(t0.toMSecsSinceEpoch()), len(self.kanban_board.board))
        self.series.append(float(t1.toMSecsSinceEpoch()), 0)

    def add_tasks(self):
        start_date = self.start.toPython()
        end_date = self.end.toPython()
        today = date.today()
        delta =  timedelta(days=1)

        not_dones = []
        while start_date <= end_date:
        # this is not efficient: every delta you walk over the whole list again
        # instead: you could order the list by date and then walk once over the list
            start_date += delta

            created_ones = []
            created_ones = [x for x in self.kanban_board.board if 
                datetime.datetime.strptime(x.creation_date, '%d/%m/%Y').date() <= start_date]

            not_dones = []
            not_dones = [x for x in created_ones if x.status != 3 or
                                     datetime.datetime.strptime(x.done_date, '%d/%m/%Y').date() > start_date]
            qtDateTimeTmp = QtCore.QDateTime(start_date)
            self.seriesNoDones.append(float(qtDateTimeTmp.toMSecsSinceEpoch()), len(not_dones))


if __name__ == "__main__":
    import sys
    print("Hello")
    app = QtWidgets.QApplication(sys.argv)
    window = MainWindow(1)
    window.resize(640, 480)
    window.show()
    sys.exit(app.exec_())
