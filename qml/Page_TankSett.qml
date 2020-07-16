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
    id: page_TankSett

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
        imgUserAvatar.addBase64ImageToList(img)
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
        target: page_TankSett
        property: "opacity"
        from: 0
        to: 1
        onStarted: page_TankSett.visible = true
    }

    NumberAnimation
    {
        id: hidePageAnimation
        target: page_TankSett
        property: "opacity"
        from: 1
        to: 0
        onFinished: page_TankSett.visible = false
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
                id: rectTankInfo
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                height: flickView.height
                color: "#00000000"

                TanksList
                {
                    id: tanksList
                    anchors.top: parent.top
                    anchors.topMargin: AppTheme.rowHeightMin * app.scale * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    model: tanksListModel

                    onSigCurrentIndexChanged:
                    {
                        //textTankName.text = model[id].name
                        //app.sigTankSelected(currentIndex)
                    }
               }

                Text
                {
                    id: textTankName
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: tanksList.bottom
                    anchors.topMargin: AppTheme.margin * 3 * app.scale
                    height: AppTheme.compHeight * app.scale
                    verticalAlignment: Text.AlignBottom
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: tanksListModel[tanksList.currentIndex].name
                }

                Column
                {
                    anchors.top: textTankName.bottom
                    anchors.topMargin: AppTheme.margin * app.scale
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 300 * app.scale

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.verticalCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Aquarium type: ")
                        }

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.verticalCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: tanksListModel[tanksList.currentIndex].typeName
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.right
                            verticalAlignment: Text.verticalCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Date create: ")
                        }

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.left
                            verticalAlignment: Text.verticalCenter
                            height: AppTheme.compHeight / 2 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (new DateTimeUtils.DateTimeUtil()).printFullDate(tanksListModel[tanksList.currentIndex].dtCreate)
                        }
                    }


                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Length: ")
                        }

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            height: AppTheme.compHeight / 2 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: tanksListModel[tanksList.currentIndex]._l
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Height: ")
                        }

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            height: AppTheme.compHeight / 2 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: tanksListModel[tanksList.currentIndex]._h
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Width: ")
                        }

                        Text
                        {
                            width: parent / 2
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            height: AppTheme.compHeight / 2 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: tanksListModel[tanksList.currentIndex]._w
                        }
                    }
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
                anchors.top: rectTankInfo.bottom
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                height: flickView.height
                color: "#00000000"

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
                        /*
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
                        */

                        showPage(false)
                        sigClose()
                    }
                }
            }
        }
    }
}
