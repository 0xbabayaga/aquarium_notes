import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: comboList
    width: 150 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    signal sigSelectedIndexChanged(int id)

    property int currentIndex: listView.currentIndex
    property alias propertyName: textPropertyName.text
    property alias model: listView.model
    property alias text: textArea.text
    property int yOffset: 200 * app.scale

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
        //text: listView.model[listView.currentIndex].name
        text: listView.model.get(listView.currentIndex).name
        width: comboList.width
        height: comboList.height
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        horizontalAlignment: Text.AlignLeft
        color: enabled ? AppTheme.blueColor : AppTheme.hideColor
    }

    Rectangle
    {
        id: rectUnderLine
        anchors.top: textArea.bottom
        anchors.left: textArea.left
        anchors.right: textArea.right
        height: 1 * app.scale
        color: textArea.enabled ? AppTheme.blueColor : AppTheme.hideColor
        opacity: comboList.opacity
    }

    Image
    {
        id: img
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.height
        height: parent.height
        source: "qrc:/resources/img/icon_arrow_left.png"
        mipmap: true

        MouseArea
        {
            anchors.fill: parent

            onClicked: showList(true)
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
        color: "#00000000"

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

                /*
                Image
                {
                    anchors.fill: parent
                    anchors.topMargin: -yOffset
                    source: "qrc:/resources/background.jpg"
                    fillMode: Image.PreserveAspectCrop
                    width: app.width
                    height: app.height

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: rect.visible = false
                    }
                }
                */

                Rectangle
                {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: AppTheme.margin * app.scale
                    anchors.rightMargin: AppTheme.margin * app.scale
                    anchors.topMargin: AppTheme.margin * app.scale
                    height: AppTheme.rowHeight * app.scale * 6
                    color: "#00000000"

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
                        text: qsTr("Property:")
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        verticalAlignment: Text.AlignBottom
                    }

                    ListView
                    {
                        id: listView
                        anchors.fill: parent
                        anchors.topMargin: AppTheme.padding * 2 * app.scale
                        clip: true

                        delegate: Rectangle
                        {
                            color: "#00000000"
                            width: listView.width
                            height: AppTheme.rowHeightMin * app.scale

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontBigSize * app.scale
                                color: AppTheme.fontMainColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: name
                                opacity: (index === listView.currentIndex) ? AppTheme.opacityEnabled : AppTheme.opacityDisabled
                            }

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text: desc //formattedTime(param1)
                                opacity: (index === listView.currentIndex) ? AppTheme.opacityEnabled : AppTheme.opacityDisabled
                            }

                            Rectangle
                            {
                                id: rectLine
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: 1 * app.scale
                                color: AppTheme.blueColor
                                visible: index === listView.currentIndex
                            }

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked: listView.currentIndex = index
                            }
                        }

                        onCurrentIndexChanged:
                        {
                            showList(false)
                            sigSelectedIndexChanged(currentIndex)
                        }

                        ScrollBar.vertical: ScrollBar
                        {
                            policy: ScrollBar.AlwaysOn
                            parent: listView.parent
                            anchors.top: listView.top
                            anchors.left: listView.right
                            anchors.leftMargin: AppTheme.padding * app.scale
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
}
