import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: timePicker
    width: 150 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    property alias title: textHeader.text
    property int dotSignWidth: 20 * app.scale
    property int yOffset: 200 * app.scale

    function updateTime()
    {
        var hh = "0" + getHH()
        var mm = "0" + getMM()

        textTime.text = hh.substr(-2) + " : " + mm.substr(-2)
    }

    function setLinuxTime(tm)
    {
        var date = new Date(tm * 1000)
        var hh = "0" + date.getHours()
        var mm = "0" + date.getMinutes()

        hoursTumbler.currentIndex = date.getHours()
        minutesTumbler.currentIndex = date.getMinutes()
        textTime.text = hh.substr(-2) + " : " + mm.substr(-2)
    }

    function setTime(hours, minutes)
    {
        hoursTumbler.positionViewAtIndex(hours, ListView.Center)
        minutesTumbler.positionViewAtIndex(minutes, ListView.Center)
    }

    function getHH()
    {
        return hoursTumbler.currentIndex
    }

    function getMM()
    {
        return minutesTumbler.currentIndex
    }

    function getLinuxTime()
    {
        var hh = "0" + getHH()
        var mm = "0" + getMM()

        return hh.substr(-2) + ":" + mm.substr(-2) + ":00"
    }

    function formatText(count, modelData)
    {
        var data = count === 23 ? modelData : modelData;
        return data.toString().length < 2 ? "0" + data : data;
    }

    function showList(vis)
    {
        rectTimeContainerOpacityAnimation.stop()

        if (vis === true)
        {
            rectTimeContainer.visible = true
            rectTimeContainerOpacityAnimation.from = 0
            rectTimeContainerOpacityAnimation.to = 1
        }
        else
        {
            rectTimeContainerOpacityAnimation.from = 1
            rectTimeContainerOpacityAnimation.to = 0
        }

        rectTimeContainerOpacityAnimation.start()
    }

    Text
    {
        id: textTime
        text: "15:30"
        width: datePicker.width
        height: AppTheme.compHeight * app.scale
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: enabled ? AppTheme.blueColor : AppTheme.hideColor
        onFocusChanged: focus ? rectUnderLine.color = AppTheme.blueColor : rectUnderLine.color = AppTheme.hideColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: textTime.forceActiveFocus()
        }
    }

    Rectangle
    {
        id: rectUnderLine
        anchors.top: textTime.bottom
        anchors.left: textTime.left
        anchors.right: textTime.right
        height: 1 * app.scale
        color: AppTheme.hideColor
        opacity: datePicker.opacity
    }

    Image
    {
        id: img
        anchors.right: parent.right
        anchors.top: parent.top
        width: 27 * app.scale
        height: 27 * app.scale
        source: "qrc:/resources/img/icon_listdown.png"
        mipmap: true

        MouseArea
        {
            anchors.fill: parent

            onClicked:
            {
                datePicker.forceActiveFocus()
                showList(true)
            }
        }
    }

    ColorOverlay
    {
        anchors.fill: img
        source: img
        color: AppTheme.blueColor
    }

    Rectangle
    {
        id: rectTimeContainer
        parent: Overlay.overlay
        width: app.width
        height: app.height
        focus: true
        clip: true
        visible: false
        color: "#00000000"

        NumberAnimation
        {
            id: rectTimeContainerOpacityAnimation
            target: rectTimeContainer
            property: "opacity"
            duration: 300
            easing.type: Easing.InOutQuad
            from: 0
            to: 1

            onFinished: if (to === 0) rectTimeContainer.visible = false
        }

        MouseArea { anchors.fill: parent }

        Rectangle
        {
            color: "#00000000"
            anchors.fill: parent

            Rectangle
            {
                anchors.fill: parent
                anchors.topMargin: yOffset
                color: "#ffffffff"
                clip: true

                Rectangle
                {
                    anchors.fill: parent
                    anchors.leftMargin: AppTheme.margin * app.scale
                    anchors.rightMargin: AppTheme.margin * app.scale
                    anchors.topMargin: AppTheme.margin * app.scale
                    color: "#00000000"

                    Text
                    {
                        id: textHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                        width: 100 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("Select a time:")
                    }

                    Rectangle
                    {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: textHeader.bottom
                        anchors.topMargin: AppTheme.padding * app.scale
                        height: 200 * app.scale

                        Tumbler
                        {
                            id: hoursTumbler
                            anchors.right: labelDot.left
                            anchors.top: parent.top
                            width: 100 * app.scale
                            height: parent.height
                            model: 24
                            delegate: Label
                            {
                                text: formatText(Tumbler.tumbler.count, modelData)
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: AppTheme.fontSuperBigSize * app.scale
                                font.family: AppTheme.fontFamily
                                color: (index === hoursTumbler.currentIndex) ? AppTheme.blueColor : AppTheme.hideColor
                            }
                            visibleItemCount: 3
                        }

                        Label
                        {
                            id: labelDot
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: AppTheme.fontSuperBigSize * app.scale
                            font.family: AppTheme.fontFamily
                            color: AppTheme.blueColor
                            text: ":"
                        }

                        Tumbler
                        {
                            id: minutesTumbler
                            anchors.left: labelDot.right
                            anchors.top: parent.top
                            width: 100 * app.scale
                            height: parent.height
                            model: 60
                            delegate: Label
                            {
                                text: formatText(Tumbler.tumbler.count, modelData)
                                opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: AppTheme.fontSuperBigSize * app.scale
                                font.family: AppTheme.fontFamily
                                color: (index === minutesTumbler.currentIndex) ? AppTheme.blueColor : AppTheme.hideColor
                            }
                            visibleItemCount: 3
                        }
                    }

                    IconSimpleButton
                    {
                        id: buttonCancel
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.margin * app.scale
                        anchors.left: parent.left
                        image: "qrc:/resources/img/icon_cancel.png"

                        onSigButtonClicked:
                        {
                            showList(false)
                        }
                    }

                    IconSimpleButton
                    {
                        id: buttonOk
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.margin * app.scale
                        anchors.right: parent.right
                        image: "qrc:/resources/img/icon_ok.png"

                        onSigButtonClicked:
                        {
                            updateTime()
                            showList(false)
                        }
                    }
                }
            }
        }
    }
}
