import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: tankStoryView
    width: app.width

    property int tankImageHeight: 96
    property int currentViewIndex: 0

    signal sigTankStoryClose()
    signal sigTankStoryLoadIndex(int index)

    function addStoryRecord(smpId, desc, imageList, dt)
    {
        storyModel.append({"smpId": smpId, "desc": desc, "imgList": imageList, "dt": dt})
    }

    Component.onCompleted: console.log("OnCompleted ", view.width, view.height)

    onVisibleChanged: if (visible === true) sigTankStoryLoadIndex(0)

    ListModel { id: storyModel }

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

            delegate: NoteView
            {
                id: noteView
                width: view.width
                imagesList: imgList
                noteText: desc
                noteDate: dt

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        view.currentIndex = index
                        sigTankStoryLoadIndex(index + 1)
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
