import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: currentActivities

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectDataHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: AppTheme.compHeight * app.scale
            color: "#00000000"

            Text
            {
                verticalAlignment: Text.AlignVCenter
                width: 80 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("CURRENT ACTIVITIES: ")
            }
        }
    }
}
