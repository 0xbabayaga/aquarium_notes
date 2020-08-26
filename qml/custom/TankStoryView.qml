import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: tankStoryView
    width: app.width

    //property alias currentIndex: view.currentIndex
    property int tankImageHeight: 180
    property int currentViewIndex: 0

    signal sigTankStoryClose()
    signal sigTankStoryLoadIndex(int index)

    function addStoryRecord(smpId, desc, imageList, dt)
    {
        storyModel.append({"smpId": smpId, "desc": desc, "imagesList": imageList, "dt": dt})
    }

    onVisibleChanged: if (visible === true) sigTankStoryLoadIndex(currentViewIndex)

    ListModel
    {
        id: storyModel

        ListElement {   smpId: 0;  desc: "Default";    imagesList: ""; dt: 1912341239;   }
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        MouseArea
        {
            anchors.fill: parent
            onClicked: sigTankStoryClose()
        }

        ListView
        {
            id: view
            anchors.fill: parent
            orientation: ListView.Vertical
            spacing: AppTheme.margin * app.scale
            model: storyModel
            clip: true

            delegate: Rectangle
            {
                width: parent.width
                height: tankImageHeight
                color: "#00000000"

                Behavior on height
                {
                    NumberAnimation
                    {
                        duration: 200
                        easing.type: Easing.OutExpo
                    }
                }

                Rectangle
                {
                    id: rect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.rightMargin: AppTheme.padding * app.scale
                    anchors.top: parent.top
                    color: AppTheme.whiteColor
                    height: parent.height
                }

                DropShadow
                {
                    anchors.fill: rect
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: AppTheme.shadowSize * app.scale
                    samples: AppTheme.shadowSamples
                    color: AppTheme.shadowColor
                    source: rect
                }

                Rectangle
                {
                    anchors.fill: rect
                    color: AppTheme.whiteColor

                    Text
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.padding * app.scale
                        anchors.top: parent.top
                        anchors.topMargin: AppTheme.padding * app.scale
                        text: smpId
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                    }

                }
            }

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: view.parent
                anchors.top: view.top
                anchors.left: view.right
                anchors.leftMargin: -AppTheme.margin / 3 * app.scale
                anchors.bottom: view.bottom

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
