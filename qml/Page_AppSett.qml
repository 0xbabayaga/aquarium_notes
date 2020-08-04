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
    id: page_AppSett

    signal sigClosing()
    signal sigClosed()

    function showPage(vis)
    {
        showPageAnimation.stop()

        if (vis === true)
            showPageAnimation.to = 0
        else
            showPageAnimation.to = page_AppSett.height

        showPageAnimation.start()
    }

    function setCurrentImage(img)
    {
        imgTankAvatar.addBase64ImageToList(img)
    }

    NumberAnimation
    {
        id: showPageAnimation
        target: rectContainer
        property: "anchors.topMargin"
        duration: 400
        easing.type: Easing.OutBack
        onStarted: page_AppSett.visible = true
        onFinished:
        {
            if (rectContainer.anchors.topMargin > 0 && page_AppSett.visible === true)
            {
                page_AppSett.visible = false
                sigClosed()
            }
        }
    }

    Rectangle
    {
        id: rectContainer
        anchors.top: parent.top
        anchors.topMargin: page_AppSett.height
        anchors.left: parent.left
        anchors.right: parent.right
        height: page_AppSett.height
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor
    }

    DropShadow
    {
        anchors.fill: rectContainer
        horizontalOffset: 0
        verticalOffset: -3
        radius: 16.0 * app.scale
        samples: 16
        color: "#20000000"
        source: rectContainer
    }

    Rectangle
    {
        id: rectRealContainer
        anchors.fill: rectContainer
        color: "#00000000"

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -(AppTheme.rowHeightMin - AppTheme.margin) * app.scale
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


            Rectangle
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: AppTheme.rowHeight * app.scale
                color: "#00000000"

                Text
                {
                    id: textHeader
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.padding * app.scale
                    verticalAlignment: Text.AlignBottom
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("SETTINGS")
                }
            }

            Flickable
            {
                id: flickView
                anchors.top: parent.top
                anchors.topMargin: AppTheme.margin * 2 * app.scale
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.rightMargin: AppTheme.padding * app.scale
                contentWidth: width
                contentHeight: height * 2
                flickableDirection: Flickable.VerticalFlick
                interactive: false
                clip: true

                NumberAnimation on contentY
                {
                    id: animationToPage
                    from: 0
                    to: 0
                    duration: 1000
                    easing.type: Easing.OutExpo
                    running: false
                }

                Rectangle
                {
                    id: rectSettings
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height / 2
                    color: "#00000000"

                    Column
                    {
                        id: columnContainer
                        width: parent.width
                        anchors.top: parent.top
                        anchors.topMargin: AppTheme.padding * app.scale

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Language")
                        }

                        ComboListQuick
                        {
                            id: comboLang
                            objectName: "comboLang"
                            propertyName: qsTr("Language");
                            width: parent.width
                            model: langsModel
                            //KeyNavigation.tab: textFileName

                            ListModel
                            {
                                id: langsModel

                                ListElement {  name: "English"      }
                                ListElement {  name: "Беларускi"    }
                                ListElement {  name: "Русский"      }
                            }

                            onCurrentIndexChanged: app.sigLanguageChanged(currentIndex)
                        }

                        Item { height: AppTheme.padding * app.scale; width: 1;}

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Units")
                        }

                        ComboListQuick
                        {
                            id: comboMetrics
                            propertyName: qsTr("Units");
                            width: parent.width
                            model: unitsModel
                            //KeyNavigation.tab: textFileName

                            ListModel
                            {
                                id: unitsModel

                                ListElement { name: qsTr("Metric")}
                                ListElement { name: qsTr("Imperial")}
                            }
                        }

                    }

                    IconSimpleButton
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.margin * app.scale
                        image: "qrc:/resources/img/icon_arrow_down.png"

                        onSigButtonClicked:
                        {
                            showPage(false)
                            sigClosing()
                        }
                    }
                }
            }
        }
    }
}
