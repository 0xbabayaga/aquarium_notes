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

    property var ctx: null
    property int diagramHeight: 50 * app.scale

    function drawAxis(xMin, xMax, curvesCount)
    {
        if (ctx !== null)
        {
            canvas.height = diagramHeight * curvesCount
            ctx.setDiagramParams(xMin, xMax, canvas.width, canvas.height, diagramHeight)
        }
    }

    function drawCurve(name, yMin, yMax, points)
    {
        ctx.drawCurve(yMin, yMax, points)
        canvas.requestPaint()
    }


    Rectangle
    {
        anchors.fill: parent
        color: "#00000040"

        Canvas
        {
            id: canvas
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: diagramHeight

            onPaint:
            {
                if (ctx === null)
                    ctx = new Diagrams.DiagramView(canvas.getContext('2d'), canvas.width, canvas.height)
            }
        }
    }
}
