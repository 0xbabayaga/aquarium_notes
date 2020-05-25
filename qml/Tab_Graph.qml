import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtCharts 2.3
import "custom"
import ".."


Item
{
    id: tab_Graph

    Rectangle
    {
        anchors.fill: parent
        color: "#00000040"

        ChartView
        {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: 300 * app.scale
            antialiasing: true

                ValueAxis {
                    id: axisX
                    min: 0
                    max: 10
                    tickCount: 5
                }

                ValueAxis {
                    id: axisY
                    min: -0.5
                    max: 1.5
                }

                LineSeries {
                    id: series1
                    axisX: axisX
                    axisY: axisY
                }

                LineSeries {
                    id: series2
                    axisX: axisX
                    axisY: axisY
                }
            }

            // Add data dynamically to the series
            Component.onCompleted: {
                for (var i = 0; i <= 10; i++) {
                    series1.append(i, Math.random());
                    series2.append(i, Math.random());
                }
            }
    }
}
