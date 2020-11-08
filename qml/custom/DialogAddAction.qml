import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import "../custom"
import AppDefs 1.0

Item
{
    id: dialogAddAction
    width: app.width
    height: app.height

    property bool isEdit: false
    property int editId: 0

    function setActionParam(id, name, desc, repeatsInterval, period, dateTime)
    {
        editId = id
        textActionName.text = name
        textDesc.text = desc
        textPeriod.text = repeatsInterval
        comboPeriod.currentIndex = period
        datePicker.setLinuxDate(dateTime)
        timePicker.setLinuxTime(dateTime)
    }

    signal sigCancel()
    signal sigOk()

    function show(visible)
    {
        if (visible === true)
        {
            showDialogAnimation.start()
            rectFakeDataContainer.anchors.topMargin = AppTheme.padding * 5 * app.scale
        }
        else
        {
            rectFakeDataContainer.anchors.topMargin = rectContainer.height
            hideDialogAnimation.start()
        }
    }

    function setEdit(isEdit)
    {
        dialogAddAction.isEdit = isEdit
    }

    function addAction()
    {
        var dt = Math.round(new Date(datePicker.getLinuxDate() + " " + timePicker.getLinuxTime()).getTime()/1000)

        if (textActionName.text.length > 0 &&
            textDesc.text.length)
        {
            app.sigAddAction(textActionName.text, textDesc.text, comboPeriod.currentIndex, parseInt(textPeriod.text), dt)

            showActionDialog(false, false, 0)
        }
    }

    function editAction(id)
    {
        var dt = Math.round(new Date(datePicker.getLinuxDate() + " " + timePicker.getLinuxTime()).getTime()/1000)

        if (textActionName.text.length > 0 &&
            textDesc.text.length)
        {
            app.sigEditAction(id, textActionName.text, textDesc.text, comboPeriod.currentIndex, parseInt(textPeriod.text), dt)

            showActionDialog(false, false, 0)
        }
    }

    function deleteAction(id)
    {
        app.sigDeleteAction(id)
        showActionDialog(false, false, 0)
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

            Behavior on anchors.topMargin
            {
                NumberAnimation { duration: 200 }
            }
        }

        DropShadow
        {
            anchors.fill: rectFakeDataContainer
            horizontalOffset: 0
            verticalOffset: -AppTheme.shadowOffset * app.scale
            radius: AppTheme.shadowSize/2 * app.scale
            samples: AppTheme.shadowSamples * app.scale
            color: AppTheme.shadowColor
            source: rectFakeDataContainer
        }

        Rectangle
        {
            id: rectAddActionDialog
            anchors.fill: rectFakeDataContainer
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            color: "#00000020"

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
                color: AppTheme.blueFontColor
                text: (dialogAddAction.isEdit === true) ? qsTr("EDIT ACTION") : qsTr("ADD ACTION")
            }

            Rectangle
            {
                anchors.top: textHeader.bottom
                width: parent.width
                height: 1 * app.scale
                color: AppTheme.backLightBlueColor
            }

            Column
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: textHeader.bottom
                anchors.topMargin: AppTheme.margin * app.scale
                height: 400 * app.scale
                width: parent.width
                spacing: AppTheme.padding * app.scale

                TextInput
                {
                    id: textActionName
                    placeholderText: qsTr("Action name")
                    maximumLength: AppDefs.MAX_ACTIONNAME_SIZE
                    width: parent.width
                    focus: true
                    //KeyNavigation.tab: textUserEmail
                }

                TextInput
                {
                    id: textDesc
                    placeholderText: qsTr("Description")
                    maximumLength: AppDefs.MAX_ACTIONDESC_SIZE
                    width: parent.width
                    focus: true
                    //KeyNavigation.tab: textUserEmail
                }

                Rectangle
                {
                    width: parent.width
                    height: AppTheme.compHeight * app.scale
                    color: "#00000000"

                    Text
                    {
                        id: textRepeat
                        anchors.left: parent.left
                        height: parent.height
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSmallSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("Repeat: ")
                    }

                    TextInput
                    {
                        id: textPeriod
                        anchors.right: comboPeriod.left
                        anchors.rightMargin: AppTheme.padding * app.scale
                        placeholderText: qsTr("1")
                        validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                        width: 60 * app.scale
                        focus: true
                        maximumLength: 2
                        //KeyNavigation.tab: textUserEmail
                    }

                    ComboListQuick
                    {
                        id: comboPeriod
                        anchors.right: parent.right
                        propertyName: qsTr("Select a period:");
                        width: 100 * app.scale
                        model: periodslistModel

                        ListModel
                        {
                            id: periodslistModel
                            ListElement {   name: qsTr("Once")      }
                            ListElement {   name: qsTr("Days")     }
                            ListElement {   name: qsTr("Weeks")    }
                            ListElement {   name: qsTr("Months")   }
                        }

                        onCurrentIndexChanged:
                        {
                            if (comboPeriod.currentIndex > 0)
                            {
                                textPeriod.enabled = true
                                textPeriod.visible = true
                                textRepeat.text = qsTr("Repeat every:")
                            }
                            else
                            {
                                textPeriod.enabled = false
                                textPeriod.visible = false
                                textRepeat.text = qsTr("Repeat:")
                            }
                        }
                    }
                }

                Text
                {
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSmallSize * app.scale
                    color: AppTheme.greyColor
                    text: qsTr("Start Date/Time")
                }

                DatePicker
                {
                    id: datePicker
                    width: parent.width
                    title: qsTr("Select a start date:")
                }

                TimePicker
                {
                    id: timePicker
                    width: parent.width
                    title: qsTr("Select a start time:")
                }
            }

            IconSimpleButton
            {
                id: buttonCancel
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.left: parent.left
                image: "qrc:/resources/img/icon_cancel.png"

                onSigButtonClicked: showActionDialog(false, false, 0)
            }

            IconSimpleButton
            {
                id: buttonAdd
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                image: "qrc:/resources/img/icon_ok.png"

                onSigButtonClicked: dialogAddAction.isEdit ? editAction(dialogAddAction.editId) : addAction()
            }
        }
    }
}
