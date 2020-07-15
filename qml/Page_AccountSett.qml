import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import "custom"
import AppDefs 1.0

Item
{
    id: page_AccountSett

    signal sigClose()

    function showPage(vis)
    {
        if (vis === true)
            showPageAnimation.start()
        else
            hidePageAnimation.start()
    }

    NumberAnimation
    {
        id: showPageAnimation
        target: page_AccountSett
        property: "opacity"
        from: 0
        to: 1
        onStarted: page_AccountSett.visible = true
    }

    NumberAnimation
    {
        id: hidePageAnimation
        target: page_AccountSett
        property: "opacity"
        from: 1
        to: 0
        onFinished: page_AccountSett.visible = false
    }


    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectCreateAccount
            anchors.fill: parent
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.margin * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.margin * app.scale
            color: "#00000000"

            Column
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 60 * app.scale
                height: 300 * app.scale
                width: parent.width
                spacing: AppTheme.padding * app.scale

                Text
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: AppTheme.compHeight * app.scale
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("Edit account")
                }

                Item { height: 1; width: 1;}

                TextInput
                {
                    id: textUserName
                    placeholderText: qsTr("User name")
                    width: parent.width
                    maximumLength: AppTheme.textMaxLength32
                    focus: true
                    text: app.curUserName
                    KeyNavigation.tab: textUserEmail
                }

                Item { height: 1; width: 1;}

                TextInput
                {
                    id: textUserEmail
                    placeholderText: qsTr("User email")
                    width: parent.width
                    maximumLength: AppTheme.textMaxLength64
                    focus: true
                    text: app.curUserEmail
                    KeyNavigation.tab: textUserPass
                }

                Item { height: 1; width: 1;}

                TextInput
                {
                    id: textUserPass
                    placeholderText: qsTr("User password")
                    width: parent.width
                    maximumLength: AppTheme.textMaxLength16
                    focus: true
                    KeyNavigation.tab: buttonCancel
                }

                Item { height: 1; width: 1;}

                Text
                {
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("Tank image")
                }

                ImageList
                {
                    id: imgTankAvatar
                    imagesCountMax: 1
                }
            }

            IconSimpleButton
            {
                id: buttonCancel
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                image: "qrc:/resources/img/icon_cancel.png"
                KeyNavigation.tab: buttonCreate

                onSigButtonClicked:
                {
                    showPage(false)
                    sigClose()
                }
            }

            IconSimpleButton
            {
                id: buttonCreate
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                KeyNavigation.tab: textUserName

                onSigButtonClicked:
                {
                    var imgLink = ""

                    if (imgTankAvatar.selectedImagesList.count > 0)
                        imgLink = imgTankAvatar.selectedImagesList.get(0).fileLink

                    app.sigEditAccount(textUserName.text,
                                       textUserPass.text,
                                       textUserEmail.text,
                                       imgLink)

                    showPage(false)
                    sigClose()
                }
            }
        }
    }
}
