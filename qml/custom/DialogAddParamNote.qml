import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import "../custom"
import AppDefs 1.0

Item
{
    id: dialogAddParamNote
    width: app.width
    height: app.height

    property alias addParamsListModel: addRecordListView.model
    property alias selectedImagesList: imagesList.selectedImagesList
    property alias note: textNote.text
    property bool isEdit: false

    signal sigCancel()
    signal sigOk()

    function show(visible)
    {
        if (visible === true)
        {
            showDialogAnimation.start()
            rectFakeDataContainer.anchors.topMargin = AppTheme.padding * 5 * app.scale
            imagesList.reset()
        }
        else
        {
            rectFakeDataContainer.anchors.topMargin = rectContainer.height
            hideDialogAnimation.start()
        }
    }

    function setEdit(isEdit)
    {
        dialogAddParamNote.isEdit = isEdit
    }

    function savePersonalParams(isSave)
    {
        var en = false

        if (isSave === true)
        {
            var i

            for (i = 0; i < personalParamsListView.model.length; i++)
            {
                if (personalParamsListView.model[i].en === true)
                {
                    en = true
                    break
                }
            }

            if (en === true)
            {
                for (i = 0; i < personalParamsListView.model.length; i++)
                {
                    app.sigPersonalParamStateChanged(personalParamsListView.model[i].paramId,
                                                     personalParamsListView.model[i].en)
                }

                rectPersonalParamsDialog.opacity = 0
                rectAddRecordDialog.opacity = 1

                if (isSave === true)
                    app.sigFullRefreshData()

                dialogAddParamNote.addParamsListModel = app.getAllParamsListModel()
            }
            else
            {
                warningDialog.showDialog(true, qsTr("Warning"), qsTr("At least one parameter must be enabled!"))
            }
        }
        else
        {
            rectPersonalParamsDialog.opacity = 0
            rectAddRecordDialog.opacity = 1

            app.sigFullRefreshData()

            dialogAddParamNote.addParamsListModel = app.getAllParamsListModel()
        }
    }

    function verifyInputParams()
    {
        for (var i = 0; i < dialogAddParamNote.addParamsListModel.length; i++)
        {
            if (dialogAddParamNote.addParamsListModel[i].en === true &&
                dialogAddParamNote.addParamsListModel[i].value === -1)
            {
                return false
            }
        }

        return true
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
            radius: AppTheme.radius * 2 * app.scale

            Behavior on anchors.topMargin
            {
                NumberAnimation { duration: 200 }
            }
        }

        DropShadow
        {
            anchors.fill: rectFakeDataContainer
            horizontalOffset: 0
            verticalOffset: -3
            radius: AppTheme.shadowSize * app.scale
            samples: AppTheme.shadowSamples
            color: AppTheme.shadowColor
            source: rectFakeDataContainer
        }

        Rectangle
        {
            id: rectDataContainer
            anchors.fill: rectFakeDataContainer

            Rectangle
            {
                id: rectAddRecordDialog
                anchors.fill: parent
                anchors.topMargin: AppTheme.padding * app.scale
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.rightMargin: AppTheme.margin * app.scale
                color: AppTheme.whiteColor

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
                    text: (dialogAddParamNote.isEdit === true) ? qsTr("EDIT RECORD") : qsTr("ADD RECORD")
                }

                Rectangle
                {
                    anchors.top: textHeader.bottom
                    width: parent.width
                    height: 1 * app.scale
                    color: AppTheme.backLightBlueColor
                }

                IconSmallSimpleButton
                {
                    anchors.right: parent.right
                    anchors.verticalCenter: textHeader.verticalCenter
                    image: "qrc:/resources/img/icon_mon2.png"

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
                    anchors.bottomMargin: AppTheme.margin * 3 * app.scale
                    contentWidth: width
                    clip:true

                    Behavior on contentHeight
                    {
                        NumberAnimation {   duration: 200   }
                    }

                    ListView
                    {
                        id: addRecordListView
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: (model) ? model.length * AppTheme.rowHeightMin * app.scale : 0
                        spacing: 0
                        model: app.getAllParamsListModel()
                        clip: true
                        interactive: false

                        onModelChanged:
                        {
                            height = getParamListRealCount() * AppTheme.rowHeightMin * app.scale
                            flickableContainer.contentHeight = addRecordListView.height + AppTheme.rowHeightMin * 8 * app.scale
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
                                color: AppTheme.blueFontColor
                                text: fullName
                            }

                            TextInput
                            {
                                id: textInputValue
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                placeholderText: "0"
                                width: 100 * app.scale
                                maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
                                text: (value !== -1) ? value : ""
                                validator : RegExpValidator { regExp : /[0-9]+\.[0-9]+/ }

                                onTextChanged: value = Number.parseFloat(textInputValue.text)
                                Keys.onReturnPressed:  nextItemInFocusChain().forceActiveFocus()
                                //KeyNavigation.tab: bottomRight

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

                    Column
                    {
                        anchors.top: addRecordListView.bottom
                        anchors.topMargin: AppTheme.padding * app.scale
                        width: parent.width
                        height: 580 * app.scale
                        spacing: AppTheme.padding * app.scale

                        TextInput
                        {
                            id: textNote
                            placeholderText: qsTr("Add note")
                            width: parent.width
                            height: AppTheme.compHeight * app.scale
                            maximumLength: 256
                            //focus: false
                            //KeyNavigation.tab: textTankL
                        }

                        Text
                        {
                            id: textAddImage
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width
                            height: AppTheme.compHeight * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueFontColor
                            text: qsTr("Add image")
                        }

                        ImageList
                        {
                            id: imagesList
                            objectName: "imageList"
                            imagesCountMax: (app.isFullFunctionality() === true) ? AppDefs.NOTE_IMAGES_COUNT_FULL_LIMIT : AppDefs.NOTE_IMAGES_COUNT_LIMIT

                            onSigImagesLimitReached:
                            {
                                if (app.isFullFunctionality() === true &&
                                    imagesList.selectedImagesList.count === AppDefs.NOTE_IMAGES_COUNT_FULL_LIMIT)
                                {
                                   tip.tipText = qsTr("You can only add ") + AppDefs.NOTE_IMAGES_COUNT_FULL_LIMIT + qsTr(" images.")
                                }
                                else
                                    tip.tipText = qsTr("You cannot add more than ") + AppDefs.NOTE_IMAGES_COUNT_LIMIT + qsTr(" image.") + qsTr("\nLimitation of non-registered version.")

                                tip.show(true)
                            }
                        }
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

                IconSimpleButton
                {
                    id: buttonCancel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.left: parent.left
                    image: "qrc:/resources/img/icon_cancel.png"

                    onSigButtonClicked:
                    {
                        dialogAddParamNote.show(false)
                        sigCancel()
                    }
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
                        if (verifyInputParams() === true)
                        {
                            dialogAddParamNote.show(false)
                            sigOk()
                        }
                        else
                            warningDialog.showDialog(true, qsTr("Warning"), qsTr("Please fill in each of the parameters"))
                    }
                }
            }

            Tips
            {
                id: tip
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.rowHeight * 2 * app.scale
                visible: false
                tipText: qsTr("")
            }


            Rectangle
            {
                id: rectPersonalParamsDialog
                anchors.fill: parent
                anchors.topMargin: AppTheme.padding * app.scale
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.rightMargin: AppTheme.margin * app.scale
                color: AppTheme.whiteColor
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
                    height: AppTheme.rowHeightMin * app.scale
                    width: 100 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("LIST OF PARAMS")
                }

                Rectangle
                {
                    anchors.top: textListOfParamsHeader.bottom
                    width: parent.width
                    height: 1 * app.scale
                    color: AppTheme.backLightBlueColor
                }

                Text
                {
                    anchors.top: textListOfParamsHeader.bottom
                    anchors.topMargin: AppTheme.padding * app.scale
                    anchors.left: parent.left
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSmallSize * app.scale
                    color: AppTheme.greyColor
                    wrapMode: Text.WordWrap
                    text: qsTr("Select a set of parameters for monitoring")
                }

                ListView
                {
                    id: personalParamsListView
                    anchors.fill: parent
                    anchors.topMargin: AppTheme.compHeight * 3 * app.scale
                    anchors.bottomMargin: AppTheme.rowHeight * 2 * app.scale
                    spacing: 0
                    clip: true
                    model: app.getAllParamsListModel()

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
                            color: en ? AppTheme.blueFontColor : AppTheme.greyColor
                            text: fullName
                        }

                        CheckBoxButton
                        {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: en
                            onCheckedChanged:
                            {
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

                IconSimpleButton
                {
                    id: buttonBack
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.left: parent.left
                    image: "qrc:/resources/img/icon_cancel.png"

                    onSigButtonClicked: savePersonalParams(false)
                }

                IconSimpleButton
                {
                    id: buttonSave
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.right: parent.right
                    image: "qrc:/resources/img/icon_ok.png"

                    onSigButtonClicked: savePersonalParams(true)
                }
            }
        }

        WaitDialog
        {
            id: warningDialog

        }
    }
}
