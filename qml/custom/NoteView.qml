import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.1
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: noteView
    width: app.width
    height: 300 * app.scale

    property string imagesList: ""
    property alias noteText: textNoteDetailed.text
    property alias noteDate: textNoteDate.text

    ListModel { id: imagesListModel }

    onImagesListChanged:
    {
        imagesListModel.clear()

        var imgs = imagesList.split(";")

        for (var i = 0; i < imgs.length; i++)
            imagesListModel.append({"fileLink": imgs[i]})

        if(imagesListModel.count > 0)
        {
            imgCurrent.source = "file:///" + imagesListModel.get(0).fileLink
            //noteView.height = imgCurrent.height + AppTheme.rowHeight * 2 * app.scale
        }
    }

    Rectangle
    {
        id: rectNoteDetails
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Item
        {
            id: photoFrame
            width: rectNoteDetails.width
            height: rectNoteDetails.height

            Image
            {
                id: imgCurrent
                anchors.fill: parent

                onStatusChanged:
                {
                    if (status == Image.Ready)
                    {
                        var sc = sourceSize.width / photoFrame.width
                        photoFrame.height = sourceSize.height / sc
                        photoFrame.scale = 1

                        noteView.height = photoFrame.height + AppTheme.rowHeight * 2 * app.scale

                    }
                }
            }

            PinchArea
            {
                anchors.fill: parent
                pinch.target: photoFrame
                pinch.minimumRotation: 0
                pinch.maximumRotation: 0
                pinch.minimumScale: 1
                pinch.maximumScale: 4

                onPinchUpdated:
                {
                    if(photoFrame.x < dragArea.drag.minimumX)
                        photoFrame.x = dragArea.drag.minimumX
                    else if(photoFrame.x > dragArea.drag.maximumX)
                        photoFrame.x = dragArea.drag.maximumX

                    if(photoFrame.y < dragArea.drag.minimumY)
                        photoFrame.y = dragArea.drag.minimumY
                    else if(photoFrame.y > dragArea.drag.maximumY)
                        photoFrame.y = dragArea.drag.maximumY
                }

                MouseArea
                {
                    id: dragArea
                    hoverEnabled: true
                    anchors.fill: parent
                    drag.target: photoFrame
                    scrollGestureEnabled: false
                    drag.minimumX: (rectNoteDetails.width - (photoFrame.width * photoFrame.scale))/2
                    drag.maximumX: -(rectNoteDetails.width - (photoFrame.width * photoFrame.scale))/2
                    drag.minimumY: (rectNoteDetails.height - (photoFrame.height * photoFrame.scale))/2
                    drag.maximumY: -(rectNoteDetails.height - (photoFrame.height * photoFrame.scale))/2

                    onDoubleClicked:
                    {
                        photoFrame.x = 0
                        photoFrame.y = 0
                        photoFrame.scale = 1
                    }

                    onWheel:
                    {
                        var scaleBefore = photoFrame.scale
                        photoFrame.scale += photoFrame.scale * wheel.angleDelta.y / 120 / 10
                        if(photoFrame.scale < 1)
                            photoFrame.scale = 1
                        else if(photoFrame.scale > 4)
                            photoFrame.scale = 4

                        if(photoFrame.x < drag.minimumX)
                            photoFrame.x = drag.minimumX
                        else if(photoFrame.x > drag.maximumX)
                            photoFrame.x = drag.maximumX

                        if(photoFrame.y < drag.minimumY)
                            photoFrame.y = drag.minimumY
                        else if(photoFrame.y > drag.maximumY)
                            photoFrame.y = drag.maximumY
                    }
                }
            }
        }

        ListView
        {
            id: imagesPreviewList
            anchors.top: photoFrame.bottom
            anchors.topMargin: AppTheme.padding * app.scale + (photoFrame.scale - 1) * photoFrame.height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: imagesListModel.count * (AppTheme.compHeight + AppTheme.padding / 2) * app.scale
            height: AppTheme.compHeight * app.scale
            orientation: ListView.Horizontal
            spacing: AppTheme.padding / 2 * app.scale
            clip: true
            model: imagesListModel
            interactive: false

            Behavior on width
            {
                NumberAnimation { duration: 100 }
            }

            delegate: Rectangle
            {
                width: parent.height
                height: width
                radius: height / 2
                color: "#00000000"

                Image
                {
                    anchors.fill: parent
                    source: (fileLink === "") ? "" : "file:///" + fileLink
                    mipmap: true
                    layer.enabled: true
                    layer.effect: OpacityMask
                    {
                        maskSource: imgMask
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: imgCurrent.source = "file:///" + fileLink
                    }
                }

                Rectangle
                {
                    id: imgMask
                    anchors.fill: parent
                    radius: height/2
                    visible: false
                }
            }
        }

        Text
        {
            id: textNoteDetailed
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * 3 / 2 * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * 3 / 2 * app.scale
            anchors.top: imagesPreviewList.bottom
            anchors.topMargin: AppTheme.padding / 2 * app.scale
            height: contentHeight + AppTheme.padding * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.greyColor
            text: ""
            wrapMode: Text.WordWrap
        }

        Text
        {
            id: textNoteDate
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * 3 / 2 * app.scale
            anchors.top: textNoteDetailed.bottom
            anchors.topMargin: AppTheme.padding / 2 * app.scale
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.blueFontColor
            text: ""
        }
    }
}
