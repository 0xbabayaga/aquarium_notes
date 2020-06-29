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

    property int lastSmpId: 0
    property bool isAccountCreated: false
    property real scale: (Screen.orientation  === Qt.PortraitOrientation) ? Screen.desktopAvailableHeight / 720 : Screen.desktopAvailableHeight / 1080

    property var months: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    ListView
    {
        id: tmpParamList
        model: allParamsListModel
        visible: false
    }

    visible: true
    width: 360
    height: 720

    signal sigCreateAccount(string uname, string upass, string umail)
    signal sigCreateTank(string name, int type, int l, int w, int h, string img)
    signal sigAddRecord(int smpId, int paramId, double value)
    signal sigEditRecord(int smpId, int paramId, double value)
    signal sigAddRecordNotes(int smpId, string note, string imageLink)
    signal sigEditRecordNotes(int smpId, string note, string imageLink)
    signal sigTankSelected(int tankIdx)
    signal sigPersonalParamStateChanged(int paramId, bool en)
    signal sigAddAction(string name, string desc, int type, int period, int dt)
    signal sigEditAction(int id, string name, string desc, int type, int period, int dt)
    signal sigDeleteAction(int id)
    signal sigActionViewPeriodChanged(int p)
    signal sigRefreshData()
    signal sigCurrentSmpIdChanged(int smpId)
    signal sigDebug()

    function getAllParamsListModel() { return allParamsListModel    }

    function getParamById(id)
    {
        for (var i = 0; i < allParamsListModel.length; i++)
        {
            if (allParamsListModel[i].paramId === id)
                return allParamsListModel[i]
        }

        return 0
    }

    function printDate(tm)
    {
        var date = new Date(tm * 1000)
        var day = "0" + date.getDate()
        var month = "0" + date.getMonth()
        var year = "0" + date.getYear()

        //var formattedDate = day.substr(-2) + '.' + month.substr(-2) + '.' + year.substr(-2)
        var formattedDate = day.substr(-2) + '/' + month.substr(-2)

        return formattedDate
    }

    function printDateEx(tm)
    {
        var date = new Date(tm * 1000)
        var day = "0" + date.getDate()
        var formattedDate = day.substr(-2) + ' ' + app.months[date.getMonth()].slice(0,3).toUpperCase()

        return formattedDate
    }

    Image
    {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: AppTheme.margin * app.scale
        width: parent.width
        height: width * 0.75
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
        objectName: "page_AccountCreation"
        anchors.fill: rectBackground
        visible: isAccountCreated === false

        onSigAppInitCompleted: isAccountCreated = true
    }

    Page_TankData
    {
        id: page_TankData
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: AppTheme.rowHeightMin * app.scale
    }
}
