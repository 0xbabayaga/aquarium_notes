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

    property int curveCount: 0

    property var component
    property var diagram

    function drawCurve(name, xMin, xMax, yMin, yMax, points)
    {
        component = Qt.createComponent("qrc:/qml/custom/DiagramView.qml");

        if (component.status === Component.Ready)
        {
            diagram = component.createObject(rectContainer, { "x": 0, "y": curveCount * 100 * app.scale });

            if (diagram === null)
                console.log("Error creating object")

            delayedTmr.start()

            curveCount++
        }
    }

    function delayedDraw()
    {
        console.log("triggered")
        diagram.drawCurve("asd", 0, 0, 100, 100, 0)
    }


    Timer
    {
        id: delayedTmr
        running: false
        interval: 1000
        onTriggered: delayedDraw()
    }

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        color: "#00000040"

        /*
        DiagramView
        {
            id: diagramView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 100 * app.scale
        }
        */
    }
}
