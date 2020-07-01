import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import "../custom"

Item
{
    id: dialogAddParamNote
    width: app.width
    height: app.height

    property alias addParamsListModel: addRecordListView.model
    property alias note: textNote.text
    property alias selectedImagesList: imagesList.selectedImagesList
    property bool isEdit: false

    signal sigCancel()
    signal sigOk()

    function show(visible)
    {
        if (visible === true)
        {
            showDialogAnimation.start()
            rectFakeDataContainer.anchors.topMargin = AppTheme.padding * 9 * app.scale
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
        color: "#20000000"
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
            radius: 10.0 * app.scale
            samples: 16
            color: "#20000000"
            source: rectFakeDataContainer
        }

        Rectangle
        {
            id: rectDataContainer
            anchors.fill: rectFakeDataContainer
            radius: AppTheme.radius * 2 * app.scale

            Rectangle
            {
                id: rectAddRecordDialog
                anchors.fill: parent
                anchors.topMargin: AppTheme.padding * app.scale
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.rightMargin: AppTheme.margin * app.scale
                color: AppTheme.whiteColor

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
                    anchors.bottomMargin: AppTheme.margin * 3 * app.scale
                    contentWidth: width
                    contentHeight: (addRecordListView.model) ? addRecordListView.model.length * AppTheme.rowHeightMin * app.scale + 300 * app.scale : 0
                    clip:true


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
                                text: (value !== -1) ? value : ""
                                //text: value

                                onTextChanged: value = Number.parseFloat(textInputValue.text)

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
                        placeholderText: qsTr("Add note")
                        width: parent.width
                        maximumLength: 256
                        //focus: false
                        //KeyNavigation.tab: textTankL
                    }

                    IconSimpleButton
                    {
                        id: buttonAddImage
                        anchors.top: textNote.bottom
                        anchors.topMargin: AppTheme.margin * app.scale
                        anchors.left: parent.left
                        image: "qrc:/resources/img/icon_plus.png"

                        onSigButtonClicked: dialogAddImage.show(true)
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
                        visible: false
                    }

                    DialogAddImage
                    {
                        id: dialogAddImage
                        visible: false
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
                        dialogAddParamNote.show(false)
                        sigOk()
                    }
                }
            }
        }
    }
}
