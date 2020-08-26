import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import "../"

Item
{
    id: page_Main
    objectName: "page_Main"

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

    function openStoryView(isOpen)
    {
        if (isOpen === true)
            openTankStoryViewAnimation.start()
        else
            hideTankStoryViewAnimation.start()
    }

    SequentialAnimation
    {
        id: openTankStoryViewAnimation

        NumberAnimation
        {
            target: tanksList
            property: "opacity"
            from: 1
            to: 0
        }

        NumberAnimation
        {
            target: tankStory
            property: "opacity"
            from: 0
            to: 1
        }

        onStarted: tankStory.visible = true
        onFinished: tanksList.visible = false
    }

    SequentialAnimation
    {
        id: hideTankStoryViewAnimation

        NumberAnimation
        {
            target: tankStory
            property: "opacity"
            from: 1
            to: 0
        }

        NumberAnimation
        {
            target: tanksList
            property: "opacity"
            from: 0
            to: 1
        }

        onStarted: tanksList.visible = true
        onFinished: tankStory.visible = false
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

    Rectangle
    {
        id: rectHeaderShadow
        anchors.fill: parent
        color: AppTheme.whiteColor
    }

    DropShadow
    {
        anchors.fill: rectHeaderShadow
        horizontalOffset: 0
        verticalOffset: -AppTheme.shadowOffset * app.scale
        radius: AppTheme.shadowSize * app.scale
        samples: AppTheme.shadowSamples * app.scale
        color: AppTheme.shadowColor
        source: rectHeaderShadow
    }

    Rectangle
    {
        anchors.fill: rectHeaderShadow
        color: AppTheme.whiteColor

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: AppTheme.padding * app.scale
            width: parent.width
            height: width * 0.75
            source: "qrc:/resources/img/back_waves.png"
        }

        Text
        {
            id: textUserTanks
            anchors.top: parent.top
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.greyColor
            text: qsTr("MY TANKS")
        }

        TankListView
        {
            id: tanksList
            anchors.fill: parent
            anchors.topMargin: AppTheme.padding * 3 * app.scale
            anchors.bottomMargin: AppTheme.margin * app.scale
            model: tanksListModel

            onSigCurrentIndexChanged: app.sigTankSelected(currentIndex)

            onSigTankSelected:
            {
                app.sigTankSelected(currentIndex)
                openTankPage()
            }

            onSigDoubleClicked:
            {
                app.sigTankSelected(currentIndex)
                openTankPage()
            }

            onSigTankStorySelected:
            {
                //app.sigTankStorySelected(currentIndex)
                openStoryView(true)
            }
        }

        TankStoryView
        {
            id: tankStory
            objectName: "tankStory"
            anchors.fill: parent
            anchors.topMargin: AppTheme.padding * 3 * app.scale
            anchors.bottomMargin: AppTheme.margin * app.scale
            visible: false
            opacity: 0

            onSigTankStoryClose: openStoryView(false)
            onSigTankStoryLoadIndex: app.sigTankStorySelected(index)
        }
    }
}
