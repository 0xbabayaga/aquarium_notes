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

    property int global_DIMUNITS:   AppDefs.Dimensions_CM
    property int global_VOLUNITS:   AppDefs.Volume_L
    property int global_DATEFORMAT: AppDefs.DateFormat_DD_MM_YYYY
    property string global_USERREGION: ""
    property string global_USERCOUNTRY: ""
    property string global_USERCITY: ""

    ListView
    {
        id: tmpParamList
        model: allParamsListModel
        visible: false
    }

    visible: true
    width: 360
    height: 720

    onIsAccountCreatedChanged:
    {
        if (isAccountCreated === false)
        {
            page_TankSett.visible = false
            page_AccountSett.visible = false
            page_TankData.visible = false
            page_Main.visible = false
            page_AccountWizard.visible = true
        }
        else
        {
            page_Main.visible = true
            page_AccountWizard.visible = false
        }
    }

    signal sigCreateAccount(string uname, string upass, string umail, string img)
    signal sigEditAccount(string uname, string upass, string umail, string img)
    signal sigDeleteAccount()
    signal sigCreateTank(string name, string desc, int type, int l, int w, int h, string img)
    signal sigEditTank(string tankId, string name, string desc, int type, int l, int w, int h, string img)
    signal sigDeleteTank(string tankId)
    signal sigAddRecord(int smpId, int paramId, double value)
    signal sigEditRecord(int smpId, int paramId, double value)
    signal sigAddRecordNotes(int smpId, string note, string imageLink)
    signal sigEditRecordNotes(int smpId, string note, string imageLink)
    signal sigTankSelected(int tankIdx)
    signal sigTankStoryLoad(int tankIdx)
    signal sigPersonalParamStateChanged(int paramId, bool en)
    signal sigAddAction(string name, string desc, int type, int period, int dt)
    signal sigEditAction(int id, string name, string desc, int type, int period, int dt)
    signal sigDeleteAction(int id)
    signal sigActionViewPeriodChanged(int p)
    signal sigRefreshData()
    signal sigCurrentSmpIdChanged(int smpId)
    signal sigDebug()
    signal sigOpenGallery()
    signal sigLanguageChanged(int id)
    signal sigDimensionUnitsChanged(int id)
    signal sigVolumeUnitsChanged(int id)
    signal sigDateFormatChanged(int id)

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

    function convertDimension(dim)
    {
        var val = dim

        if (global_DIMUNITS === AppDefs.Dimensions_INCH)
            val = dim / 2.54

        return Math.round(val * 100) / 100
    }

    function deconvertDimension(dim)
    {
        if (global_DIMUNITS === AppDefs.Dimensions_INCH)
            return dim * 2.54
        else
            return dim
    }

    function convertVolume(vol)
    {
        var val = vol

        if (global_VOLUNITS === AppDefs.Volume_L)
            val = vol
        else if (global_VOLUNITS === AppDefs.Volume_G_UK)
            val = vol * 0.219969
        else
            val = vol * 0.2641717541633774

        return Math.round(val)
    }

    function currentDimensionUnits()
    {
        if (global_DIMUNITS === AppDefs.Dimensions_CM)
            return qsTr("cm")
        else
            return qsTr("inch")
    }

    function currentVolumeUnits()
    {
        if (global_VOLUNITS === AppDefs.Volume_L)
            return qsTr("L")
        else if (global_VOLUNITS === AppDefs.Volume_G_UK)
            return qsTr("Gal(UK)")
        else
            return qsTr("Gal(US)")
    }

    function currentVolumeUnitsShort()
    {
        if (global_VOLUNITS === AppDefs.Volume_L)
            return qsTr("L")
        else if (global_VOLUNITS === AppDefs.Volume_G_UK)
            return qsTr("G")
        else
            return qsTr("G")
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
                color: AppTheme.blueColor

                Text
                {
                    id: textAppName
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.margin/2 * app.scale
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.whiteColor
                    text: qsTr("AQUARIUM NOTES")
                }
            }
        }

        Page_Main
        {
            id: page_Main
            anchors.fill: rectBackground
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
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
            anchors.fill: rectBackground
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
        }

        Page_AccountSett
        {
            id: page_AccountSett
            anchors.fill: rectBackground
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
            visible: false
            //onSigClosed: page_Main.showPage(true)
        }

        Page_TankSett
        {
            id: page_TankSett
            anchors.fill: rectBackground
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
            visible: false
            //onSigClosed: page_Main.showPage(true)
        }

        Page_AppSett
        {
            id: page_AppSett
            anchors.fill: rectBackground
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
            visible: false

            //onSigClosed: page_Main.showPage(true)
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
        accountImage: "data:image/png;base64," + app.curUserAvatar

        onSigMenuSelected:
        {
            if (isAccountCreated === true)
            {
                if (id === AppDefs.Menu_Account)
                {
                    page_TankSett.moveToEdit(false)
                    page_TankSett.showPage(false)
                    page_AppSett.showPage(false)
                    page_AccountSett.showPage(true)
                }
                else if (id === AppDefs.Menu_TankInfo)
                {
                    page_AccountSett.moveToEdit(false)
                    page_AccountSett.showPage(false)
                    page_AppSett.showPage(false)
                    page_TankSett.showPage(true)
                }
                else if (id === AppDefs.Menu_Settings)
                {
                    page_AccountSett.moveToEdit(false)
                    page_AccountSett.showPage(false)
                    page_TankSett.showPage(false)
                    page_AppSett.showPage(true)
                }
            }
        }
    }
}
