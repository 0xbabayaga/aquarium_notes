import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import ".."

Item
{
    id: page_TankData
    visible: false
    width: app.width
    height: app.height

    ListModel
    {
        id: modelTabs
        ListElement { tab: qsTr("HISTORY") }
        ListElement { tab: qsTr("GRAPHS") }
        ListElement { tab: qsTr("ACTION") }
    }

    function showPage(vis, tankParams)
    {
        var tankName
        var tankDesc
        var tankType
        var tankVol
        var tankTypeName

        scaleAnimation.stop()

        if (tankParams !== 0)
        {
            tankName = tankParams[0]
            tankDesc = tankParams[1]
            tankType = tankParams[2]
            tankTypeName = tankParams[3]
            tankVol = Math.ceil(tankParams[4])
        }

        if (vis === true)
        {
            page_TankData.visible = true
            scaleAnimation.from = 0
            scaleAnimation.to = 1

            textTankVol.text = tankVol + "L"
            textTankName.text = tankName
            textTankName.color = (tankType < 4) ? AppTheme.blueColor : AppTheme.greenColor
            textTankVol.color = textTankName.color
            textTankType.text = "["+ tankTypeName +"]"
            //arrowOverlay.color = textTankName.color

            imgTank.source = "data:image/jpg;base64," + tankParams[5]
        }
        else
        {
            scaleAnimation.to = 0
            scaleAnimation.from = 1
        }

        scaleAnimation.start()
    }

    function savePersonalParams(isSave)
    {
        if (isSave === true)
        {
            for (var i = 0; i < personalParamsListView.model.length; i++)
            {
                app.sigPersonalParamStateChanged(personalParamsListView.model[i].paramId,
                                                 personalParamsListView.model[i].en)
            }
        }

        rectPersonalParamsDialog.opacity = 0
        rectAddRecordDialog.opacity = 1

        addRecordListView.model = app.getAllParamsListModel()
    }

    function addLogRecord(isAdd)
    {
        if (isAdd === true)
        {
            for (var i = 0; i < addRecordListView.model.length; i++)
            {
                if (addRecordListView.model[i].en === true &&
                    addRecordListView.model[i].value !== -1)
                {
                    app.sigAddRecord(app.lastSmpId,
                                     addRecordListView.model[i].paramId,
                                     addRecordListView.model[i].value)
                }
            }

            if (textNote.text.length > 0 || imagesList.getSelectedImageLink().length > 0)
                sigAddRecordNotes(app.lastSmpId,
                                  textNote.text,
                                  imagesList.getSelectedImageLink())

            app.lastSmpId++
        }

        rectAddRecordDialog.opacity = 0
        rectPersonalParamsDialog.opacity = 0
        rectDataContainer.opacity = 1
    }

    function getParamListRealCount()
    {
        var size = 0

        for (var i = 0; i < addRecordListView.model.length; i++)
            if (addRecordListView.model[i].en === true)
                size++;

        return size
    }

    ScaleAnimator
    {
        id: scaleAnimation
        target: page_TankData
        from: 0
        to: 1
        duration: 200
        running: false
        onFinished: if (to === 0) page_TankData.visible = false
    }

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
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
        anchors.fill: parent
        anchors.bottomMargin: AppTheme.rowHeightMin * app.scale
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor

        MouseArea   {   anchors.fill: parent    }

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
            id: rectHeaderContainer
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.top: parent.top
            height: AppTheme.rowHeight * app.scale
            color: "#00000000"

            IconSimpleButton
            {
                id: imgArrowBack
                anchors.left: parent.left
                anchors.verticalCenter: imgTank.verticalCenter
                height: AppTheme.compHeight * app.scale
                width: height
                image: "qrc:/resources/img/icon_arrow_left.png"

                onSigButtonClicked:
                {
                    addLogRecord(false)
                    showPage(false, "")
                }
            }

            Image
            {
                id: imgTank
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                width: height
                mipmap: true
                source: ""

                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: imgTankMask
                }
            }

            Rectangle
            {
                id: imgTankMask
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                width: height
                radius: height/2
                visible: false
            }

            Text
            {
                id: textTankName
                anchors.right: imgTank.left
                anchors.rightMargin: AppTheme.padding * app.scale
                anchors.verticalCenter: parent.verticalCenter
                height: AppTheme.compHeight * app.scale
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("Not defined")
            }

            Text
            {
                id: textTankVol
                anchors.top: textTankName.bottom
                anchors.right: imgTank.left
                anchors.rightMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("Not defined")
            }

            Text
            {
                id: textTankType
                anchors.top: textTankName.bottom
                anchors.right: textTankVol.left
                anchors.rightMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("Not defined")
            }
        }

        PagesTabList
        {
            id: pageTabsList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: AppTheme.rowHeightMin * 2 * app.scale
            model: modelTabs
        }


        Rectangle
        {
            id: rectDataContainer
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.topMargin: AppTheme.rowHeightMin * 3 * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
            color: "#00002000"

            Behavior on opacity
            {
                NumberAnimation {   duration: 200 }
            }

            CurrentParamsTable
            {
                id: paramsTable
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                model: curValuesListModel
                height: 300 * app.scale
            }

            Rectangle
            {
                anchors.fill: paramsTable
                visible: (curValuesListModel.length === 0)
                color: "#00000000"

                Text
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 250 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    wrapMode: Text.WordWrap
                    color: AppTheme.greyColor
                    text: qsTr("No record found for this aquarium")
                }
            }

            IconButton
            {
                id: addRecordButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale

                onSigButtonClicked:
                {
                    rectAddRecordDialog.opacity = 1
                    rectDataContainer.opacity = 0
                    addRecordListView.model = 0
                    addRecordListView.model = app.getAllParamsListModel()
                }
            }
        }

        Rectangle
        {
            id: rectAddRecordDialog
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            anchors.topMargin: AppTheme.rowHeight * 2 * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
            color: "#00000020"
            opacity: 0
            visible: (opacity === 0) ? false : true

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
                color: AppTheme.blueColor
                text: qsTr("Add record:")
            }

            UrlButton
            {
                id: buttonSetParams
                anchors.right: parent.right
                anchors.bottom: textHeader.bottom
                buttonText: "Edit params"
                width: 80 * app.scale

                onSigButtonClicked:
                {
                    rectAddRecordDialog.opacity = 0
                    rectPersonalParamsDialog.opacity = 1
                }
            }

            Flickable
            {
                id: flickableContainer
                anchors.fill: parent
                anchors.topMargin: AppTheme.compHeight * 2 * app.scale
                anchors.bottomMargin: AppTheme.rowHeightMin * 2 * app.scale
                contentWidth: width
                contentHeight: addRecordListView.model.length * AppTheme.rowHeightMin * app.scale
                clip: true

                ListView
                {
                    id: addRecordListView
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: model.length * AppTheme.rowHeightMin * app.scale
                    spacing: 0
                    model: app.getAllParamsListModel()
                    clip: true
                    interactive: false

                    onModelChanged:
                    {
                        height = getParamListRealCount() * AppTheme.rowHeightMin * app.scale
                        flickableContainer.contentHeight = addRecordListView.height
                        flickableContainer.contentHeight += AppTheme.rowHeightMin * 3 * app.scale
                    }

                    delegate: Rectangle
                    {
                        width: parent.width
                        height: (en === true) ? AppTheme.rowHeightMin * app.scale : 0
                        visible: en
                        color: "#00000000"

                        Behavior on height
                        {
                            NumberAnimation { duration: 200}
                        }

                        Text
                        {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            verticalAlignment: Text.AlignVCenter
                            width: 100 * app.scale
                            height: parent.height
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueColor
                            text: fullName
                        }

                        TextInput
                        {
                            id: textInputValue
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            placeholderText: "0"
                            width: 100 * app.scale
                            maximumLength: 4

                            onTextChanged: value = textInputValue.text

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.greyColor
                                text: unitName
                            }
                        }
                    }
                }

                TextInput
                {
                    id: textNote
                    anchors.top: addRecordListView.bottom
                    anchors.topMargin: AppTheme.padding * app.scale
                    placeholderText: qsTr("Add notes")
                    width: parent.width
                    maximumLength: 256
                    //focus: false
                    //KeyNavigation.tab: textTankL
                }

                ImageList
                {
                    id: imagesList
                    anchors.top: textNote.bottom
                    anchors.topMargin: AppTheme.margin * app.scale
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: parent.width
                    propertyName: qsTr("Attach a photo")
                    model: imageGalleryListModel
                }


                ScrollBar.vertical: ScrollBar
                {
                    policy: ScrollBar.AlwaysOn
                    parent: flickableContainer.parent
                    anchors.top: flickableContainer.top
                    anchors.left: flickableContainer.right
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.bottom: flickableContainer.bottom

                    contentItem: Rectangle
                    {
                        implicitWidth: 2 * app.scale
                        implicitHeight: 100 * app.scale
                        radius: width / 2
                        color: AppTheme.hideColor
                    }
                }
            }

            StandardButton
            {
                id: buttonCancel
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.left: parent.left
                bText: qsTr("CANCEL")

                onSigButtonClicked: addLogRecord(false)
            }

            StandardButton
            {
                id: buttonAdd
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                bText: qsTr("ADD")

                onSigButtonClicked: addLogRecord(true)
            }
        }


        Rectangle
        {
            id: rectPersonalParamsDialog
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            anchors.topMargin: AppTheme.rowHeight * 2 * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
            color: "#00000020"
            opacity: 0
            visible: (opacity === 0) ? false : true

            Behavior on opacity
            {
                NumberAnimation {   duration: 200 }
            }

            Text
            {
                id: textListOfParamsHeader
                anchors.top: parent.top
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
                width: 100 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("List of params:")
            }

            Text
            {
                anchors.top: textListOfParamsHeader.bottom
                anchors.topMargin: AppTheme.padding * app.scale
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
                width: 100 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("Please select a set of parameters for monitoring")
            }

            ListView
            {
                id: personalParamsListView
                anchors.fill: parent
                anchors.topMargin: AppTheme.compHeight * 2 * app.scale
                anchors.bottomMargin: AppTheme.rowHeight * 2 * app.scale
                spacing: 0
                model: app.getAllParamsListModel()
                clip: true

                delegate: Rectangle
                {
                    width: parent.width
                    height: AppTheme.rowHeightMin * app.scale
                    color: "#00000000"

                    Text
                    {
                        id: textFullName
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        verticalAlignment: Text.AlignVCenter
                        width: 100 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: en ? AppTheme.blueColor : AppTheme.greyColor
                        text: fullName
                    }

                    SwitchButton
                    {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: en
                        onCheckedChanged: {
                            en = checked
                            textFullName.color = en ? AppTheme.blueColor : AppTheme.greyColor
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar
                {
                    policy: ScrollBar.AlwaysOn
                    parent: personalParamsListView.parent
                    anchors.top: personalParamsListView.top
                    anchors.left: personalParamsListView.right
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.bottom: personalParamsListView.bottom

                    contentItem: Rectangle
                    {
                        implicitWidth: 2
                        implicitHeight: 100
                        radius: width / 2
                        color: AppTheme.hideColor
                    }
                }
            }

            StandardButton
            {
                id: buttonBack
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.left: parent.left
                bText: qsTr("CANCEL")

                onSigButtonClicked: savePersonalParams(false)
            }

            StandardButton
            {
                id: buttonSave
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                bText: qsTr("SAVE")

                onSigButtonClicked: savePersonalParams(true)
            }
        }
    }
}
