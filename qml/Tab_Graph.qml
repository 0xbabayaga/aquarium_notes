import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../js/diagrams.js" as Diagrams
import "custom"
import ".."


Item
{
    id: tab_Graph

    property var ctx: null

    function readValues(anArray, anObject)
    {
        for (var i = 0; i < anArray.length; i++)
            console.log("Array item:", anArray[i])

        for (var prop in anObject)
        {
            console.log("Object item:", prop, "=", anObject[prop])
        }
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

                ctx.draw()
            }
        }
    }
}
