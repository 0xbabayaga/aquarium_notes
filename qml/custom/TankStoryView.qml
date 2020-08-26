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

    signal sigTankStoryClose()

    Rectangle
    {
        anchors.fill: parent
        color: "#20000000"

        MouseArea
        {
            anchors.fill: parent
            onClicked: sigTankStoryClose()
        }

        /*
        ListView
        {
            id: view
            anchors.fill: parent
            orientation: ListView.Vertical
            spacing: AppTheme.margin * app.scale
            clip: true

            delegate: Rectangle
            {
                width: parent.width
                height: (index === view.currentIndex) ? (tankListView.tankImageHeight * app.scale + (currParamTable.realModelLength() * AppTheme.compHeight + AppTheme.rowHeightMin + AppTheme.padding/2) * app.scale) : tankListView.tankImageHeight * app.scale
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
                    color: "#20000000"


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
        */
    }
}
