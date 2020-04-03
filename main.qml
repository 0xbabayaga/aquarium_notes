import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "qml"
import "qml/custom"

Window
{
    id: app
    objectName: "app"

    property real scale: (Screen.orientation  === Qt.PortraitOrientation) ? Screen.desktopAvailableHeight / 720 : Screen.desktopAvailableHeight / 1080

    ListModel
    {
        id: tmpTankModel
        ListElement { name: "MY REEF";          volume: 450;    type: 0;    photo: ""   }
        ListElement { name: "BEST REEF EVER";   volume: 120;    type: 0;    photo: ""   }
        ListElement { name: "MY FRESH";         volume: 70;     type: 1;    photo: ""   }
    }

    ListModel
    {
        id: tmpParamModel
        ListElement { name: "Salinity";     value: "33.5ppm";    }
        ListElement { name: "Ca";           value: "397mg\\l";     }
        ListElement { name: "kH";           value: "7.7dKH";     }
        ListElement { name: "pH";           value: "8.2";     }
    }


    visible: true
    width: 360
    height: 720

    Image
    {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: AppTheme.margin
        anchors.right: parent.right
        fillMode: Image.PreserveAspectFit
        source: "qrc:/resources/img/back_waves.png"
    }

    Rectangle
    {
        id: rectMain
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: AppTheme.rowHeightMin * app.scale
        color: "#00000000"

        Image
        {
            id: imgAppIcon
            anchors.right: parent.right
            anchors.rightMargin: 12 * app.scale
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            width: 16 * app.scale
            height: 16 * app.scale
            source: "qrc:/resources/img/icon_app.png"
            mipmap: true

            ColorOverlay
            {
                anchors.fill: imgAppIcon
                source: imgAppIcon
                color: AppTheme.blueColor
            }
        }

        Text
        {
            id: textAppName
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.margin/2 * app.scale
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("AQUARIUM NOTES")
        }
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
        tanksListmodel: tmpTankModel
        onSigCurrentIndexChanged: textTankName.text = tanksListmodel.get(id).name
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
}
