import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import ".."


Item
{
    id: tab_Action

    Rectangle
    {
        id: rectDataContainer
        anchors.fill: parent
        color: "#00000000"

        Behavior on opacity
        {
            NumberAnimation {   duration: 200 }
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
                KeyNavigation.tab: textUserEmail
            }

            Item { height: 1; width: 1;}

            TextInput
            {
                id: textPeriod
                placeholderText: qsTr("Description")
                width: parent.width
                focus: true
                KeyNavigation.tab: textUserEmail
            }

            Item { height: 1; width: 1;}

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
                enabled: buttonPeriodicEnable.checked
            }

            Item { height: 1; width: 1;}

            Text
            {
                verticalAlignment: Text.AlignVCenter
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("Start date")
            }

            DatePicker
            {
                id: datePicker
                width: parent.width
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

            onSigButtonClicked:
            {
                rectAddActionDialog.opacity = 0
                rectDataContainer.opacity = 1
            }
        }
    }
}
