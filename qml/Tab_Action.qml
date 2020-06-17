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

    function addAction()
    {
        var dt = Math.round(new Date(datePicker.getLinuxDate() + " " + timePicker.getLinuxTime()).getTime()/1000)

        if (textActionName.text.length > 0 &&
            textDesc.text.length)
        {
            app.sigAddAction(textActionName.text, textDesc.text, 0, comboPeriod.currentIndex, dt)

            rectAddActionDialog.opacity = 0
            rectDataContainer.opacity = 1
        }
    }

    function printType(period)
    {
        switch (period)
        {
            case AppDefs.ActionRepeat_EveryDay:     return qsTr("(Daily)");
            case AppDefs.ActionRepeat_EveryWeek:    return qsTr("(Weekly)");
            case AppDefs.ActionRepeat_EveryMonth:   return qsTr("(Monthly)");
            default:                                return "(Undefined)"
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
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            width: 120 * app.scale
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontBigSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("This week:")
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
                            text: printType(period)
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

                            }
                        }

                        IconSmallSimpleButton
                        {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            image: "qrc:/resources/img/icon_edit.png"

                            onSigButtonClicked:
                            {

                            }
                        }
                    }
                }
            }
        }

        IconSimpleButton
        {
            id: addRecordButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale

            onSigButtonClicked:
            {
                rectAddActionDialog.opacity = 1
                rectDataContainer.opacity = 0
            }
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
            height: 300 * app.scale
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
                ListElement {   name: qsTr("One shot")      }
                ListElement {   name: qsTr("Every day")     }
                ListElement {   name: qsTr("Every week")    }
                ListElement {   name: qsTr("Every month")   }
            }

            ComboList
            {
                id: comboPeriod
                propertyName: qsTr("Select a period:");
                width: parent.width
                model: periodslistModel
            }

            //Item { height: 1; width: 1;}

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

            onSigButtonClicked:
            {
                rectAddActionDialog.opacity = 0
                rectDataContainer.opacity = 1
            }
        }

        IconSimpleButton
        {
            id: buttonAdd
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale
            anchors.right: parent.right
            image: "qrc:/resources/img/icon_ok.png"

            onSigButtonClicked: addAction()
        }
    }
}
