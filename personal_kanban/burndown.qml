import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtCharts 2.1

Window {
    id: window1
    title: "Chart test"
    visible: true
    width: 600
    height: 400

    ChartView {
        id: chart
        anchors.fill: parent
        axes: [
            ValueAxis{
                id: xAxis
                min: 1.0
                max: 10.0
            },
            ValueAxis{
                id: yAxis
                min: 0.0
                max: 10.0
            }
        ]
        Component.onCompleted: {
            var seriesCount = Math.round(Math.random()* 10);
            for(var i = 0;i < seriesCount;i ++)
            {
                var series = chart.createSeries(ChartView.SeriesTypeLine, "line"+ i, xAxis, yAxis);
                series.pointsVisible = true;
                series.color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                series.hovered.connect(function(point, state){ console.log(point); }); // connect onHovered signal to a function
                var pointsCount = Math.round(Math.random()* 20);
                var x = 0.0;
                for(var j = 0;j < pointsCount;j ++)
                {
                    x += (Math.random() * 2.0);
                    var y = (Math.random() * 10.0);
                    series.append(x, y);
                }
            }
        }
    }
}
