import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import "../"

Item
{
    id: page_Main

    ListModel
    {
        id: tmpParamModel
        ListElement { name: "Salinity";     value: "33.5ppm";    }
        ListElement { name: "Ca";           value: "397mg\\l";     }
        ListElement { name: "kH";           value: "7.7dKH";     }
        ListElement { name: "pH";           value: "8.2";     }
    }

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
        text: tanksListmodel.get(0).name;
    }

    TanksList
    {
        id: tanksList
        anchors.top: parent.top
        anchors.topMargin: AppTheme.rowHeightMin * app.scale * 2
        anchors.horizontalCenter: parent.horizontalCenter
        model: tanksListModel
        onSigCurrentIndexChanged:
        {
            textTankName.text = tanksListModel.get(id).name
        }
    }

    Rectangle
    {
        id: rectDataContainer
        anchors.top:tanksList.bottom
        anchors.margins: AppTheme.margin * app.scale
        anchors.topMargin: AppTheme.rowHeight * app.scale * 2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#00000000"

        Text
        {
            id: textCurrentLabel
            anchors.top: parent.top
            anchors.right: parent.right
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontBigSize * app.scale
            color: AppTheme.greyColor
            text: "[" + qsTr("CURRENT") + "]"
        }

        ListView
        {
            id: paramListView
            anchors.fill: parent
            anchors.topMargin: textCurrentLabel.height
            spacing: 0
            model: tmpParamModel
            delegate: Rectangle
            {
                width: parent.width
                height: AppTheme.rowHeight * app.scale
                color: "#00000000"

                Text
                {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: name
                }

                Text
                {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.greyColor
                    text: value
                }

                Rectangle
                {
                    width: parent.width
                    height: 1 * app.scale
                    anchors.bottom: parent.bottom
                    color: ((index + 1) === paramListView.model.count) ? "#00000000" : AppTheme.shideColor
                }
            }
        }
    }

    StandardButton
    {
        id: butShowMore
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: AppTheme.margin * app.scale
        bText: qsTr("Show more")

        onSigButtonClicked:
        {
            page_TankData.showPage(true, tanksList.model[tanksList.currentIndex].name,
                                   tanksList.model[tanksList.currentIndex].type)
        }
    }
}
