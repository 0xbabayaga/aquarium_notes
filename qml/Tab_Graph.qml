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

    function addDiagram(num, paramId, xMin, xMax, yMin, yMax, points)
    {
        diagrams.add(paramId, tab_Graph.graphHeight, xMin, xMax, yMin, yMax, points)
        flickableContainer.contentHeight = (diagrams.curnesCnt + 1) * tab_Graph.graphHeight
    }

    PointList
    {
        id: pointList
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model:  graphPointsList
        z: 2

        onSigCurIndexChanged: redraw(id)
    }

    Flickable
    {
        id: flickableContainer
        anchors.top: pointList.bottom
        anchors.topMargin: AppTheme.padding * app.scale
        anchors.bottom: parent.bottom
        anchors.bottomMargin: AppTheme.margin * app.scale// * 4
        anchors.left: parent.left
        anchors.right: parent.right
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
}
