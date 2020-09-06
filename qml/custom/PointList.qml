import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/datetimeutility.js" as DateTimeUtils
import "../"

Item
{
    id: pointList
    height: AppTheme.compHeight * app.scale
    width: app.width

    property alias model: view.model
    property alias currentIndex: view.currentIndex

    signal sigCurIndexChanged(int id)

    Rectangle
    {
        id: rectShadow
        anchors.fill: parent
    }

    DropShadow
    {
        anchors.fill: rectShadow
        horizontalOffset: 0
        verticalOffset: 0
        radius: AppTheme.shadowSize
        samples: AppTheme.shadowSamples
        color: AppTheme.shadowColor
        source: rectShadow
    }


    Rectangle
    {
        id: container
        anchors.fill: rectShadow
        color: AppTheme.lightBlueColor

        ListView
        {
            id: view
            anchors.fill: parent
            orientation: ListView.Horizontal
            maximumFlickVelocity: 10000
            clip: true

            property int cellWidth: 70 * app.scale

            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (width - cellWidth) / 2
            preferredHighlightEnd: (width + cellWidth) / 2

            delegate: Component
            {
                Rectangle
                {
                    width: view.cellWidth
                    height: AppTheme.rowHeight/2 * app.scale
                    color: (view.currentIndex === index) ? AppTheme.blueColor : "#00000000"

                    Text
                    {
                        anchors.fill: parent
                        color: (view.currentIndex === index) ? AppTheme.whiteColor : AppTheme.blueFontColor
                        font.pixelSize: (view.currentIndex === index) ? AppTheme.fontNormalSize * app.scale : AppTheme.fontSmallSize * app.scale
                        font.family: AppTheme.fontFamily
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: (new DateTimeUtils.DateTimeUtil()).printDateEx(tm)

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                view.currentIndex = index
                                sigCurIndexChanged(currentIndex)
                            }
                        }
                    }
                }
            }
        }
    }
}
