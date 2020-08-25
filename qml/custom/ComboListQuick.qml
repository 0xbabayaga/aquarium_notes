import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: comboListQuick
    width: 150 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    signal sigSelectedIndexChanged(int id)

    property alias currentIndex: listView.currentIndex
    property alias propertyName: textPropertyName.text
    property alias model: listView.model
    property alias text: textArea.text

    function showList(vis)
    {
        rectListOpacityAnimation.stop()

        if (vis === true)
        {
            rectList.visible = true
            rectListOpacityAnimation.from = 0
            rectListOpacityAnimation.to = 1
        }
        else
        {
            rectListOpacityAnimation.from = 1
            rectListOpacityAnimation.to = 0
        }

        rectListOpacityAnimation.start()
    }

    function formattedTime(val)
    {
        var mm = val % 60
        var hh = val / 24
        var str = ""

        hh %= 24

        if (hh < 10)
            str = "0"

        str += hh
        str += ":"

        if (mm < 10)
            str += "0"

        str += mm

        return str
    }

    Text
    {
        id: textArea
        text: (listView.model.count) ? listView.model.get(listView.currentIndex).name : ""
        width: comboListQuick.width
        height: comboListQuick.height
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: enabled ? AppTheme.blueFontColor : AppTheme.hideColor
        onFocusChanged: focus ? rectUnderLine.color = AppTheme.blueColor : rectUnderLine.color = AppTheme.hideColor

        MouseArea
        {
            anchors.fill: parent
            onClicked: textArea.forceActiveFocus()
        }
    }

    Rectangle
    {
        id: rectUnderLine
        anchors.top: textArea.bottom
        anchors.left: textArea.left
        anchors.right: textArea.right
        height: 1 * app.scale
        color: AppTheme.hideColor
        opacity: comboListQuick.opacity
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
                textArea.forceActiveFocus()
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
        id: rectList
        parent: Overlay.overlay
        width: app.width
        height: app.height
        focus: true
        clip: true
        visible: false
        color: "#20000000"

        NumberAnimation
        {
            id: rectListOpacityAnimation
            target: rectList
            property: "opacity"
            duration: 300
            easing.type: Easing.InOutQuad
            from: 0
            to: 1

            onFinished: if (to === 0) rectList.visible = false
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: showList(false)
        }

        Rectangle
        {
            id: rectShadow
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.verticalCenter: parent.verticalCenter
            height: AppTheme.rowHeight * 2 * app.scale + AppTheme.compHeight * app.scale * listView.model.count
            radius: AppTheme.radius * 2 * app.scale
            color: AppTheme.whiteColor
        }

        DropShadow
        {
            anchors.fill: rectShadow
            horizontalOffset: 0
            verticalOffset: -3
            radius: 16.0 * app.scale
            samples: 16
            color: "#20000000"
            source: rectShadow
        }

        Rectangle
        {
            anchors.fill: rectShadow
            radius: AppTheme.radius * 2 * app.scale
            color: AppTheme.whiteColor
            clip: true

            Rectangle
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.rightMargin: AppTheme.padding * app.scale
                anchors.topMargin: AppTheme.margin * app.scale
                height: AppTheme.rowHeight * app.scale * 6
                color: "#00000000"

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: showList(false)
                }

                Rectangle
                {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: AppTheme.rowHeight/2 * app.scale
                    height: 1 * app.scale
                    color: AppTheme.blueColor
                    visible: false
                }

                Rectangle
                {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -AppTheme.rowHeight/2 * app.scale
                    height: 1 * app.scale
                    color: AppTheme.blueColor
                    visible: false
                }

                Text
                {
                    id: textPropertyName
                    text: ""
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.padding * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.greyDarkColor
                    verticalAlignment: Text.AlignBottom
                }

                ListView
                {
                    id: listView
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: AppTheme.margin * 2 * app.scale
                    height: AppTheme.compHeight * app.scale * model.count
                    clip: true

                    delegate: Rectangle
                    {
                        color: (index === listView.currentIndex) ? AppTheme.lightBlueColor : "#00000000"
                        width: listView.width
                        height: AppTheme.compHeight * app.scale

                        Text
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: AppTheme.padding * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.blueFontColor
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: name
                        }

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: listView.currentIndex = index
                        }
                    }

                    onCurrentIndexChanged:
                    {
                        sigSelectedIndexChanged(currentIndex)

                            showList(false)
                            textArea.text = (model !== undefined) ? model.get(currentIndex).name : ""
                        }

                    ScrollBar.vertical: ScrollBar
                    {
                        policy: ScrollBar.AlwaysOn
                        parent: listView.parent
                        anchors.top: listView.top
                        anchors.left: listView.right
                        anchors.bottom: listView.bottom

                        contentItem: Rectangle
                        {
                            implicitWidth: 2
                            implicitHeight: 100
                            radius: width / 2
                            color: AppTheme.hideColor
                        }
                    }
                }
            }
        }
    }
}
