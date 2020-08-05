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
    id: page_AccountSett

    signal sigClosing()
    signal sigClosed()

    function showPage(vis)
    {
        showAccountSettAnimation.stop()

        if (vis === true)
            showAccountSettAnimation.to = 0
        else
            showAccountSettAnimation.to = page_AccountSett.height

        showAccountSettAnimation.start()
    }

    function setCurrentImage(img)
    {
        imgTankAvatar.addBase64ImageToList(img)
        imgAccount.source = "data:image/png;base64," + img
    }

    function moveToEdit(val)
    {
        animationToPage.stop()

        if (val === true)
        {
            animationToPage.from = 0
            animationToPage.to = flickView.height
        }
        else
        {
            animationToPage.from = flickView.height
            animationToPage.to = 0
        }

        animationToPage.start()
    }

    onVisibleChanged:
    {
        if (visible === true)
            imgUserAvatar.addBase64ImageToList(app.curUserAvatar)
    }

    NumberAnimation
    {
        id: showAccountSettAnimation
        target: rectContainer
        property: "anchors.topMargin"
        duration: 400
        easing.type: Easing.OutExpo
        onStarted: page_AccountSett.visible = true
        onFinished:
        {
            if (rectContainer.anchors.topMargin > 0 && page_AccountSett.visible === true)
            {
                page_AccountSett.visible = false
                sigClosed()
            }
        }
    }

    Rectangle
    {
        id: rectContainer
        anchors.top: parent.top
        anchors.topMargin: page_AccountSett.height
        anchors.left: parent.left
        anchors.right: parent.right
        height: page_AccountSett.height
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor
    }

    DropShadow
    {
        anchors.fill: rectContainer
        horizontalOffset: 0
        verticalOffset: -3
        radius: 10.0 * app.scale
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
            id: rectAccountInfo
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
                    verticalAlignment: Text.AlignBottom
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("ACCOUNT")
                }
            }

            Rectangle
            {
                id: rectAccountPhoto
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: AppTheme.margin * 2 * app.scale
                width: AppTheme.margin * 4 * app.scale
                height: width
                radius: width / 2
                border.width: 2 * app.scale
                border.color: AppTheme.blueColor
                color: AppTheme.backLightBlueColor

                Image
                {
                    id: imgAccount
                    anchors.fill: parent
                    anchors.margins: 1 * app.scale
                    source: "data:image/png;base64," + app.curUserAvatar
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

            DropShadow
            {
                anchors.fill: rectAccountPhoto
                horizontalOffset: 0
                verticalOffset: 0
                radius: 12.0
                samples: 16
                color: "#60000000"
                source: rectAccountPhoto
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
                text: app.curUserName
            }

            Text
            {
                id: textAccountEmail
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textAccountName.bottom
                height: AppTheme.compHeight * app.scale
                verticalAlignment: Text.AlignVCenter
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: app.curUserEmail
            }

            Text
            {
                id: textAccountDateCreate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textAccountEmail.bottom
                height: AppTheme.compHeight / 2 * app.scale
                verticalAlignment: Text.AlignTop
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: (new DateTimeUtils.DateTimeUtil()).printFullDate(app.curUserDateCreate)
            }

            Text
            {
                id: textLocation
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textAccountDateCreate.bottom
                height: AppTheme.compHeight / 2 * app.scale
                verticalAlignment: Text.AlignTop
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: app.global_USERREGION + " " + app.global_USERCOUNTRY + " " + app.global_USERCITY
            }

            Flickable
            {
                id: flickView
                anchors.top: parent.top
                anchors.topMargin: AppTheme.margin * 9 * app.scale
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.padding * app.scale
                contentWidth: width
                contentHeight: height * 2
                clip: true
                flickableDirection: Flickable.VerticalFlick
                interactive: false

                NumberAnimation on contentY
                {
                    id: animationToPage
                    from: 0
                    to: 0
                    duration: 500
                    easing.type: Easing.OutExpo
                    running: false
                }

                Rectangle
                {
                    id: rectEdit
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height / 2
                    color: "#00000000"

                    IconSmallSimpleButton
                    {
                        anchors.top: parent.top
                        anchors.topMargin: AppTheme.margin * app.scale
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: -AppTheme.margin * app.scale
                        image: "qrc:/resources/img/icon_edit.png"

                        onSigButtonClicked: moveToEdit(true)
                    }

                    IconSmallSimpleButton
                    {
                        anchors.top: parent.top
                        anchors.topMargin: AppTheme.margin * app.scale
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: AppTheme.margin * app.scale
                        image: "qrc:/resources/img/icon_cancel.png"

                        onSigButtonClicked: confirmDialog.showDialog(true,
                                                                     qsTr("Account delete"),
                                                                     qsTr("All data assosiated with current account will be deleted!"))
                    }

                    IconSimpleButton
                    {
                        id: buttonGoBack
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.margin * app.scale
                        image: "qrc:/resources/img/icon_arrow_down.png"
                        KeyNavigation.tab: textUserName

                        onSigButtonClicked:
                        {
                            page_AccountSett.showPage(false)
                            sigClosing()
                        }
                    }
                }

                Rectangle
                {
                    id: rectEditAccount
                    anchors.top: rectEdit.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: flickView.height
                    color: "#00000000"

                    Column
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        height: 300 * app.scale
                        width: parent.width
                        spacing: AppTheme.padding * app.scale

                        TextInput
                        {
                            id: textUserName
                            placeholderText: qsTr("User name")
                            width: parent.width
                            maximumLength: AppDefs.MAX_USERNAME_SIZE
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
                            maximumLength: AppDefs.MAX_EMAIL_SIZE
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
                            maximumLength: AppDefs.MAX_PASS_SIZE
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
                            id: imgUserAvatar
                            objectName: "imgUserAvatar"
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
                            moveToEdit(false)
                        }
                    }

                    IconSimpleButton
                    {
                        id: buttonCreate
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.margin * app.scale
                        image: "qrc:/resources/img/icon_ok.png"
                        KeyNavigation.tab: textUserName

                        onSigButtonClicked:
                        {
                            var imgLink = ""

                            if (imgUserAvatar.selectedImagesList.count > 0)
                            {
                                if (imgUserAvatar.selectedImagesList.get(0).fileLink !== "")
                                    imgLink = imgUserAvatar.selectedImagesList.get(0).fileLink
                                else
                                    imgLink = imgUserAvatar.selectedImagesList.get(0).base64data
                            }

                            app.sigEditAccount(textUserName.text,
                                               textUserPass.text,
                                               textUserEmail.text,
                                               imgLink)

                            showPage(false)
                            sigClosing()
                        }
                    }
                }
            }
        }
    }

    ConfirmDialog
    {
        id: confirmDialog
        onSigAccept:
        {
            page_AccountSett.showPage(false)
            sigClosing()
            app.sigDeleteAccount()
        }
    }
}
