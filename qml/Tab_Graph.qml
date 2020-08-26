import QtQuick 2.0
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
        flickableContainer.contentHeight = diagrams.currentCnt * tab_Graph.graphHeight
    }

    PointList
    {
        id: pointList
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        model:  graphPointsList
        visible: (graphPointsList.length !== 0)

        onSigCurIndexChanged: redraw(id)
    }

    Flickable
    {
        id: flickableContainer
        anchors.fill: parent
        anchors.topMargin: pointList.height + AppTheme.padding * app.scale
        anchors.bottomMargin: AppTheme.margin * app.scale
        contentHeight: height * 2
        contentWidth: width
        clip: true

        DiagramView
        {
            id: diagrams
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
        }

        Rectangle
        {
            anchors.fill: parent
            visible: (graphPointsList) ? (graphPointsList.length === 0) : false
            color: "#00000000"

            Text
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -AppTheme.margin * 3 * app.scale
                horizontalAlignment: Text.AlignHCenter
                width: 250 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                wrapMode: Text.WordWrap
                color: AppTheme.greyColor
                text: qsTr("No record found for this aquarium")
            }
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
                implicitWidth: 2 * app.scale
                implicitHeight: 100 * app.scale
                radius: width / 2
                color: AppTheme.hideColor
            }
        }
    }
}
