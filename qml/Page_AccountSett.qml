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

    signal sigClose()

    function showPage(vis)
    {
        if (vis === true)
            showPageAnimation.start()
        else
            hidePageAnimation.start()
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

        Flickable
        {
            id: flickView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            contentWidth: width
            contentHeight: app.height * 2

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
                id: rectAccountInfo
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                height: flickView.height
                color: "#00000000"

                Rectangle
                {
                    id: rectAccountPhoto
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: AppTheme.margin * 3 * app.scale
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
                        anchors.margins: 2 * app.scale
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
                    radius: 8.0
                    samples: 16
                    color: "#60000000"
                    source: rectAccountPhoto
                }

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
                    text: app.curUserName
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

                IconSimpleButton
                {
                    id: buttonEdit
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    image: "qrc:/resources/img/icon_edit.png"
                    KeyNavigation.tab: textUserName

                    onSigButtonClicked: moveToEdit(true)
                }
            }

            Rectangle
            {
                id: rectCreateAccount
                anchors.top: rectAccountInfo.bottom
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                height: flickView.height
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
                    image: "qrc:/resources/img/icon_ok.png"
                    KeyNavigation.tab: textUserName

                    onSigButtonClicked:
                    {
                        var imgLink = ""

                        if (imgUserAvatar.selectedImagesList.count > 0)
                        {
                            if (imgUserAvatar.selectedImagesList.get(0).fileLink !== 0)
                                imgLink = imgUserAvatar.selectedImagesList.get(0).fileLink
                            else
                                imgLink = imgUserAvatar.selectedImagesList.get(0).base64data
                        }

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
}
