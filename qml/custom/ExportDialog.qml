import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: exportDialog
    width: app.width
    height: app.height
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    property bool inProgress: false
    property bool isImport: false
    property alias message: textMessage.text

    signal sigAccept()
    signal sigCancel()

    function showDialog(vis, message)
    {
        rectContOpacityAnimation.stop()

        if (vis === true)
        {
            textMessage.text = message
            exportDialog.inProgress = true
            rectCont.visible = true
            rectContOpacityAnimation.from = 0
            rectContOpacityAnimation.to = 1
        }
        else
        {
            rectContOpacityAnimation.from = 1
            rectContOpacityAnimation.to = 0
        }

        rectContOpacityAnimation.start()
    }

    Rectangle
    {
        id: rectCont
        anchors.fill: parent
        parent: Overlay.overlay
        focus: true
        clip: true
        visible: false
        color: "#00000000"

        MouseArea { anchors.fill: parent }

        NumberAnimation
        {
            id: rectContOpacityAnimation
            target: rectCont
            property: "opacity"
            duration: 300
            easing.type: Easing.InOutQuad
            from: 0
            to: 1

            onFinished: if (to === 0) rectCont.visible = false
        }

        Rectangle
        {
            color: AppTheme.backHideColor
            anchors.fill: parent

            Rectangle
            {
                id: rectWindow
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - AppTheme.margin * app.scale
                height: 240 * app.scale - AppTheme.margin * app.scale
                radius: AppTheme.radius / 2 * app.scale
                color: AppTheme.whiteColor

                Behavior on height
                {
                    NumberAnimation { duration: 200 }
                }

                Text
                {
                    id: textHeader
                    anchors.top: parent.top
                    anchors.topMargin: AppTheme.padding * app.scale
                    height: AppTheme.compHeight * app.scale
                    width: parent.width
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueFontColor
                    text: (isImport === true) ? qsTr("Importing") : qsTr("Exporting")
                }

                Text
                {
                    id: textMessage
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: - AppTheme.padding * app.scale
                    height: AppTheme.compHeight * app.scale
                    width: parent.width - AppTheme.margin * app.scale * 2
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.greyDarkColor
                    text: "TEXT"
                    wrapMode: Text.WordWrap

                    onContentHeightChanged:
                    {
                        rectWindow.height = 240 * app.scale - AppTheme.margin * app.scale + textMessage.contentHeight
                    }
                }

                IconSimpleButton
                {
                    id: buttonCancel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.padding * app.scale
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.leftMargin: AppTheme.padding * app.scale
                    image: "qrc:/resources/img/icon_ok.png"
                    opacity: (inProgress === true) ? 0 : 1
                    enabled: (inProgress === false)

                    onSigButtonClicked: showDialog(false, 0)
                }
            }
        }
    }
}
