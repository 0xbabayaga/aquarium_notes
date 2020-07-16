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
        {
            moveToEdit(false)
            hidePageAnimation.start()
        }
    }

    function setCurrentImage(img)
    {
        imgTankAvatar.addBase64ImageToList(img)
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
            imgTankAvatar.addBase64ImageToList(tanksListModel[tanksList.currentIndex].img)
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

                        imgTankAvatar.addBase64ImageToList(tanksListModel[tanksList.currentIndex].img)
                    }
                }

                Text
                {
                    id: txtTankName
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: tanksList.bottom
                    anchors.topMargin: AppTheme.margin * 3 * app.scale
                    height: AppTheme.compHeight * app.scale
                    verticalAlignment: Text.AlignBottom
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].name : ""
                }

                Column
                {
                    anchors.top: txtTankName.bottom
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
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Aquarium type: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].typeName : ""
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Date create: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? (new DateTimeUtils.DateTimeUtil()).printFullDate(tanksListModel[tanksList.currentIndex].dtCreate) : ""
                        }
                    }


                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Length: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].l + qsTr("cm") : ""
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Height: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].h + qsTr("cm") : ""
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Width: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].w + qsTr("cm") : ""
                        }
                    }

                    Row
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: qsTr("Volume: ")
                        }

                        Text
                        {
                            width: parent.width / 2
                            height: parent.height
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: (tanksListModel.length > 0) ? Math.round(tanksListModel[tanksList.currentIndex].volume / 10) * 10 + qsTr("L") : ""
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
                    //KeyNavigation.tab: textUserName

                    onSigButtonClicked: moveToEdit(true)
                }
            }

            Rectangle
            {
                id: rectEditTank
                anchors.top: rectTankInfo.bottom
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
                    anchors.verticalCenterOffset: 32 * app.scale
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
                        text: qsTr("Edit tank profile")
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textTankName
                        placeholderText: qsTr("Tank name")
                        width: parent.width
                        focus: false
                        text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].name : ""
                        KeyNavigation.tab: textTankL
                    }

                    Item { height: 1; width: 1;}

                    Rectangle
                    {
                        id: rectRow
                        width: parent.width
                        height: AppTheme.compHeight * app.scale
                        color: "#00000000"

                        property int unitWidth: 20 * app.scale

                        TextInput
                        {
                            id: textTankL
                            anchors.left: parent.left
                            placeholderText: qsTr("100")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].l : ""
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: textTankW

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }

                        TextInput
                        {
                            id: textTankW
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].w : ""
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: textTankH

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }

                        TextInput
                        {
                            id: textTankH
                            anchors.right: parent.right
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].h : ""
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: comboTankType

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }
                    }

                    Item { height: 1; width: 1;}

                    ComboList
                    {
                        id: comboTankType
                        propertyName: qsTr("Select a tank type:");
                        width: parent.width
                        model: aquariumTypesListModel
                        currentIndex: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].type : ""
                        //KeyNavigation.tab: textFileName
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
                    image: "qrc:/resources/img/icon_ok.png"
                    //KeyNavigation.tab: textUserName

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
