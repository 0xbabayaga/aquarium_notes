import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import "../"

Item
{
    id: page_Main

    Text
    {
        id: textTankName
        anchors.top: parent.top
        anchors.topMargin: AppTheme.margin * app.scale * 2
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontSuperBigSize * app.scale
        color: AppTheme.blueColor
        text: tanksList.model[0].name
    }

    TanksList
    {
        id: tanksList
        anchors.top: parent.top
        anchors.topMargin: AppTheme.rowHeightMin * app.scale * 2
        anchors.horizontalCenter: parent.horizontalCenter
        model: app.getTankListModel()
        onSigCurrentIndexChanged:
        {
            textTankName.text = model[id].name
            app.sigTankSelected(currentIndex)
        }
    }

    Flickable
    {
        id: flickableContainer
        anchors.top:tanksList.bottom
        anchors.margins: AppTheme.margin * app.scale
        anchors.topMargin: AppTheme.compHeight * app.scale * 3
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: AppTheme.rowHeight * app.scale

        contentWidth: width
        contentHeight: 700 * app.scale
        clip: true

        CurrentParamsMainTable
        {
            id: currParamsMainTable
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            model: curParamsModel
            height: 300
        }

        CurrrentActivities
        {
            id: currActivities
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: currParamsMainTable.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            height: 200
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
                implicitWidth: 2
                implicitHeight: 100
                radius: width / 2
                color: AppTheme.hideColor
            }
        }
    }

    StandardButton
    {
        id: butShowMore
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: AppTheme.margin * app.scale
        bText: qsTr("DETAILS")

        onSigButtonClicked:
        {
            page_TankData.showPage(true, app.getTankListModel()[tanksList.currentIndex].name,
                                   app.getTankListModel()[tanksList.currentIndex].type)
        }
    }
}
