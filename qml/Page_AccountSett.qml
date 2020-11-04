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
        imgAccount.source = "data:image/jpg;base64," + img
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
        target: rectContainerShadow
        property: "anchors.topMargin"
        duration: 200
        easing.type: Easing.OutCubic
        onStarted: page_AccountSett.visible = true
        onFinished:
        {
            if (rectContainerShadow.anchors.topMargin > 0 && page_AccountSett.visible === true)
            {
                page_AccountSett.visible = false
                sigClosed()
            }
        }
    }

    Rectangle
    {
        id: rectContainerShadow
        anchors.top: parent.top
        anchors.topMargin: page_AppSett.height
        anchors.left: parent.left
        anchors.right: parent.right
        height: page_AppSett.height
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
        id: rectRealContainer
        anchors.fill: rectContainerShadow
        color: "#00000000"

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
            id: rectAccountInfo
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
                text: qsTr("ACCOUNT")
            }

            Rectangle
            {
                id: rectAccountPhoto
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * 5 * app.scale
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
                radius: AppTheme.shadowSize * app.scale
                samples: AppTheme.shadowSamples * app.scale
                color: AppTheme.shideColor
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
                id: textAccountDateCreate
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textAccountName.bottom
                anchors.topMargin: AppTheme.padding/2 * app.scale
                height: AppTheme.compHeight / 2 * app.scale
                verticalAlignment: Text.AlignVCenter
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("Since") + " " + (new DateTimeUtils.DateTimeUtil()).printFullDate(app.curUserDateCreate)
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
                            //KeyNavigation.tab: textUserPass
                        }

                        Item { height: 1; width: 1;}

                        /*
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
                        */

                        Text
                        {
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueFontColor
                            text: qsTr("User photo")
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
                                               "" /* textUserPass.text */,
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
