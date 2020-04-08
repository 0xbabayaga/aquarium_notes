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

    property bool isAccountCreated: false
    property real scale: (Screen.orientation  === Qt.PortraitOrientation) ? Screen.desktopAvailableHeight / 720 : Screen.desktopAvailableHeight / 1080

    visible: true
    width: 360
    height: 720

    signal sigCreateAccount(string uname, string upass, string umail, int tankType)

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
        id: rectBackground
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectHeader
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
                width: 24 * app.scale
                height: 24 * app.scale
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
    }

    Page_Main
    {
        id: page_Main
        anchors.fill: rectBackground
        visible: isAccountCreated === true
    }

    Page_AccountCreation
    {
        id: page_AccountCreation
        anchors.fill: rectBackground
        visible: isAccountCreated === false
    }

    Page_TankData
    {
        id: page_TankData
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: AppTheme.rowHeightMin * app.scale
    }
}
