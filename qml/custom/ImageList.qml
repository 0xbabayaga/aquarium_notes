import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtQuick.Dialogs 1.0
import "../"

Item
{
    id: imageList
    width: app.width
    height: AppTheme.rowHeightMin * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    property int imagesCountMax: 4
    property alias selectedImagesList: listOfImages
    property string galleryImageSelected: ""

    onGalleryImageSelectedChanged: if (galleryImageSelected !== "") addImageToList(galleryImageSelected)

    function reset()
    {
        listOfImages.clear()
        imagesListView.width = 0
    }

    function addImageToList(imgUrl)
    {
        if (listOfImages.count < imagesCountMax)
            listOfImages.append({ "fileLink": imgUrl,   "base64data": ""})

        resize()

        galleryImageSelected = ""
    }

    function addBase64ImageToList(img64)
    {
        if (listOfImages.count < imagesCountMax)
            listOfImages.append({ "fileLink": "",   "base64data": img64})

        resize()

        galleryImageSelected = ""
    }

    function removeImage(index)
    {
        if (index < listOfImages.count)
        {
            listOfImages.remove(index, 1)
            resize()
        }
    }

    function getSource(link, base64)
    {
        if (link !== "")
            return "file:///" + link
        else if (base64 !== "")
            return "data:image/png;base64," + base64
        else
            return ""
    }

    function resize()
    {
        imagesListView.width = listOfImages.count * (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
    }

    ListModel
    {
        id: listOfImages
    }

    ListView
    {
        id: imagesListView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 0
        height: parent.height
        orientation: ListView.Horizontal
        spacing: AppTheme.padding * app.scale
        clip: true
        model: listOfImages

        Behavior on width
        {
            NumberAnimation { duration: 100 }
        }

        delegate: Rectangle
        {
            width: imageList.height
            height: width
            radius: height / 2
            color: AppTheme.greyColor

            Image
            {
                anchors.fill: parent
                source: getSource(fileLink, base64data)
                mipmap: true
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: imgTankMask
                }
            }

            Rectangle
            {
                id: imgTankMask
                anchors.fill: parent
                radius: height/2
                visible: false
            }

            Rectangle
            {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 24 * app.scale
                height: width
                radius: width / 2
                color: AppTheme.blueColor

                Image
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: AppTheme.compHeight / 2 * app.scale
                    height: width
                    source: "qrc:/resources/img/icon_cancel.png"
                    mipmap: true

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked: imageList.removeImage(index)
                    }
                }
            }
        }
    }

    IconSimpleButton
    {
        id: buttonAddImage
        anchors.left: imagesListView.right
        image: "qrc:/resources/img/icon_photo.png"
        enabled: imagesListView.model.count < imageList.imagesCountMax

        onSigButtonClicked:
        {
            if (app.isAndro === true)
                app.sigOpenGallery()
            else
                fileDialog.open()
        }
    }

    FileDialog
    {
        id: fileDialog
        title: "Please choose an image"
        folder: shortcuts.pictures
        nameFilters: [ "Image files (*.jpg *.png)" ]
        visible: false

        onAccepted:
        {
            addImageToList(fileDialog.fileUrls[0].replace("file:///", ""))
            close()
        }

        onRejected: close()
    }
}
