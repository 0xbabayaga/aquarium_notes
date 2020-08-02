import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: tanksList
    height: 96 * app.scale
    width: (model) ? ((model.length > 2) ? app.width + AppTheme.margin * app.scale * 4 : 360 * app.scale) : app.width

    property alias model: view.model
    property alias currentIndex: view.currentIndex

    signal sigCurrentIndexChanged(int id)
    signal sigDoubleClicked(int id)

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
                height: 96 * app.scale
                scale: PathView.iconScale
                z: PathView.z

                Rectangle
                {
                    id: rect
                    anchors.fill: parent
                    //radius: AppTheme.radius/2 * app.scale
                    color: AppTheme.whiteColor
                    clip: true
                }

                DropShadow
                {
                    anchors.fill: rect
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: 16.0
                    samples: 16
                    color: "#60000000"
                    source: rect
                }


                Rectangle
                {
                    anchors.fill: rect
                    radius: AppTheme.radius/2 * app.scale
                    color: (view.currentIndex === index) ? AppTheme.whiteColor : ((type === 0) ? AppTheme.lightBlueColor : AppTheme.lightGreenColor)
                    clip: true

                    Image
                    {
                        id: imgPhoto
                        width: parent.width
                        height: parent.height
                        anchors.bottom: parent.bottom
                        source: (img.length > 0) ? "data:image/jpg;base64," + img : ""
                        mipmap: true
                        opacity: 0.87
                    }

                    Image
                    {
                        id: imgWave
                        width: parent.width
                        height: parent.width/3
                        //fillMode: Image.PreserveAspectFit
                        anchors.bottom: parent.bottom
                        source: (type < 4) ? "qrc:/resources/img/wave_blue_2.png" : "qrc:/resources/img/wave_green_2.png"
                        mipmap: true
                        opacity: 0.8
                    }

                    /*
                    Text
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.padding/2 * app.scale
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.padding/2 * app.scale
                        text: name
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
                        color: (type < 4) ? AppTheme.whiteColor : AppTheme.whiteColor
                        verticalAlignment: Text.AlignBottom
                        height: AppTheme.compHeight * app.scale
                    }
                    */

                    Text
                    {
                        anchors.right: parent.right
                        anchors.rightMargin: AppTheme.padding/2 * app.scale
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: AppTheme.padding/2 * app.scale
                        text: Math.ceil(volume) + "L"
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.whiteColor
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                        height: AppTheme.compHeight * app.scale
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onDoubleClicked:
                        {
                            view.currentIndex = index
                            sigDoubleClicked(index)
                        }

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
            delegate: delegate

            path: Path
            {
                startX: 0
                startY: view.height * 1.20

                PathAttribute { name: "iconScale"; value: 0.75 }
                PathAttribute { name: "z"; value: 0 }
                PathLine {x: view.width/2; y: view.height }
                PathAttribute { name: "iconScale"; value: 1.25 }
                PathAttribute { name: "iconOpacity"; value: 1 }
                PathAttribute { name: "z"; value: 1 }
                PathLine {x: view.width; y: view.height * 1.20 }
            }

            onCurrentIndexChanged: sigCurrentIndexChanged(currentIndex)
        }
    }
}
