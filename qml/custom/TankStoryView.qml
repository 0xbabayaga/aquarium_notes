import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/datetimeutility.js" as DateTimeUtils
import "../"

Item
{
    id: tankStoryView
    width: app.width

    property int tankImageHeight: 96
    property int currentViewIndex: 0

    signal sigTankStoryClose()
    signal sigTankStoryLoadIndex(int index)

    function addStoryRecord(smpId, desc, imageList, dt, params)
    {
        storyModel.append({"smpId": smpId, "desc": desc, "imgList": imageList, "dt": dt, "params": params})
    }

    onVisibleChanged: if (visible === true) sigTankStoryLoadIndex(0)

    ListModel { id: storyModel }

    Rectangle
    {
        id: rectHeaderShadow
        anchors.fill: parent
        anchors.leftMargin: AppTheme.padding * app.scale
        anchors.rightMargin: AppTheme.padding * app.scale
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

        ListView
        {
            id: view
            anchors.fill: parent
            anchors.topMargin: AppTheme.padding / 2 * app.scale
            orientation: ListView.Vertical
            model: storyModel
            clip: true
            cacheBuffer: 6000

            delegate: NoteView
            {
                id: noteView
                width: view.width
                imagesList: imgList
                noteText: desc
                noteDate: (new DateTimeUtils.DateTimeUtil()).printFullDate(dt)
                parameters: params
                isFirstOnList: (index === 0)
            }

            onAtYEndChanged:
            {
                sigTankStoryLoadIndex(view.model.count)
            }

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: view.parent
                anchors.top: view.top
                anchors.topMargin: AppTheme.compHeight * app.scale
                anchors.left: view.right
                anchors.leftMargin: AppTheme.padding / 4 * app.scale
                anchors.bottom: view.bottom
                anchors.bottomMargin: AppTheme.compHeight * app.scale

                contentItem: Rectangle
                {
                    implicitWidth: 2 * app.scale
                    implicitHeight: AppTheme.rowHeight * app.scale
                    radius: width / 2
                    color: AppTheme.hideColor
                }
            }
        }
    }
}
