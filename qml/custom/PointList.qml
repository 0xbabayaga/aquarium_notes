import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: pointList
    height: 64 * app.scale
    width: (model) ? ((model.length > 2) ? app.width + AppTheme.margin * app.scale * 4 : 360 * app.scale) : app.width

    property alias model: view.model
    property alias currentIndex: view.currentIndex

    signal sigCurIndexChanged(int id)

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Component
        {
            id: delegate

            Item
            {
                id: itemContainer
                width: 64 * app.scale
                height: pointList.height
                scale: PathView.iconScale

                Rectangle
                {
                    anchors.fill: parent
                    color: "#00000000"

                    Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: app.printDate(tm)
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSize * app.scale
                        color: (currentIndex === index) ? AppTheme.whiteColor : AppTheme.blueColor
                        verticalAlignment: Text.AlignVCenter
                        height: parent.height
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            console.log("1234")

                            view.currentIndex = index
                            //sigCurIndexChanged(view.currentIndex)
                        }
                    }
                }
            }
        }

        Rectangle
        {
            anchors.top: parent.top
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80 * app.scale
            height: AppTheme.compHeight * app.scale
            color: AppTheme.blueColor
        }

        PathView
        {
            id: view
            anchors.fill: parent
            pathItemCount: 5
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            delegate: delegate

            path: Path
            {
                startX: 0
                startY: view.height/2

                PathAttribute { name: "iconScale"; value: 0.75 }
                PathAttribute { name: "iconOrder"; value: 0 }
                PathLine {x: view.width/2; y: view.height/2 }
                PathAttribute { name: "iconScale"; value: 1.5 }
                PathAttribute { name: "iconOpacity"; value: 1.5 }
                PathLine {x: view.width; y: view.height/2 }
            }

            onCurrentIndexChanged: sigCurIndexChanged(currentIndex)
        }
    }
}
