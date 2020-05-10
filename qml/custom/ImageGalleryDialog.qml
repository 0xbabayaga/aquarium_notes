import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: imageGalleryDialog
    width: 150 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    signal sigSelectedIndexChanged(int id)

    property int currentIndex: listView.currentIndex
    property alias propertyName: textPropertyName.text
    property alias model: listView.model
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
                        color: AppTheme.greyDarkColor
                        verticalAlignment: Text.AlignBottom
                    }

                    GridView
                    {
                        id: listView
                        anchors.fill: parent
                        anchors.topMargin: AppTheme.padding * 2 * app.scale
                        clip: true
                        cellWidth: width/3
                        cellHeight: cellWidth
                        focus: true


                        delegate: Rectangle
                        {
                            color: "#00000000"
                            width: listView.cellWidth
                            height: listView.cellWidth

                            Rectangle
                            {
                                anchors.fill: parent
                                anchors.margins: 4 * app.scale
                                color: "#00000000"

                                Image
                                {
                                    anchors.fill: parent
                                    source: "file:///" + fileLink
                                    //mipmap: true
                                }

                                MouseArea
                                {
                                    anchors.fill: parent
                                    onClicked: listView.currentIndex = index
                                }
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
