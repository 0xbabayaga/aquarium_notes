import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: pagesTabList
    height: AppTheme.compHeight * app.scale
    width: app.width

    property alias model: view.model
    property alias currentIndex: view.currentIndex

    signal sigCurrentIndexChanged(int id)

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        //color: "#f1feff"//AppTheme.whiteColor
        color: "#00000000"

        Component
        {
            id: delegate

            Item
            {
                id: itemContainer
                width: 128 * app.scale
                height: parent.height
                scale: PathView.iconScale

                Rectangle
                {
                    anchors.fill: parent
                    radius: AppTheme.radius/2 * app.scale
                    color: "#00000000"
                    clip: true

                    Text
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.padding/2 * app.scale
                        text: tab
                        font.family: AppTheme.fontFamily
                        //font.pixelSize: AppTheme.fontNormalSize * app.scale
                        font.pixelSize: (index === currentIndex) ? AppTheme.fontBigSize * app.scale : AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            view.currentIndex = index
                            sigCurrentIndexChanged(index)
                        }
                    }
                }
            }
        }

        PathView
        {
            id: view
            anchors.fill: parent
            pathItemCount: 5
            preferredHighlightBegin: 0.1
            preferredHighlightEnd: 0.1
            highlightRangeMode: PathView.StrictlyEnforceRange
            delegate: delegate

            path: Path
            {
                startX: 120/2 * app.scale
                startY: view.height/2

                PathAttribute { name: "iconScale"; value: 1 }
                PathAttribute { name: "iconOrder"; value: 0 }
                PathLine {x: view.width; y: view.height/2 }
                PathAttribute { name: "iconScale"; value: 1 }
                PathAttribute { name: "iconOpacity"; value: 1 }
                //PathLine {x: view.width; y: view.height/2 }
            }

            onCurrentIndexChanged: sigCurrentIndexChanged(currentIndex)
        }
    }

    /*
    DropShadow
    {
        anchors.fill: rectContainer
        horizontalOffset: 0
        verticalOffset: 2
        radius: 6.0
        samples: 16
        color: "#20000000"
        source: rectContainer
    }
    */
}
