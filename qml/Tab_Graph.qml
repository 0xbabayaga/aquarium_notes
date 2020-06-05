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

    property int graphHeight: 128 * app.scale
    property var diagramObjs: []
    property var component: 0
    property var diagram: 0

    Component.onCompleted:
    {
        component = Qt.createComponent("qrc:/qml/custom/DiagramView.qml");
    }

    function clearDiagrams()
    {
        console.log("clearDiagrams", tab_Graph.diagramObjs.length)

        for (var i = 0; i < tab_Graph.diagramObjs.length; i++)
        {
            tab_Graph.diagramObjs[0].destroy()
            tab_Graph.diagramObjs.shift()
        }
    }

    function redraw(selectedPoint)
    {
        console.log("redraw", selectedPoint, tab_Graph.diagramObjs.length)

        for (var i = 0; i < tab_Graph.diagramObjs.length; i++)
        {
            tab_Graph.diagramObjs[i].setCurrentPoint(selectedPoint)
            tab_Graph.diagramObjs[i].draw()
        }
    }

    function drawDiagrams()
    {
        //delayedTmr.start()
    }

    function addDiagram(num, name, xMin, xMax, yMin, yMax, points)
    {
        if (num === 0)
        {
            if (tab_Graph.component.status === Component.Ready)
            {
                tab_Graph.diagram = component.createObject(rectContainer, { "x": 0, "y": tab_Graph.diagramObjs.length * tab_Graph.graphHeight })
                tab_Graph.diagramObjs.push(tab_Graph.diagram)
                tab_Graph.diagram.add(num, name, tab_Graph.graphHeight, xMin, xMax, yMin, yMax, points)

                console.log("addded", num, tab_Graph.diagramObjs.length)

                flickableContainer.contentHeight = tab_Graph.diagramObjs.length * tab_Graph.graphHeight
            }
        }
        else
        {
            tab_Graph.diagramObjs[diagramObjs.length - 1].add(num, name, tab_Graph.graphHeight, xMin, xMax, yMin, yMax, points)
        }
    }

    /*
    Timer
    {
        id: delayedTmr
        running: false
        interval: 500
        repeat: false
        onTriggered:
        {
            for (var i = 0; i < tab_Graph.diagramObjs.length; i++)
            {
                //tab_Graph.diagramObjs[i].draw()
            }
        }
    }
    */

    Flickable
    {
        id: flickableContainer
        anchors.fill: parent
        anchors.topMargin: AppTheme.padding * app.scale
        anchors.bottomMargin: AppTheme.margin * app.scale * 3
        anchors.rightMargin: AppTheme.margin * app.scale
        contentWidth: flickableContainer.width
        contentHeight: 1400 * app.scale
        clip: true

        Rectangle
        {
            id: rectContainer
            anchors.fill: parent
            color: "#00000000"
        }

        ScrollBar.vertical: ScrollBar
        {
            policy: ScrollBar.AlwaysOn
            parent: flickableContainer.parent
            anchors.top: flickableContainer.top
            anchors.left: flickableContainer.right
            anchors.leftMargin: AppTheme.padding * app.scale
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
        anchors.left: parent.left
        anchors.right: parent.right
        height: AppTheme.rowHeight * app.scale
        model:  graphPointsList

        onSigCurrentIndexChanged: redraw(id)
    }
}
