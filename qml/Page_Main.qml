import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import "../"

Item
{
    id: page_Main

    function showPage(vis)
    {
        if (vis === true)
            showPageAnimation.start()
        else
            hidePageAnimation.start()
    }

    function openTankPage()
    {
        var tankParams = [tanksListModel[tanksList.currentIndex].name,
                          tanksListModel[tanksList.currentIndex].desc,
                          tanksListModel[tanksList.currentIndex].type,
                          tanksListModel[tanksList.currentIndex].typeName,
                          tanksListModel[tanksList.currentIndex].volume,
                          tanksListModel[tanksList.currentIndex].img]

        page_TankData.showPage(true, tankParams)
    }

    NumberAnimation
    {
        id: showPageAnimation
        target: page_Main
        property: "opacity"
        from: 0
        to: 1
        onStarted: page_Main.visible = true
    }

    NumberAnimation
    {
        id: hidePageAnimation
        target: page_Main
        property: "opacity"
        from: 1
        to: 0
        onFinished: page_Main.visible = false
    }

    Text
    {
        id: textUserTanks
        anchors.top: parent.top
        anchors.topMargin: AppTheme.padding * 4 * app.scale
        anchors.left: parent.left
        anchors.leftMargin: AppTheme.padding * app.scale
        verticalAlignment: Text.AlignVCenter
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        color: AppTheme.greyColor
        text: qsTr("USER TANKS")
    }

    TankListView
    {
        id: tanksList
        anchors.fill: parent
        anchors.topMargin: AppTheme.padding * 6 * app.scale
        model: tanksListModel

        onSigCurrentIndexChanged:
        {
            textTankName.text = model[id].name
            app.sigTankSelected(currentIndex)
        }

        onSigDoubleClicked:
        {
            textTankName.text = model[id].name
            app.sigTankSelected(currentIndex)
            openTankPage()
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
        text: (tanksList.model.length > 0) ? tanksList.model[0].name : ""
        visible: false
    }

    TanksList
    {
        //id: tanksList
        anchors.top: parent.top
        anchors.topMargin: AppTheme.rowHeightMin * app.scale * 2
        anchors.horizontalCenter: parent.horizontalCenter
        //model: tanksListModel
        visible: false

        onSigCurrentIndexChanged:
        {
            //textTankName.text = model[id].name
            app.sigTankSelected(currentIndex)
        }

        //onSigDoubleClicked:
        //{
            //textTankName.text = model[id].name
            //app.sigTankSelected(currentIndex)
            //openTankPage()
       //}
    }

    Flickable
    {
        id: flickableContainer
        anchors.top:tanksList.bottom
        anchors.topMargin: AppTheme.compHeight * app.scale * 3
        anchors.left: parent.left
        anchors.leftMargin: AppTheme.padding * app.scale
        anchors.right: parent.right
        anchors.rightMargin: AppTheme.padding * app.scale
        anchors.bottom: parent.bottom
        visible: false

        contentWidth: width
        contentHeight: 700 * app.scale
        clip: true

        CurrentParamsMainTable
        {
            id: currParamsMainTable
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            //model: curValuesListModel
            height: 300 * app.scale
        }

        ScrollBar.vertical: ScrollBar
        {
            policy: ScrollBar.AlwaysOn
            parent: flickableContainer.parent
            anchors.top: flickableContainer.top
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: flickableContainer.right
            anchors.leftMargin: AppTheme.padding / 4 * app.scale
            anchors.bottom: flickableContainer.bottom
            anchors.bottomMargin: AppTheme.padding * app.scale

            contentItem: Rectangle
            {
                implicitWidth: 2
                implicitHeight: 100
                radius: width / 2
                color: AppTheme.hideColor
            }
        }
    }


    IconSimpleButton
    {
        id: buttonDetails
        anchors.right: parent.right
        anchors.rightMargin: AppTheme.padding * app.scale
        anchors.top: flickableContainer.top
        anchors.topMargin: -AppTheme.padding * app.scale
        image: "qrc:/resources/img/icon_arrow_right.png"

        onSigButtonClicked: openTankPage()
        visible: false
    }
}
