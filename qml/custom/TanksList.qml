import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: tanksList
    height: 128 * app.scale
    width: (view.model.count > 2) ? app.width + AppTheme.margin * app.scale * 4 : 360 * app.scale

    property alias tanksListModel: view.model
    property alias currentIndex: view.currentIndex

    signal sigCurrentIndexChanged(int id)

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Component
        {
            id: delegate

            Item
            {
                id: itemContainer
                width: 128 * app.scale
                height: 128 * app.scale
                scale: PathView.iconScale

                Rectangle
                {
                    id: rect
                    anchors.fill: parent
                    radius: AppTheme.radius * app.scale
                    color: AppTheme.whiteColor
                    clip: true
                }

                DropShadow
                {
                    anchors.fill: rect
                    horizontalOffset: 0
                    verticalOffset: -3
                    radius: 16.0
                    samples: 16
                    color: "#40000000"
                    source: rect
                }


                Rectangle
                {
                    anchors.fill: rect
                    radius: AppTheme.radius * app.scale
                    color: (view.currentIndex === index) ? AppTheme.whiteColor : ((type === 0) ? AppTheme.lightBlueColor : AppTheme.lightGreenColor)
                    clip: true

                    Text
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.padding * app.scale
                        anchors.right: parent.right
                        anchors.top: parent.top
                        text: name
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSmallSize * app.scale
                        color: (type === 0) ? AppTheme.blueColor : AppTheme.greenColor
                        verticalAlignment: Text.AlignBottom
                        height: AppTheme.compHeight * app.scale
                    }

                    Image
                    {
                        id: imgWave
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        anchors.bottom: parent.bottom
                        source: (type === 0) ? "qrc:/resources/img/wave_blue.png" : "qrc:/resources/img/wave_green.png"
                        mipmap: true


                    }

                    Text
                    {
                        anchors.right: parent.right
                        anchors.rightMargin: AppTheme.padding * app.scale
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        text: volume + "L"
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.whiteColor
                        horizontalAlignment: Text.AlignRight
                        height: AppTheme.compHeight * app.scale
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            view.currentIndex = index
                            sigCurrentIndexChanged(index)
                        }
                    }
                }
            }
        }

        PathView
        {
            id: view
            anchors.fill: parent
            pathItemCount: 5
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            model: contactModel
            delegate: delegate

            path: Path
            {
                startX: 0
                startY: view.height * 1.25

                PathAttribute { name: "iconScale"; value: 0.75 }
                PathAttribute { name: "iconOrder"; value: 0 }
                PathLine {x: view.width/2; y: view.height }
                PathAttribute { name: "iconScale"; value: 1.25 }
                PathAttribute { name: "iconOpacity"; value: 1 }
                PathLine {x: view.width; y: view.height * 1.25 }
            }

            onCurrentIndexChanged: sigCurrentIndexChanged(currentIndex)
        }
    }
}
