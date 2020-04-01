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
        ListElement { name: "MY REEF";  volume: 450;    type: 0    }
        ListElement { name: "BEST REEF EVER";  volume: 120;    type: 0    }
        ListElement { name: "MY FRESH";  volume: 70;    type: 1    }
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
            anchors.left: parent.left
            anchors.leftMargin: -AppTheme.margin * app.scale * 2
            anchors.right: parent.right
            anchors.rightMargin: -AppTheme.margin * app.scale * 2
            anchors.top: parent.top
            anchors.topMargin: AppTheme.rowHeightMin * app.scale * 2
            width: parent.width
            tanksListmodel: tmpTankModel

            onSigCurrentIndexChanged: textTankName.text = tanksListmodel.get(id).name
        }
    }
}
