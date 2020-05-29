import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/diagrams.js" as Diagrams
import ".."

Item
{
    id: diagramView
    width: app.width
    height: 100 * app.scale

    property var ctx: null

    function drawCurve(name, xMin, xMax, yMin, yMax, points)
    {
        if (ctx === null)
            ctx = new Diagrams.DiagramView(canvas.getContext('2d'), canvas.width, canvas.height)

        ctx.drawCurve(name, xMin, xMax, yMin, yMax, points)

        canvas.requestPaint()
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000040"

        Canvas
        {
            id: canvas
            anchors.fill: parent

            onPaint:
            {
                if (ctx === null)
                    ctx = new Diagrams.DiagramView(canvas.getContext('2d'), canvas.width, canvas.height)
            }
        }
    }
}
