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

    function add(num, id, height, xMin, xMax, yMin, yMax, points)
    {
        diagramView.height = height

        if (ctx === null)
            ctx = new Diagrams.DiagramView(app.scale)

        ctx.setCurve(num, app.getParamById(id).shortName, app.getParamById(id).unitName, app.getParamById(id).color, xMin, xMax, yMin, yMax, points)
    }

    function setCurrentPoint(currentPoint)
    {
        ctx.setCurrentPoint(currentPoint)
    }

    function draw()
    {
        canvas.requestPaint()
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000040"

        Rectangle
        {
            id: rectContainerShadow
            anchors.fill: parent
            color: "#00000000"
        }

        Rectangle
        {
            anchors.fill: rectContainerShadow
            color: "#00000000"

            Canvas
            {
                id: canvas
                anchors.fill: parent

                onPaint:
                {
                    ctx.init(canvas.getContext('2d'), canvas.width, canvas.height)
                    ctx.draw()
                }
            }
        }
    }
}
