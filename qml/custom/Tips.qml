import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import AppDefs 1.0

Item
{
    id: tips
    width: app.width - AppTheme.margin * 2 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: 0
    visible: false

    property alias tipText: tipInfo.text

    function show(visible)
    {
        showTipAnimation.stop()
        hideTipAnimation.stop()

        if (visible === true)
            showTipAnimation.start()
        else
            hideTipAnimation.start()

        if (visible === true)
            tmr.start()
        else
            tmr.stop()
    }

    NumberAnimation
    {
        id: showTipAnimation
        target: tips
        property: "opacity"
        duration: 200
        from: 0
        to: 1

        onStarted: tips.visible = true
    }

    NumberAnimation
    {
        id: hideTipAnimation
        target: tips
        property: "opacity"
        duration: 200
        from: 1
        to: 0

        onFinished: tips.visible = false
    }

    Timer
    {
        id: tmr
        interval: AppDefs.APP_TIP_SHOW_TIME
        running: false
        repeat: false
        onTriggered: show(false)
    }

    Rectangle
    {
        anchors.fill: parent
        radius: AppTheme.radius * 2 * app.scale
        //color: AppTheme.lightBlueColor
        color: AppTheme.blueColor

        Text
        {
            id: tipInfo
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            height: parent.height
            width: parent.width
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
            color: AppTheme.whiteColor
            //color: AppTheme.blueColor
            text: "None"
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: show(false)
        }
    }
}
