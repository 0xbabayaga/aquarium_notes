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

    property bool isEdit: true

    signal sigClosing()
    signal sigClosed()

    function showPage(vis)
    {
        showPageAnimation.stop()

        if (vis === true)
            showPageAnimation.to = 0
        else
            showPageAnimation.to = page_TankSett.height

        showPageAnimation.start()
    }

    function setCurrentImage(img)
    {
        imgTankAvatar.addBase64ImageToList(img)
    }

    function moveToEdit(val)
    {
        animationToPage.stop()

        isEdit = true

        if (val === true)
        {
            animationToPage.from = 0
            animationToPage.to = flickView.height
            textHeader.text = qsTr("TANKS") + qsTr(" :: EDIT")
        }
        else
        {
            animationToPage.from = flickView.height
            animationToPage.to = 0
            textHeader.text = qsTr("TANKS")
        }

        animationToPage.start()
    }

    function moveToAddNewTank(val)
    {
        animationToPage.stop()

        isEdit = false

        if (val === true)
        {
            animationToPage.from = 0
            animationToPage.to = flickView.height

            textTankName.text = ""
            textTankDesc.text = ""
            textTankL.text = ""
            textTankH.text = ""
            textTankW.text = ""
            imgTankAvatar.reset()

            textHeader.text = qsTr("TANKS") + qsTr(" :: ADD NEW")
        }
        else
        {
            animationToPage.from = flickView.height
            animationToPage.to = 0
            textHeader.text = qsTr("TANKS")
        }

        animationToPage.start()
    }

    function checkAndCreate()
    {
        var imgLink = ""

        if (imgTankAvatar.selectedImagesList.count > 0)
        {
            if (imgTankAvatar.selectedImagesList.get(0).fileLink !== "")
                imgLink = imgTankAvatar.selectedImagesList.get(0).fileLink
            else
                imgLink = imgTankAvatar.selectedImagesList.get(0).base64data
        }

        if (textTankName.text.length > 0 &&
            textTankH.text.length > 0 &&
            textTankL.text.length > 0 &&
            textTankW.text.length > 0)
        {
            if (page_TankSett.isEdit === true)
            {
                app.sigEditTank(textTankName.text,
                                textTankDesc.text,
                                comboTankType.currentIndex,
                                parseInt(textTankL.text),
                                parseInt(textTankW.text),
                                parseInt(textTankH.text),
                                imgLink)
            }
            else
            {
                app.sigCreateTank(textTankName.text,
                                  textTankDesc.text,
                                  comboTankType.currentIndex,
                                  parseInt(textTankL.text),
                                  parseInt(textTankW.text),
                                  parseInt(textTankH.text),
                                  imgLink)
            }

            moveToEdit(false)
        }
        //else
    }

    onVisibleChanged:
    {
        if (visible === true)
            imgTankAvatar.addBase64ImageToList(tanksListModel[tanksList.currentIndex].img)
    }

    NumberAnimation
    {
        id: showPageAnimation
        target: rectContainer
        property: "anchors.topMargin"
        duration: 400
        easing.type: Easing.OutBack
        onStarted: page_TankSett.visible = true
        onFinished:
        {
            if (rectContainer.anchors.topMargin > 0 && page_TankSett.visible === true)
            {
                page_TankSett.visible = false
                sigClosed()
            }
        }
    }

    Rectangle
    {
        id: rectContainer
        anchors.top: parent.top
        anchors.topMargin: page_TankSett.height
        anchors.left: parent.left
        anchors.right: parent.right
        height: page_TankSett.height
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
            id: rectTankInfo
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.rightMargin: AppTheme.padding * app.scale
            color: "#00000000"

            TanksList
            {
                id: tanksList
                anchors.top: parent.top
                anchors.topMargin: AppTheme.rowHeightMin * app.scale
                anchors.horizontalCenter: parent.horizontalCenter
                model: tanksListModel
                visible: isEdit === true

                onSigCurrentIndexChanged:
                {
                    imgTankAvatar.addBase64ImageToList(tanksListModel[tanksList.currentIndex].img)
                }
            }

            Rectangle
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: AppTheme.rowHeight * app.scale
                color: "#00000000"

                Image
                {
                    id: imgApp
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    width: 20 * app.scale
                    height: 20 * app.scale
                    source: "qrc:/resources/img/icon_app.png"
                    mipmap: true
                }

                ColorOverlay
                {
                    anchors.fill: imgApp
                    source: imgApp
                    color: AppTheme.blueColor
                }

                Text
                {
                    id: textHeader
                    anchors.verticalCenter: imgApp.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    verticalAlignment: Text.AlignBottom
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("TANKS")
                }
            }

            Flickable
            {
                id: flickView
                anchors.top: parent.top
                anchors.topMargin: AppTheme.margin * 7 * app.scale
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
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
                    id: rectTankData
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

                        Row
                        {
                            width: parent.width
                            height: AppTheme.compHeight * app.scale

                            Text
                            {
                                id: txtTankName
                                verticalAlignment: Text.AlignBottom
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBigSize * app.scale
                                color: AppTheme.blueColor
                                text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].name : ""
                                visible: isEdit === true
                            }
                        }

                        Row
                        {
                            width: parent.width
                            height: AppTheme.compHeight * app.scale

                            Text
                            {
                                id: txtTankDesc
                                verticalAlignment: Text.AlignBottom
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontSmallSize * app.scale
                                color: AppTheme.greyColor
                                text: (tanksListModel.length > 0) ? "(" + tanksListModel[tanksList.currentIndex].desc + ")" : "()" + qsTr("No desciption") + ")"
                                wrapMode: Text.WordWrap
                                visible: isEdit === true
                            }
                        }

                        Item { height: AppTheme.padding * app.scale; width: 1;}

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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Aquarium type:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Date create:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Length:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Height:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Width:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
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
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: qsTr("Volume:") + " "
                            }

                            Text
                            {
                                width: parent.width / 2
                                height: parent.height
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: (tanksListModel.length > 0) ? Math.round(tanksListModel[tanksList.currentIndex].volume / 10) * 10 + qsTr("L") : ""
                            }
                        }

                        Item { width: 1; height: AppTheme.padding * app.scale }

                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: (AppTheme.compHeight * 3 + AppTheme.margin * 2) * app.scale
                            height: AppTheme.compHeight * app.scale
                            spacing: AppTheme.margin * app.scale

                            IconSmallSimpleButton
                            {
                                image: "qrc:/resources/img/icon_plus.png"

                                onSigButtonClicked: moveToAddNewTank(true)
                            }

                            IconSmallSimpleButton
                            {
                                image: "qrc:/resources/img/icon_edit.png"

                                onSigButtonClicked: moveToEdit(true)
                            }

                            IconSmallSimpleButton
                            {
                                image: "qrc:/resources/img/icon_cancel.png"

                                onSigButtonClicked: confirmDialog.showDialog(true,
                                                                             qsTr("Tank profile delete"),
                                                                             qsTr("All data assosiated with current aquarium will be deleted!"))
                            }
                        }
                    }

                    IconSimpleButton
                    {
                        id: buttonEdit
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

                Rectangle
                {
                    id: rectAddEditTank
                    anchors.top: rectTankData.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.right: parent.right
                    anchors.rightMargin: AppTheme.padding * app.scale
                    height: flickView.height
                    color: "#00000000"

                    Column
                    {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 300 * app.scale
                        width: parent.width
                        spacing: AppTheme.padding * app.scale

                        TextInput
                        {
                            id: textTankName
                            placeholderText: qsTr("Tank name")
                            width: parent.width
                            maximumLength: AppDefs.MAX_TANKNAME_SIZE
                            focus: false
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].name : ""
                            KeyNavigation.tab: textTankDesc
                        }

                        Item { height: 1; width: 1;}

                        TextInput
                        {
                            id: textTankDesc
                            placeholderText: qsTr("Tank description")
                            width: parent.width
                            maximumLength: AppDefs.MAX_TANKDESC_SIZE
                            focus: false
                            text: (tanksListModel.length > 0) ? tanksListModel[tanksList.currentIndex].desc : ""
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
                                maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
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
                                maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
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
                                maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
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
                            moveToEdit(false)
                            sigClosing()
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

                        onSigButtonClicked: checkAndCreate()
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
            app.sigDeleteTank(tanksList.model[tanksList.currentIndex].tankId)
        }
    }
}
