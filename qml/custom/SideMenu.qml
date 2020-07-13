import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: sideMenu
    width: AppTheme.rightWidth * app.scale

    signal sigMenuSelected(int id)

    ListModel
    {
        id: menuListModel

        ListElement {   name: qsTr("ACCOUNT");      en: true    }
        ListElement {   name: qsTr("TANK INFO");    en: true    }
        ListElement {   name: qsTr("SETTINGS");     en: true    }
        ListElement {   name: qsTr("UTILITY");      en: false   }
    }

    Rectangle
    {
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        height: parent.width
        color: AppTheme.whiteColor

        Rectangle
        {
            id: rectAccountPhoto
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: AppTheme.margin * 3 * app.scale
            height: width
            radius: width / 2
            border.width: 2 * app.scale
            border.color: AppTheme.blueColor
            color: AppTheme.backLightBlueColor

            Text
            {
                id: textAccountName
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: rectAccountPhoto.bottom
                anchors.topMargin: AppTheme.padding * app.scale
                height: AppTheme.compHeight * app.scale
                verticalAlignment: Text.AlignBottom
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: "John Wick"
            }

            Text
            {
                id: textAccountEmail
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textAccountName.bottom
                height: AppTheme.compHeight / 2 * app.scale
                verticalAlignment: Text.AlignTop
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: "john.wick007@gmail.com"
            }
        }

        Rectangle
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2 * app.scale
            color: AppTheme.backLightBlueColor
        }
    }

    Rectangle
    {
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: AppTheme.margin * app.scale
        width: parent.width
        height: menuListModel.count * AppTheme.rowHeightMin * app.scale

        ListView
        {
            anchors.fill: parent
            spacing: 0
            interactive: false
            model: menuListModel

            delegate: Rectangle
            {
                id: rectCeil
                width: parent.width
                height: AppTheme.rowHeightMin * app.scale
                color: AppTheme.whiteColor

                Behavior on color { ColorAnimation { duration: 200 }    }

                Text
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.margin * 3 * app.scale
                    anchors.right: parent.right
                    height: AppTheme.rowHeightMin * app.scale
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueColor
                    text: name
                }

                SequentialAnimation
                {
                    id: rectCeilAnimation

                    ScaleAnimator
                    {
                        target: rectCeil
                        from: 1
                        to: 0.95
                        easing.type: Easing.OutBack
                        duration: 100
                    }

                    ScaleAnimator
                    {
                        target: rectCeil
                        from: 0.95
                        to: 1
                        easing.type: Easing.OutBack
                        duration: 500
                    }
                }

                MouseArea
                {
                    anchors.fill: parent
                    onPressed:
                    {
                        rectCeilAnimation.start()
                        color = AppTheme.lightBlueColor
                    }
                    onReleased:
                    {
                        sigMenuSelected(index)
                        color = AppTheme.whiteColor
                    }
                }
            }
        }
    }
}
