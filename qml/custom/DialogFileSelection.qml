import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import "../custom"
import AppDefs 1.0

Item
{
    id: dialogFileSelection
    width: app.width
    height: app.height

    property alias filesListModel: filesListView.model
    property bool isSelectFile: true

    signal sigCancel()
    signal sigOk(string file)

    function show(visible)
    {
        if (visible === true)
        {
            showDialogAnimation.start()
            rectFakeDataContainer.anchors.topMargin = AppTheme.padding * 5 * app.scale
        }
        else
        {
            rectFakeDataContainer.anchors.topMargin = rectContainer.height
            hideDialogAnimation.start()
        }
    }

    NumberAnimation
    {
        id: showDialogAnimation
        target: rectContainer
        property: "opacity"
        duration: 100
        from: 0
        to: 1
        easing.type: Easing.InOutQuad
        onStarted: rectContainer.visible = true
    }

    NumberAnimation
    {
        id: hideDialogAnimation
        target: rectContainer
        property: "opacity"
        duration: 100
        from: 1
        to: 0
        easing.type: Easing.InOutQuad
        onStopped: rectContainer.visible = false
    }


    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        parent: Overlay.overlay
        color: AppTheme.backHideColor
        opacity: 0
        visible: false

        MouseArea { anchors.fill: parent }

        Rectangle
        {
            id: rectFakeDataContainer
            anchors.fill: parent
            anchors.topMargin: rectContainer.height

            Behavior on anchors.topMargin
            {
                NumberAnimation { duration: 200 }
            }
        }

        DropShadow
        {
            anchors.fill: rectFakeDataContainer
            horizontalOffset: 0
            verticalOffset: -AppTheme.shadowOffset * app.scale
            radius: AppTheme.shadowSize/2 * app.scale
            samples: AppTheme.shadowSamples * app.scale
            color: AppTheme.shadowColor
            source: rectFakeDataContainer
        }

        Rectangle
        {
            id: rectAddActionDialog
            anchors.fill: rectFakeDataContainer
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            color: "#00000020"

            Behavior on opacity
            {
                NumberAnimation {   duration: 200 }
            }

            Text
            {
                id: textHeader
                anchors.top: parent.top
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
                height: AppTheme.rowHeightMin * app.scale
                width: 100 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueFontColor
                text: (dialogFileSelection.isSelectFile === true) ? qsTr("SELECT A FILE FOR IMPORT") : qsTr("ENTER A FILE NAME")
            }

            Rectangle
            {
                anchors.top: textHeader.bottom
                width: parent.width
                height: 1 * app.scale
                color: AppTheme.backLightBlueColor
            }

            ListView
            {
                id: filesListView
                anchors.fill: parent
                anchors.topMargin: AppTheme.rowHeight * app.scale
                spacing: 0
                interactive: true

                delegate: Rectangle
                {
                    width: parent.width
                    height: AppTheme.compHeight * app.scale
                    color: (index === filesListView.currentIndex) ? AppTheme.backLightBlueColor : AppTheme.whiteColor

                    Row
                    {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Text
                        {
                            verticalAlignment: Text.AlignVCenter
                            height: AppTheme.compHeight * app.scale
                            width: 140 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueFontColor
                            text: name
                        }

                        /*
                        Text
                        {
                            verticalAlignment: Text.AlignVCenter
                            height: AppTheme.compHeight * app.scale
                            width: 50 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: fullPath
                        }
                        */
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: filesListView.currentIndex = index
                        onDoubleClicked:
                        {
                            filesListView.currentIndex = index
                            show(false)
                            sigOk(filesListView.model[filesListView.currentIndex].fullPath)
                        }
                    }
                }
            }


            IconSimpleButton
            {
                id: buttonCancel
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.left: parent.left
                image: "qrc:/resources/img/icon_cancel.png"

                onSigButtonClicked: show(false)
            }

            IconSimpleButton
            {
                id: buttonAdd
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                image: "qrc:/resources/img/icon_ok.png"

                onSigButtonClicked:
                {
                    show(false)
                    sigOk(filesListView.model[filesListView.currentIndex].fullPath)
                }
            }
        }
    }
}
