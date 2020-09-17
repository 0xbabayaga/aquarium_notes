import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtMultimedia 5.11
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
            dialogAddAction.setEdit(isEdit)

            if (isEdit === true)
            {
                dialogAddAction.setActionParam(actionList.model[id].actId,
                                               actionList.model[id].name,
                                               actionList.model[id].desc,
                                               actionList.model[id].period,
                                               actionList.model[id].type,
                                               actionList.model[id].startDT)
            }
            else
            {
                dialogAddAction.setActionParam(0,
                                               "",
                                               "",
                                               "1",
                                               0,
                                               Date.now() / 1000 | 0)

            }
        }

        dialogAddAction.show(visible)
    }

    function printType(type, period)
    {
        switch (type)
        {
            case AppDefs.ActionRepeat_EveryDay:     return qsTr("[Every " + period + " days]");
            case AppDefs.ActionRepeat_EveryWeek:    return qsTr("[Every " + period + " weeks]");
            case AppDefs.ActionRepeat_EveryMonth:   return qsTr("[Every " + period + " months]");
            default:                                return "[Once]"
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

    function printTime(tm)
    {
        var date = new Date(tm * 1000)
        var hh = "0" + date.getHours()
        var mm = "0" + date.getMinutes()

        return hh.substr(-2)+":"+mm.substr(-2)
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
            //anchors.leftMargin: AppTheme.padding * app.scale
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            width: 100 * app.scale
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueFontColor
            text: qsTr("View period:")
        }

        ComboListQuick
        {
            id: comboViewPeriod
            anchors.top: textViewPeriod.top
            anchors.left: textViewPeriod.right
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            propertyName: qsTr("Select a period:");
            width: parent.width
            model: viewPeriodListModel

            ListModel
            {
                id: viewPeriodListModel
                ListElement {   name: qsTr("Today");    idx:  AppDefs.ActionView_Today;       }
                ListElement {   name: qsTr("Week");     idx:  AppDefs.ActionView_ThisWeek;    }
                ListElement {   name: qsTr("Month");    idx:  AppDefs.ActionView_ThisMonth;   }
            }

            onSigSelectedIndexChanged:
            {
                if (comboViewPeriod.model)
                    sigActionViewPeriodChanged(comboViewPeriod.model.get(currentIndex).idx)
            }
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
                color: AppTheme.whiteColor

                Behavior on height
                {
                    NumberAnimation {   duration: 100 }
                }

                Rectangle
                {
                    id: rectHeaderShadow
                    anchors.fill: parent
                    color: AppTheme.whiteColor
                }

                DropShadow
                {
                    anchors.fill: rectHeaderShadow
                    horizontalOffset: 0
                    verticalOffset: AppTheme.shadowOffset * app.scale
                    radius: AppTheme.shadowSize * app.scale
                    samples: AppTheme.shadowSamples * app.scale
                    color: AppTheme.shadowColor
                    source: rectHeaderShadow
                }

                Rectangle
                {
                    anchors.fill: rectHeaderShadow
                    color: (index === actionList.currentIndex) ? AppTheme.lightBlueColor : AppTheme.whiteColor

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: actionList.currentIndex = index
                    }

                    Rectangle
                    {
                        anchors.fill: parent
                        anchors.leftMargin: AppTheme.padding * app.scale
                        color: "#00000000"

                        Rectangle
                        {
                            id: columnMainInfo
                            anchors.top: parent.top
                            anchors.left: parent.left
                            height: AppTheme.compHeight * 2 * app.scale
                            width: rectDataContainer.dataWidth
                            color: (index === actionList.currentIndex) ? AppTheme.lightBlueColor : AppTheme.whiteColor

                            Text
                            {
                                anchors.top: parent.top
                                anchors.topMargin: AppTheme.padding/4 * app.scale
                                height: AppTheme.compHeight * app.scale
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueFontColor
                                text: name
                            }

                            Text
                            {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: AppTheme.padding/4 * app.scale
                                height: AppTheme.compHeight * app.scale
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
                                color: AppTheme.greyColor
                                text: printType(type, period)
                            }
                        }

                        Rectangle
                        {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            height: (index === actionList.currentIndex) ? AppTheme.compHeight * 3 * app.scale : AppTheme.compHeight * 2 * app.scale
                            width: parent.width - rectDataContainer.dataWidth
                            color: AppTheme.blueColor

                            Behavior on height
                            {
                                NumberAnimation {   duration: 100 }
                            }

                            Text
                            {
                                anchors.top: parent.top
                                anchors.topMargin: AppTheme.compHeight * app.scale
                                anchors.right: parent.right
                                anchors.rightMargin: AppTheme.padding * app.scale
                                height: AppTheme.compHeight * app.scale
                                width: parent.width
                                verticalAlignment: Text.AlignTop
                                horizontalAlignment: Text.AlignRight
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
                                color: AppTheme.whiteColor
                                text: printDay(startDT)
                            }

                            Text
                            {
                                anchors.top: parent.top
                                anchors.topMargin: AppTheme.padding/4 * app.scale
                                anchors.right: parent.right
                                anchors.rightMargin: AppTheme.padding * app.scale
                                height: AppTheme.compHeight * app.scale
                                width: parent.width
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.whiteColor
                                text: "<b>" + printShortDate(startDT) + "</b>"
                            }

                            Text
                            {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: AppTheme.padding/4 * app.scale
                                anchors.right: parent.right
                                anchors.rightMargin: AppTheme.padding * app.scale
                                height: AppTheme.compHeight * app.scale
                                width: parent.width
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignRight
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.whiteColor
                                text: printTime(startDT)
                                opacity: (index === actionList.currentIndex) ? 1 : 0

                                Behavior on opacity
                                {
                                    NumberAnimation {   duration: 100 }
                                }
                            }
                        }

                        Rectangle
                        {
                            anchors.left: parent.left
                            anchors.top: parent.verticalCenter
                            width: rectDataContainer.dataWidth
                            height: 1 * app.scale
                            color: (index === actionList.currentIndex) ? AppTheme.lightBlueColor : AppTheme.whiteColor
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
                            anchors.bottom: parent.bottom
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
            }

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: actionList.parent
                anchors.top: actionList.top
                anchors.left: actionList.right
                anchors.leftMargin: AppTheme.padding / 4 * app.scale
                anchors.bottom: actionList.bottom

                contentItem: Rectangle
                {
                    implicitWidth: 2 * app.scale
                    implicitHeight: AppTheme.rowHeight * app.scale
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

    DialogAddAction
    {
        id: dialogAddAction
        visible: false

        onSigOk: addLogRecord(dialogAddAction.isEdit)
    }

    ConfirmDialog
    {
        id: confirmDialog
        onSigAccept: dialogAddAction.deleteAction(getParam())
    }
}
