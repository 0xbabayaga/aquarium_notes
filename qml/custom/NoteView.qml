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
    property var parameters: []

    ListModel { id: imagesListModel }
    ListModel { id: paramsModel }

    Behavior on height { NumberAnimation { duration: 200 } }

    onImagesListChanged:
    {
        imagesListModel.clear()
        paramsModel.clear()

        console.log("Changeds = ", noteDate, imagesList)

        var imgs = imagesList.split(";")

        for (var i = 0; i < imgs.length; i++)
            imagesListModel.append({"fileLink": imgs[i]})

        if(imagesListModel.count > 0)
        {
            imgCurrent.source = "file:///" + imagesListModel.get(0).fileLink
            imgCurrent.height = 0
            noteView.height = textNoteDetailed.contentHeight + AppTheme.rowHeight * 2 * app.scale
        }

        for (var pt in params)
            paramsModel.append({"name": app.getParamById(parseInt(pt)).shortName, "value": parseFloat(params[pt]), "unit": app.getParamById(parseInt(pt)).unitName })
    }

    Rectangle
    {
        id: rectNoteDetails
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Image
        {
            id: imgCurrent
            width: parent.width
            mipmap: true
            fillMode: Image.PreserveAspectFit

            Behavior on height { NumberAnimation { duration: 200 } }

            onStatusChanged:
            {
                if (status == Image.Ready)
                {
                    var sc = sourceSize.width / imgCurrent.width
                    imgCurrent.height = sourceSize.height / sc
                    noteView.height = sourceSize.height / sc + textNoteDetailed.contentHeight + AppTheme.rowHeight * 2 * app.scale
                }
            }
        }

        ListView
        {
            id: imagesPreviewList
            anchors.top: imgCurrent.bottom
            anchors.topMargin: AppTheme.padding * app.scale
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
