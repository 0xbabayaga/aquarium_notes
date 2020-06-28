import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import AppDefs 1.0
import ".."


Item
{
    id: tab_Action

    property var days: ["Monday", "Tuesday", "Wensday", "Thursday", "Friday", "Saturday", "Sunday"]
    property var months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


    function showActionDialog(visible, isEdit, id)
    {
        if (visible === true)
        {
            rectAddActionDialog.isEdit = isEdit

            if (isEdit === true)
            {
                rectAddActionDialog.editId = actionList.model[id].actId
                textActionName.text = actionList.model[id].name
                textDesc.text = actionList.model[id].desc
                textPeriod.text = actionList.model[id].period
                comboPeriod.currentIndex = actionList.model[id].type
                datePicker.setLinuxDate(actionList.model[id].startDT)
                timePicker.setLinuxTime(actionList.model[id].startDT)
            }
            else
            {
                textActionName.text = ""
                textDesc.text = ""
                textPeriod.text = "1"
                comboPeriod.currentIndex = 0
                datePicker.setLinuxDate(Date.now() / 1000 | 0)
                timePicker.setLinuxTime(Date.now() / 1000 | 0)
            }

            rectAddActionDialog.opacity = 1
            rectDataContainer.opacity = 0
        }
        else
        {
            rectAddActionDialog.opacity = 0
            rectDataContainer.opacity = 1
        }
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
            app.sigEditAction(id, textActionName.text, textDesc.text, 0, comboPeriod.currentIndex, dt)

            showActionDialog(false, false, 0)
        }
    }

    function deleteAction(id)
    {
        app.sigDeleteAction(id)
        showActionDialog(false, false, 0)
    }

    function printType(type, period)
    {
        switch (type)
        {
            case AppDefs.ActionRepeat_EveryDay:     return qsTr("(Every " + period + " days)");
            case AppDefs.ActionRepeat_EveryWeek:    return qsTr("(Every " + period + " weeks)");
            case AppDefs.ActionRepeat_EveryMonth:   return qsTr("(Every " + period + " months");
            default:                                return "(Once)"
        }
    }

    function printDay(tm)
    {
        var date = new Date(tm * 1000)
        return days[date.getDay()]
    }

    function printShortDate(tm)
    {
        var date = new Date(tm * 1000)
        return months[date.getMonth()] + " " + date.getDate()
    }

    Rectangle
    {
        id: rectDataContainer
        anchors.fill: parent
        anchors.leftMargin: AppTheme.padding * app.scale
        anchors.rightMargin: AppTheme.padding * app.scale
        color: "#00000000"

        property int dataWidth: 240 * app.scale

        Behavior on opacity
        {
            NumberAnimation {   duration: 200 }
        }

        Text
        {
            id: textViewPeriod
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            width: 100 * app.scale
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("View period:")
        }

        ListModel
        {
            id: viewPeriodListModel
            ListElement {   name: qsTr("Today");    idx:  AppDefs.ActionView_Today;       }
            ListElement {   name: qsTr("Week");     idx:  AppDefs.ActionView_ThisWeek;    }
            ListElement {   name: qsTr("Month");    idx:  AppDefs.ActionView_ThisMonth;   }
        }

        ComboList
        {
            id: comboViewPeriod
            anchors.top: textViewPeriod.top
            anchors.left: textViewPeriod.right
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            propertyName: qsTr("Select a period:");
            width: parent.width
            model: viewPeriodListModel
            currentIndex: 1

            onSigSelectedIndexChanged: sigActionViewPeriodChanged(comboViewPeriod.model.get(currentIndex).idx)
        }

        ListView
        {
            id: actionList
            anchors.top: parent.top
            anchors.topMargin: AppTheme.margin * 2 * app.scale
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * 2 * app.scale
            spacing: AppTheme.padding * app.scale
            model: actionsListModel

            delegate: Rectangle
            {
                width: parent.width
                height: (index === actionList.currentIndex) ? AppTheme.rowHeight * app.scale * 2 : AppTheme.rowHeight * app.scale
                color: AppTheme.backLightBlueColor

                Behavior on height
                {
                    NumberAnimation {   duration: 100 }
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: actionList.currentIndex = index
                }

                Rectangle
                {
                    anchors.fill: parent
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.rightMargin: AppTheme.padding * app.scale
                    color: "#00000000"

                    Column
                    {
                        id: columnMainInfo
                        anchors.top: parent.top
                        anchors.left: parent.left
                        height: AppTheme.compHeight * app.scale
                        width: rectDataContainer.dataWidth

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            verticalAlignment: Text.AlignBottom
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueColor
                            text: name
                        }

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            verticalAlignment: Text.AlignTop
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: printType(type, period)
                        }
                    }

                    Column
                    {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        height: AppTheme.compHeight * app.scale
                        width: parent.width - rectDataContainer.dataWidth

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            width: parent.width
                            verticalAlignment: Text.AlignBottom
                            horizontalAlignment: Text.AlignRight
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueColor
                            text: printDay(startDT)
                        }

                        Text
                        {
                            height: AppTheme.compHeight * app.scale
                            width: parent.width
                            verticalAlignment: Text.AlignTop
                            horizontalAlignment: Text.AlignRight
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: printShortDate(startDT)
                        }
                    }

                    Rectangle
                    {
                        anchors.left: parent.left
                        anchors.top: parent.verticalCenter
                        width: rectDataContainer.dataWidth
                        height: 1 * app.scale
                        color: AppTheme.backLightBlueColor
                        opacity: (index === actionList.currentIndex) ? 1 : 0

                        Behavior on opacity
                        {
                            NumberAnimation {   duration: 100   }
                        }

                        Text
                        {
                            anchors.top: parent.top
                            anchors.topMargin: AppTheme.padding/2 * app.scale
                            anchors.left: parent.left
                            width: rectDataContainer.dataWidth
                            height: AppTheme.compHeight * app.scale
                            verticalAlignment: Text.AlignTop
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontSmallSize * app.scale
                            color: AppTheme.greyColor
                            text: desc
                            wrapMode: Text.WordWrap
                        }
                    }

                    Rectangle
                    {
                        anchors.right: parent.right
                        anchors.rightMargin: -AppTheme.padding * app.scale
                        anchors.bottom: parent.bottom
                        //anchors.bottomMargin: AppTheme.padding * app.scale
                        width: AppTheme.compHeight * 2 * app.scale
                        height: AppTheme.compHeight * app.scale
                        color: "#00000000"
                        opacity: (index === actionList.currentIndex) ? 1 : 0

                        Behavior on opacity
                        {
                            NumberAnimation {   duration: 100   }
                        }

                        IconSmallSimpleButton
                        {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            onSigButtonClicked:
                            {
                                confirmDialog.setParam(actId)
                                confirmDialog.showDialog(true, qsTr("DELETING"), qsTr("Are you sure to delete item?"))
                            }
                        }

                        IconSmallSimpleButton
                        {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            image: "qrc:/resources/img/icon_edit.png"

                            onSigButtonClicked: showActionDialog(true, true, index)
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: actionList.parent
                anchors.top: actionList.top
                anchors.left: actionList.right
                //anchors.leftMargin: AppTheme.padding * app.scale
                anchors.bottom: actionList.bottom

                contentItem: Rectangle
                {
                    implicitWidth: 2 * app.scale
                    implicitHeight: 100
                    radius: width / 2
                    color: AppTheme.hideColor
                }
            }
        }

        Rectangle
        {
            anchors.fill: parent
            visible: (actionList.model.length === 0)
            color: "#00000000"

            Text
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: 250 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                wrapMode: Text.WordWrap
                color: AppTheme.greyColor
                text: qsTr("No action found for ") + viewPeriodListModel.get(comboViewPeriod.currentIndex).name
            }
        }

        IconSimpleButton
        {
            id: addRecordButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale

            onSigButtonClicked: showActionDialog(true, false, 0)
        }
    }

    Rectangle
    {
        id: rectAddActionDialog
        anchors.fill: parent
        anchors.leftMargin: AppTheme.padding * 2 * app.scale
        anchors.rightMargin: AppTheme.padding * 2 * app.scale
        color: "#00000020"
        opacity: 0
        visible: (opacity === 0) ? false : true

        property bool isEdit: false
        property int editId: -1

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
            text: qsTr("Add action:")
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
                width: parent.width
                focus: true
                //KeyNavigation.tab: textUserEmail
            }

            //Item { height: 1; width: 1;}

            TextInput
            {
                id: textDesc
                placeholderText: qsTr("Description")
                width: parent.width
                focus: true
                //KeyNavigation.tab: textUserEmail
            }

            //Item { height: 1; width: 1;}

            ListModel
            {
                id: periodslistModel
                ListElement {   name: qsTr("Once")      }
                ListElement {   name: qsTr("Days")     }
                ListElement {   name: qsTr("Weeks")    }
                ListElement {   name: qsTr("Months")   }
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
                    width: 60 * app.scale
                    focus: true
                    maximumLength: 2
                    //KeyNavigation.tab: textUserEmail
                }

                ComboList
                {
                    id: comboPeriod
                    anchors.right: parent.right
                    propertyName: qsTr("Select a period:");
                    width: 100 * app.scale
                    model: periodslistModel

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

            onSigButtonClicked: rectAddActionDialog.isEdit ? editAction(rectAddActionDialog.editId) : addAction()
        }
    }

    ConfirmDialog
    {
        id: confirmDialog
        onSigAccept: deleteAction(getParam())
    }
}
