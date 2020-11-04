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
    height: imagesListView.height
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    property int imagesCountMax: 4
    property alias selectedImagesList: listOfImages
    property string galleryImageSelected: ""
    property int inRowItemsCnt: 0

    signal sigImagesLimitReached(int max)

    onGalleryImageSelectedChanged: if (galleryImageSelected !== "") addImageToList(galleryImageSelected)

    Component.onCompleted:
    {
        inRowItemsCnt = (imageList.width - (AppTheme.rowHeightMin + 2 * AppTheme.padding) * app.scale) / ((AppTheme.rowHeightMin + AppTheme.padding) * app.scale)
        inRowItemsCnt = parseInt(inRowItemsCnt)
    }

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

            console.log("img cnt = ", listOfImages.count)
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
        if (listOfImages.count < inRowItemsCnt)
            imagesListView.width = listOfImages.count * (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
        else
            imagesListView.width = inRowItemsCnt * (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
    }

    function calcHeight()
    {
        var cnt = 0

        if (listOfImages.count > 0)
        {
            cnt = parseInt(listOfImages.count / (inRowItemsCnt + 1)) + 1

            return (AppTheme.rowHeightMin + AppTheme.padding) * cnt * app.scale
        }
        else
            return (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
    }

    ListModel
    {
        id: listOfImages
    }

    GridView
    {
        id: imagesListView
        anchors.left: parent.left
        anchors.top: parent.top
        width: 0
        height: calcHeight()
        contentHeight: height
        cellHeight: (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
        cellWidth: cellHeight
        clip: true
        model: listOfImages

        Behavior on width
        {
            NumberAnimation { duration: 100 }
        }

        delegate: Item
        {
            width: (AppTheme.rowHeightMin + AppTheme.padding) * app.scale
            height: (AppTheme.rowHeightMin + AppTheme.padding) * app.scale

            Rectangle
            {
                anchors.fill: parent
                anchors.rightMargin: AppTheme.padding * app.scale
                anchors.bottomMargin: AppTheme.padding * app.scale
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
    }

    IconSimpleButton
    {
        id: buttonAddImage
        anchors.left: imagesListView.right
        image: "qrc:/resources/img/icon_photo.png"

        onSigButtonClicked:
        {
            if (imagesListView.model.count < imageList.imagesCountMax)
            {
                if (app.isAndro === true)
                    app.sigOpenGallery()
                else
                    fileDialog.open()
            }
            else
                sigImagesLimitReached(imageList.imagesCountMax)
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
