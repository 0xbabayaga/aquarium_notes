import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: pagesTabList
    height: AppTheme.rowHeightMin * app.scale

    property alias model: listTab.model
    property alias currentIndex: listTab.currentIndex

    signal sigCurrentIndexChanged(int id)

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        color: "#00000000"

        ListView
        {
            id: listTab
            anchors.fill: parent
            model: modelTabs
            orientation: ListView.Horizontal
            //spacing: AppTheme.rowSpacing
            currentIndex: 0

            property int cellWidth: rectContainer.width / 3

            delegate: Component
            {
                Rectangle
                {
                    width: listTab.cellWidth
                    height: AppTheme.rowHeightMin * app.scale
                    color:  "#00000000"

                    Text
                    {
                        color: AppTheme.whiteColor
                        font.pixelSize: (listTab.currentIndex === index) ? AppTheme.fontNormalSize * app.scale : AppTheme.fontNormalSize * app.scale
                        font.family: AppTheme.fontFamily
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        height: parent.height
                        text: tab

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                listTab.currentIndex = index
                                sigCurrentIndexChanged(currentIndex)
                            }
                        }
                    }

                    Rectangle
                    {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2 * app.scale
                        color: AppTheme.lightBlueColor
                        visible: (listTab.currentIndex === index)
                    }
                }
            }
        }

/*
        Component
        {
            id: delegate

            Item
            {
                id: itemContainer
                width: (index === currentIndex) ? 180 * app.scale : 120 * app.scale
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
                            listTab.currentIndex = index
                            sigCurrentIndexChanged(index)
                        }
                    }
                }
            }
        }

        PathView
        {
            id: listTab
            anchors.fill: parent
            pathItemCount: 3
            preferredHighlightBegin: 0.15
            preferredHighlightEnd: 0.15
            highlightRangeMode: PathView.StrictlyEnforceRange
            delegate: delegate

            path: Path
            {
                startX: 120/2 * app.scale
                startY: listTab.height/2

                PathAttribute { name: "iconScale"; value: 1 }
                PathAttribute { name: "iconOrder"; value: 0 }
                PathLine {x: listTab.width; y: listTab.height/2 }
                PathAttribute { name: "iconScale"; value: 1 }
                PathAttribute { name: "iconOpacity"; value: 1 }
            }

            onCurrentIndexChanged: sigCurrentIndexChanged(currentIndex)
        }
        */
    }
}
