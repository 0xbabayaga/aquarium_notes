import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import AppDefs 1.0
import "../"

Item
{
    id: sideMenu

    signal sigMenuSelected(int id)

    property bool isOpened: false
    property alias accountName: textAccountName.text
    property alias accountEmail: textAccountEmail.text
    property alias accountImage: imgAccount.source

    function showMenu(vis)
    {
        showAnimation.stop()
        hideAnimation.stop()

        if (vis === true)
        {
            showAnimation.start()
            isOpened = true
        }
        else
        {
            hideAnimation.start()
            isOpened = false
        }
    }

    ListModel
    {
        id: menuListModel

        ListElement {   name: qsTr("ACCOUNT");      index: AppDefs.Menu_Account;    en: true    }
        ListElement {   name: qsTr("TANK INFO");    index: AppDefs.Menu_TankInfo;   en: true    }
        ListElement {   name: qsTr("SETTINGS");     index: AppDefs.Menu_Settings;   en: true    }
        ListElement {   name: qsTr("UTILITY");      index: AppDefs.Menu_None;       en: false   }
    }

    SequentialAnimation
    {
        id: showAnimation

        onStarted:
        {
            shadowEffect.visible = true
            rectShadow.visible = true
        }

        NumberAnimation
        {
            target: rectShadow
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }

        NumberAnimation
        {
            target: rectShadow
            property: "anchors.leftMargin"
            from: -AppTheme.rowHeightMin * app.scale
            to: -AppTheme.rightWidth * app.scale
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation
    {
        id: hideAnimation

        onFinished:
        {
           shadowEffect.visible = false
           rectShadow.visible = false
        }

        NumberAnimation
        {
            target: rectShadow
            property: "anchors.leftMargin"
            from: -AppTheme.rightWidth * app.scale
            to: -AppTheme.rowHeightMin * app.scale
            duration: 200
            easing.type: Easing.InQuad
        }

        NumberAnimation
        {
            target: rectShadow
            property: "opacity"
            from: 1
            to: 0
            duration: 200
        }
    }

    Rectangle
    {
        id: rectBackground
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: rectShadow.left
        height: parent.height
        opacity: rectShadow.opacity
        visible: rectShadow.visible
        color: AppTheme.backLightBlueColor

        MouseArea
        {
            anchors.fill: parent
        }
    }

    Rectangle
    {
        id: rectShadow
        anchors.top: parent.top
        anchors.left: parent.right
        anchors.leftMargin: -AppTheme.rowHeightMin * app.scale
        width: AppTheme.rightWidth * app.scale
        height: parent.height
        color: AppTheme.whiteColor
        visible: false
    }

    DropShadow
    {
        id: shadowEffect
        anchors.fill: rectShadow
        horizontalOffset: -10
        verticalOffset: 0
        radius: 8.0 * app.scale
        samples: 8 * app.scale
        color: "#10000000"
        source: rectShadow
        opacity: rectShadow.opacity
        visible: false
    }

    Rectangle
    {
        anchors.fill: rectShadow
        color: AppTheme.whiteColor
        visible: rectShadow.visible
        opacity: rectShadow.opacity

        Rectangle
        {
            id: rectHeader
            anchors.top: parent.top
            anchors.left: parent.left
            height: parent.width
            width: parent.width

            Rectangle
            {
                id: rectAccountPhoto
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: AppTheme.margin * 3 * app.scale
                height: width
                radius: width / 2
                border.width: 3 * app.scale
                border.color: AppTheme.blueColor
                color: AppTheme.backLightBlueColor

                Image
                {
                    id: imgAccount
                    anchors.fill: parent
                    source: ""
                    mipmap: true
                    layer.enabled: true
                    layer.effect: OpacityMask
                    {
                        maskSource: imgTankMask
                    }
                }

                Rectangle
                {
                    id: imgTankMask
                    anchors.fill: parent
                    radius: height/2
                    visible: false
                }
            }

            Text
            {
                id: textAccountName
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: rectAccountPhoto.bottom
                anchors.topMargin: AppTheme.padding / 2 * app.scale
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
            anchors.top: rectHeader.bottom
            anchors.topMargin: AppTheme.margin * app.scale
            anchors.bottom: parent.bottom
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

                    Image
                    {
                        id: img
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.margin * 2 * app.scale
                        fillMode: Image.PreserveAspectFit
                        width: 16 * app.scale
                        height: 16 * app.scale
                        source: "qrc:/resources/img/icon_app.png"
                        mipmap: true
                    }

                    ColorOverlay
                    {
                        anchors.fill: img
                        source: img
                        color: AppTheme.blueColor
                    }

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
                            showMenu(false)
                            sigMenuSelected(index)
                            color = AppTheme.whiteColor
                        }
                    }
                }
            }
        }
    }

    Image
    {
        id: imgAppIcon
        anchors.left: rectShadow.left
        anchors.leftMargin: 12 * app.scale
        anchors.top: parent.top
        anchors.topMargin: 12 * app.scale
        fillMode: Image.PreserveAspectFit
        width: 24 * app.scale
        height: 24 * app.scale
        source: "qrc:/resources/img/icon_app.png"
        mipmap: true

        ColorOverlay
        {
            anchors.fill: imgAppIcon
            source: imgAppIcon
            color: AppTheme.blueColor
        }

        SequentialAnimation
        {
            id: imgAppAnimation

            ScaleAnimator
            {
                target: imgAppIcon
                from: 1
                to: 0.95
                easing.type: Easing.OutBack
                duration: 100
            }

            ScaleAnimator
            {
                target: imgAppIcon
                from: 0.95
                to: 1
                easing.type: Easing.OutBack
                duration: 500
            }
        }

        MouseArea
        {
            anchors.fill: parent
            onPressed: imgAppAnimation.start()
            onReleased: showMenu(!isOpened)
        }
    }
}
