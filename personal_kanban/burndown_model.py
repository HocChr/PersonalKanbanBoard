import datetime
from datetime import date, timedelta
import sys
import math
from PySide6.QtCharts import (QBarCategoryAxis, QStackedBarSeries, QBarSet, QChart,
                              QChartView, QValueAxis)
from PySide6.QtCore import Qt, QDate, QDateTime, QTime
from PySide6.QtGui import QPainter
from PySide6.QtWidgets import QApplication, QMainWindow, QDialog, QDialogButtonBox, QVBoxLayout, QLabel, QCalendarWidget

import kanban_board_persistance


class CustomDialog(QDialog):
    def __init__(self, start_date, end_date):
        super().__init__()

        self.setWindowTitle("Chart interval")

        QBtn = QDialogButtonBox.Ok

        self.buttonBox = QDialogButtonBox(QBtn)
        self.buttonBox.accepted.connect(self.accept)
        self.buttonBox.rejected.connect(self.reject)

        self.layout = QVBoxLayout()
        from_label = QLabel("From:")
        self.layout.addWidget(from_label)

        self.calendarFrom = QCalendarWidget()
        self.calendarFrom.setSelectedDate(start_date)
        self.calendarFrom.setGeometry(10, 10, 400, 250)
        self.layout.addWidget(self.calendarFrom)

        to_label = QLabel("To:")
        self.layout.addWidget(to_label)

        self.calendarTo = QCalendarWidget()
        self.calendarTo.setSelectedDate(end_date)
        self.calendarTo.setGeometry(10, 300, 400, 250)
        self.layout.addWidget(self.calendarTo)

        self.layout.addWidget(self.buttonBox)
        self.setLayout(self.layout)

    def get_from_date(self):
        return self.calendarFrom.selectedDate()

    def get_to_date(self):
        return self.calendarTo.selectedDate()


