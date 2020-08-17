import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import ".."

Item
{
    id: page_TankData
    visible: false
    width: app.width
    height: app.height

    ListModel
    {
        id: modelTabs
        ListElement { tab: qsTr("HISTORY") }
        ListElement { tab: qsTr("GRAPHS") }
        ListElement { tab: qsTr("CALENDAR") }
    }

    function showPage(vis, tankParams)
    {
        var tankName
        var tankDesc
        var tankType
        var tankVol
        var tankTypeName

        scaleAnimation.stop()

        if (tankParams !== 0)
        {
            tankName = tankParams[0]
            tankDesc = tankParams[1]
            tankType = tankParams[2]
            tankTypeName = tankParams[3]
            tankVol = Math.ceil(tankParams[4])
        }

        if (vis === true)
        {
            page_TankData.visible = true
            scaleAnimation.from = parent.width
            scaleAnimation.to = 0

            textTankVol.text = tankVol + "L"
            textTankName.text = tankName
            textTankName.color = (tankType < 4) ? AppTheme.blueColor : AppTheme.greenColor
            textTankVol.color = textTankName.color
            textTankType.text = "["+ tankTypeName +"]"
            imgTank.source = "data:image/jpg;base64," + tankParams[5]
        }
        else
        {
            scaleAnimation.to = parent.width
            scaleAnimation.from = 0
        }

        scaleAnimation.start()
    }

    function setPage(index)
    {
        swipeView.setCurrentIndex(index)
    }

    NumberAnimation
    {
        id: scaleAnimation
        target: rectContainer
        property: "x"
        from: parent.width
        to: 0
        easing.type: Easing.OutBack
        duration: 400
        running: false
        onFinished: if (to === parent.width) page_TankData.visible = false
    }

    Rectangle
    {
        id: rectContainer
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        x: parent.width
        anchors.bottomMargin: AppTheme.rowHeightMin * app.scale
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor

        MouseArea   {   anchors.fill: parent    }

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -(AppTheme.rowHeightMin - AppTheme.margin) * app.scale
            width: parent.width
            height: width * 0.75
            source: "qrc:/resources/img/back_waves.png"
            opacity: 0.3
        }

        Rectangle
        {
            id: rectHeaderShadow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: AppTheme.rowHeightMin * app.scale
            color: AppTheme.blueColor
        }

        DropShadow
        {
            anchors.fill: rectHeaderShadow
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10.0 * app.scale
            samples: 16
            color: "#40000000"
            source: rectHeaderShadow
        }

        Rectangle
        {
            anchors.fill: rectHeaderShadow
            height: AppTheme.rowHeightMin * app.scale
            color: AppTheme.blueColor

            PagesTabList
            {
                id: pageTabsList
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding * 3 * app.scale
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                model: modelTabs

                onCurrentIndexChanged: setPage(currentIndex)
            }

            IconSmallSimpleButton
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding * app.scale
                image: "qrc:/resources/img/icon_arrow_left.png"
                inverted: true

                onSigButtonClicked: showPage(false, "")
            }
        }

        Rectangle
        {
            id: rectHeaderContainer
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.top: parent.top
            anchors.topMargin: AppTheme.rowHeightMin * app.scale
            height: AppTheme.rowHeight * app.scale
            color: "#00000000"

            /*
            IconSimpleButton
            {
                id: imgArrowBack
                anchors.left: parent.left
                anchors.verticalCenter: imgTank.verticalCenter
                image: "qrc:/resources/img/icon_arrow_left.png"

                onSigButtonClicked: showPage(false, "")
            }
            */

            Image
            {
                id: imgTank
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                width: height
                mipmap: true
                source: ""

                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: imgTankMask
                }
            }

            Rectangle
            {
                id: imgTankMask
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                width: height
                radius: height/2
                visible: false
            }

            Text
            {
                id: textTankName
                anchors.right: imgTank.left
                anchors.rightMargin: AppTheme.padding * app.scale
                anchors.verticalCenter: parent.verticalCenter
                height: AppTheme.compHeight * app.scale
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("")
            }

            Text
            {
                id: textTankVol
                anchors.top: textTankName.bottom
                anchors.right: imgTank.left
                anchors.rightMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("")
            }

            Text
            {
                id: textTankType
                anchors.top: textTankName.bottom
                anchors.right: textTankVol.left
                anchors.rightMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeight * app.scale
                verticalAlignment: Text.AlignTop
                horizontalAlignment: Text.AlignRight
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("")
            }
        }

        /*
        PagesTabList
        {
            id: pageTabsList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: AppTheme.rowHeightMin * 2 * app.scale
            model: modelTabs

            onCurrentIndexChanged: setPage(currentIndex)
        }
        */

        SwipeView
        {
            id: swipeView
            anchors.fill: parent
            anchors.topMargin: AppTheme.rowHeightMin * 3 * app.scale
            orientation: Qt.Horizontal
            clip: true
            interactive: false

            Tab_Current
            {
                id: tab_Current
            }

            Tab_Graph
            {
                id: tab_Graph
            }

            Tab_Action
            {
                id: tab_Action
            }
        }
    }
}
