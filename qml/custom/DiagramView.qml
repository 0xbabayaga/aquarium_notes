import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/diagrams.js" as Diagrams
import ".."

Item
{
    id: diagramView
    width: app.width
    height: 128

    property var ctx: null
    property int curnesCnt: 0

    function add(id, height, xMin, xMax, yMin, yMax, points)
    {
        curnesCnt++

        diagramView.height = height * curnesCnt

        if (ctx === null)
            ctx = new Diagrams.DiagramView(app.scale, height)

        ctx.addCurve(app.getParamById(id).shortName,
                     app.getParamById(id).unitName,
                     app.getParamById(id).color,
                     xMin, xMax,
                     yMin, yMax,
                     app.getParamById(id).min, app.getParamById(id).max,
                     points)
    }

    function reset()
    {
        if (ctx !== null)
            ctx.reset()
    }

    function setCurrentPoint(currentPoint)
    {
        if (ctx)
        {
            ctx.setCurrentPoint(currentPoint)
            canvas.requestPaint()
        }
    }

    function draw()
    {
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
                if (ctx)
                {
                    ctx.init(canvas.getContext('2d'), canvas.width, canvas.height)
                    ctx.draw()
                }
            }
        }
    }
}
