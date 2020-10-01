import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import "custom"
import AppDefs 1.0
import "../js/datetimeutility.js" as DateTimeUtils

Item
{
    id: page_About

    signal sigClosing()
    signal sigClosed()

    function showPage(vis)
    {
        showPageAnimation.stop()

        if (vis === true)
            showPageAnimation.to = 0
        else
            showPageAnimation.to = page_About.height

        showPageAnimation.start()
    }

    NumberAnimation
    {
        id: showPageAnimation
        target: rectContainerShadow
        property: "anchors.topMargin"
        duration: 200
        easing.type: Easing.OutCubic
        onStarted: page_About.visible = true
        onFinished:
        {
            if (rectContainerShadow.anchors.topMargin > 0 && page_About.visible === true)
            {
                page_About.visible = false
                sigClosed()
            }
        }
    }

    Rectangle
    {
        id: rectContainerShadow
        anchors.top: parent.top
        anchors.topMargin: page_About.height
        anchors.left: parent.left
        anchors.right: parent.right
        height: page_About.height
        color: AppTheme.whiteColor
    }

    DropShadow
    {
        anchors.fill: rectContainerShadow
        horizontalOffset: 0
        verticalOffset: -AppTheme.shadowOffset * app.scale
        radius: AppTheme.shadowSize * app.scale
        samples: AppTheme.shadowSamples * app.scale
        color: AppTheme.shadowColor
        source: rectContainerShadow
    }

    Rectangle
    {
        id: rectContainer
        anchors.fill: rectContainerShadow
        color: AppTheme.whiteColor

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: AppTheme.padding * app.scale
            width: parent.width
            height: width * 0.75
            source: "qrc:/resources/img/back_waves.png"
            opacity: 0.3
        }

        Rectangle
        {
            id: rectTankInfo
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.rightMargin: AppTheme.padding * app.scale
            color: "#00000000"

            IconSimpleButton
            {
                id: imgArrowBack
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * app.scale
                image: "qrc:/resources/img/icon_arrow_left.png"

                onSigButtonClicked:
                {
                    showPage(false)
                    sigClosing()
                }
            }

            Text
            {
                id: textHeader
                anchors.verticalCenter: imgArrowBack.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                verticalAlignment: Text.AlignBottom
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("ABOUT")
            }

            Image
            {
                anchors.top: parent.top
                anchors.topMargin: AppTheme.rowHeight * app.scale
                anchors.horizontalCenter: parent.horizontalCenter
                width: AppTheme.rowHeight * 2 * app.scale
                height: width
                source: "qrc:/resources/img/icon.png"
                mipmap: true
            }

            Column
            {
                anchors.top: parent.top
                anchors.topMargin: AppTheme.rowHeight * 3 * app.scale
                anchors.left: parent.left
                anchors.right: parent.right

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    width: parent.width
                    height: AppTheme.compHeight * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueColor
                    text: app.global_APP_NAME
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    width: parent.width
                    height: AppTheme.compHeight * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSmallSize * app.scale
                    color: AppTheme.blueColor
                    wrapMode: Text.WordWrap
                    text: app.global_APP_DOMAIN
                }

                Text
                {
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    width: parent.width
                    height: AppTheme.compHeight * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSmallSize * app.scale
                    color: AppTheme.greyColor
                    wrapMode: Text.WordWrap
                    text: qsTr("Application version: ") + app.global_APP_VERSION
                }
            }


            Rectangle
            {
                anchors.top: parent.top
                anchors.topMargin: AppTheme.rowHeight * 2 * app.scale
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                color: "#00000000"
                opacity: (app.isFullFunctionality() === true) ? 0 : 1
                visible: !(opacity === 0)

                Text
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: AppTheme.compHeight / 2 * app.scale
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSmallSize * app.scale
                    color: AppTheme.greyColor
                    wrapMode: Text.WordWrap
                    text: qsTr("You have a limited version of application. To get a full version of application please buy <b>Aquarium Story Pro</b> or register (by pressing button below).")
                }

                IconSimpleButton
                {
                    id: registerApp
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    image: "qrc:/resources/img/icon_app_reg.png"

                    onSigButtonClicked:
                    {
                        cloudCommWaitDialog.showDialog(true,
                                              qsTr("Communicating with cloud"),
                                              qsTr("Please wait ... "))
                        app.sigRegisterApp()
                    }
                }
            }
        }
    }

    WaitDialog
    {
        id: cloudCommWaitDialog
        objectName: "cloudCommWaitDialog"
    }
}
