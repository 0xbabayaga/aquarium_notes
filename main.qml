import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import AppDefs 1.0
import "qml"
import "qml/custom"

Window
{
    id: app
    objectName: "app"

    property bool   isAndro: false
    property int    lastSmpId: 0
    property bool   isAccountCreated: false
    property real   scale: (Screen.orientation  === Qt.PortraitOrientation) ? Screen.desktopAvailableHeight / 720 : Screen.desktopAvailableHeight / 1080

    property string curUserName: ""
    property string curUserEmail: ""
    property string curUserAvatar: ""
    property int curUserDateCreate: 0

    ListView
    {
        id: tmpParamList
        model: allParamsListModel
        visible: false
    }

    visible: true
    width: 360
    height: 720

    signal sigCreateAccount(string uname, string upass, string umail, string img)
    signal sigEditAccount(string uname, string upass, string umail, string img)
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
    signal sigOpenGallery()

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

    Rectangle
    {
        id: rectMain
        anchors.fill: parent

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

        Page_AccountsWizard
        {
            id: page_AccountWizard
            objectName: "page_AccountWizard"
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

        Page_AccountSett
        {
            id: page_AccountSett
            anchors.fill: rectBackground
            visible: false

            onSigClose: page_Main.showPage(true)
        }

        Page_TankSett
        {
            id: page_TankSett
            anchors.fill: rectBackground
            visible: false

            onSigClose: page_Main.showPage(true)
        }
    }

    SideMenu
    {
        id: sideMenu
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        height: parent.height

        accountName: app.curUserName
        accountEmail: app.curUserEmail
        accountImage: "data:image/png;base64," + app.curUserAvatar

        onSigMenuSelected:
        {
            if (id === AppDefs.Menu_Account)
            {
                page_Main.showPage(false)
                page_AccountSett.moveToEdit(false)
                page_AccountSett.showPage(true)
            }
            else if (id === AppDefs.Menu_TankInfo)
            {
                page_Main.showPage(false)
                page_AccountSett.showPage(false)
                page_TankSett.showPage(true)
            }
        }
    }
}
