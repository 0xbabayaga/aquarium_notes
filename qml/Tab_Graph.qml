import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../js/diagrams.js" as Diagrams
import "custom"
import ".."


Item
{
    id: tab_Graph
    objectName: "tab_Graph"

    property int graphHeight: 100 * app.scale

    function clearDiagrams()
    {
        diagrams.reset()
    }

    function redraw(selectedPoint)
    {
        diagrams.setCurrentPoint(selectedPoint)
    }

    function drawDiagrams()
    {
    }

    function addDiagram(num, name, xMin, xMax, yMin, yMax, points)
    {
        diagrams.add(name, tab_Graph.graphHeight, xMin, xMax, yMin, yMax, points)
        flickableContainer.contentHeight = diagrams.curnesCnt * tab_Graph.graphHeight
    }

    Flickable
    {
        id: flickableContainer
        anchors.fill: parent
        anchors.topMargin: AppTheme.padding * app.scale
        anchors.bottomMargin: AppTheme.margin * app.scale * 4
        contentWidth: flickableContainer.width
        contentHeight: 1400 * app.scale
        clip: true

        DiagramView
        {
            id: diagrams
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
        }

        ScrollBar.vertical: ScrollBar
        {
            policy: ScrollBar.AlwaysOn
            parent: flickableContainer.parent
            anchors.top: flickableContainer.top
            anchors.left: flickableContainer.right
            anchors.leftMargin: -AppTheme.padding * app.scale
            anchors.bottom: flickableContainer.bottom

            contentItem: Rectangle
            {
                implicitWidth: 2
                implicitHeight: 100
                radius: width / 2
                color: AppTheme.hideColor
            }
        }
    }

    PointList
    {
        id: pointList
        anchors.top: flickableContainer.bottom
        anchors.topMargin: AppTheme.margin * app.scale
        anchors.left: parent.left
        anchors.right: parent.right
        height: AppTheme.rowHeight * app.scale
        model:  graphPointsList

        onSigCurrentIndexChanged: redraw(id)
    }
}