class TestChart(QMainWindow):
    def __init__(self):
        super().__init__()
        
        self.setWindowTitle("Burndown chart")
        self.kanban_board = kanban_board_persistance.read_selection_from_file()
        
        self.start = QDate(2023, 4, 1)
        self.end = QDate(2023, 6, 30)
        self._set_intervall()

        self.burndown_rate = 0.0 # tasks burned per day
        self.calc_burndown_rate()

        self.set_0 = QBarSet("Open")
        self.set_0.setColor("DarkRed")
        self.set_1 = QBarSet("Done")
        self.set_1.setColor("Black")
        self.set_2 = QBarSet("Forecast")
        self.set_2.setColor("Grey")
        self.categories = []

        self.add_tasks()

        self.series = QStackedBarSeries()
        self.series.append(self.set_0)
        self.series.append(self.set_1)
        self.series.append(self.set_2)

        self.chart = QChart()
        self.chart.setTheme(QChart.ChartTheme.ChartThemeBrownSand)
        self.chart.addSeries(self.series)
        self.chart.setTitle("Burndown chart, burndown rate in tasks per day: " + str(round(self.burndown_rate, 2)) + ". "
            "Time interval: " + str(self.start.toString("yy/MM/dd")) + " - " + str(self.end.toString("yy/MM/dd")))
        font = self.chart.titleFont()
        font.setPointSizeF(20)
        self.chart.setTitleFont(font)
        self.chart.setAnimationOptions(QChart.SeriesAnimations)

        self.axis_x = QBarCategoryAxis()
        self.axis_x.append(self.categories)
        self.chart.addAxis(self.axis_x, Qt.AlignBottom)
        self.series.attachAxis(self.axis_x)

        self.axis_y = QValueAxis()
        self.axis_y.setRange(0, self._calc_max_tasks())
        self.axis_y.setLabelFormat("%i")
        font = self.axis_y.labelsFont()
        font.setPointSizeF(20)
        self.axis_y.setLabelsFont(font)
        self.chart.addAxis(self.axis_y, Qt.AlignLeft)
        self.series.attachAxis(self.axis_y)

        self.chart.legend().setVisible(True)
        self.chart.legend().setAlignment(Qt.AlignBottom)
        font = self.chart.legend().font()
        font.setPointSizeF(20)
        self.chart.legend().setFont(font)

        self._chart_view = QChartView(self.chart)
        self._chart_view.setRenderHint(QPainter.Antialiasing)

        self.setCentralWidget(self._chart_view)

    def calc_burndown_rate(self):
        start_date = self.start.toPython()

        done_at_beginning = [x for x in self.kanban_board.board if x.done_date != "" and 
            datetime.datetime.strptime(x.done_date, '%d/%m/%Y').date() <= start_date]
        number_done_at_beginning = len(done_at_beginning)

        today = date.today()
        done_at_today = [x for x in self.kanban_board.board if x.done_date != "" and
            datetime.datetime.strptime(x.done_date, '%d/%m/%Y').date() <= today]
        number_done_at_today = len(done_at_today)

        duration = today - start_date
        days = duration.days
        
        burned_tasks = number_done_at_today - number_done_at_beginning
        if days >= 1:
            self.burndown_rate = burned_tasks / days
        
    def add_tasks(self):
        an_hour = QTime(16, 15) # 16 Uhr 15, an arbitrary time
        start_date = self.start.toPython()
        end_date = self.end.toPython()
        today = date.today()
        delta =  timedelta(days=10)

        not_dones = []
        while start_date <= end_date:
        # this is not efficient: every delta you walk over the whole list again
        # instead: you could order the list by date and then walk once over the list
            start_date += delta
            
            created_ones = [x for x in self.kanban_board.board if x.creation_date != "" and
                datetime.datetime.strptime(x.creation_date, '%d/%m/%Y').date() <= start_date]
    
            not_dones = [x for x in created_ones if x.status != 3 or x.done_date != "" and
                                     datetime.datetime.strptime(x.done_date, '%d/%m/%Y').date() > start_date]
            if today >= start_date:
                qtDateTimeTmp = QDateTime(self.start, an_hour)
                self.set_0.append(len(not_dones))
                self.set_1.append(len(created_ones) - len(not_dones))
                self.set_2.append(0)
                self.categories.append(str(start_date))
            else:
                # --- forecast ---
                duration = start_date - (today - delta)
                days = duration.days
                forecast = math.floor(days * self.burndown_rate)
                qtDateTimeTmp = QDateTime(self.start, an_hour)
                self.set_0.append(0)
                self.set_1.append(0)
                self.set_2.append(len(not_dones) - forecast)
                self.categories.append(str(start_date))
    
    def _calc_max_tasks(self):
        l = len(self.kanban_board.board) + 2
        l = l + (4 - l % 4)
        return l 

    def _read_from_file(self):
        with open("burndown_data.txt", 'r') as f:
            substring_from = "From:"
            substring_to = "To:"
            for line in f:
                if substring_from in line:
                    tmp = line.replace(substring_from, "")
                    tmp = tmp.replace("\n", "")
                    self.start = QDate.fromString(tmp, 'yyyy/MM/dd')
                elif substring_to in line:
                    tmp = line.replace(substring_to, "")
                    self.end = QDate.fromString(tmp, 'yyyy/MM/dd')

    def _write_to_file(self):
        with open("burndown_data.txt", 'w') as f:
                f.write("From:" + self.start.toString("yyyy/MM/dd"))
                f.write("\n")
                f.write("To:" + self.end.toString("yyyy/MM/dd"))

    def _set_intervall(self):
        self._read_from_file()
        dialog = CustomDialog(self.start, self.end)
        dialog.show()
        if dialog.exec():
            self.start = dialog.get_from_date()
            self.end = dialog.get_to_date()
            self._write_to_file()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = TestChart()
    window.resize(420, 300)
    window.showMaximized()
    sys.exit(app.exec())
