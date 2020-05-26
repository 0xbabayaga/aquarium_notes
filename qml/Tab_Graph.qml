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

    function drawAxis(xMin, xMax, yMin, yMax)
    {
        if (ctx !== null)
        {
            ctx.setLimits(xMin, xMax, yMin, yMax)
            //canvas.requestPaint()
        }
    }

    function drawCurve(name, points)
    {
        ctx.drawGrid()
        ctx.drawCurve(points)
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
            height: 300 * app.scale

            onPaint:
            {
                if (ctx === null)
                    ctx = new Diagrams.DiagramView(canvas.getContext('2d'), canvas.width, canvas.height)

                //ctx.draw()
            }
        }
    }
}
