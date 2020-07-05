import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
//import QtQuick.Dialogs 1.3
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

    function addImageToList(imgUrl)
    {
        if (listOfImages.count < imagesCountMax)
            listOfImages.append({ "fileLink": imgUrl})

        galleryImageSelected = ""

        imagesListView.width = listOfImages.count * AppTheme.rowHeightMin * app.scale

        if (listOfImages.count > 1)
            imagesListView.width += (listOfImages.count - 1) * AppTheme.padding * app.scale
    }

    ListModel
    {
        id: listOfImages
    }

    ListView
    {
        id: imagesListView
        width: 0
        height: parent.height
        orientation: ListView.Horizontal
        spacing: AppTheme.padding * app.scale
        clip: true
        model: listOfImages

        delegate: Rectangle
        {
            width: imageList.height
            height: width
            radius: height / 2
            color: AppTheme.greyColor

            Image
            {
                anchors.fill: parent
                source: (fileLink === "") ? "" : "file:///" + fileLink
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
        }
    }

    IconSimpleButton
    {
        id: buttonAddImage
        anchors.left: imagesListView.right
        anchors.leftMargin: AppTheme.padding * app.sacle
        image: "qrc:/resources/img/icon_photo.png"

        onSigButtonClicked: app.sigOpenGallery()
        //onSigButtonClicked: fileDialog.open()

    }

    /*
    FileDialog
    {
        id: fileDialog
        title: "Please choose an image"
        folder: shortcuts.home
        nameFilters: [ "Image files (*.jpg *.png)", "All files (*)" ]

        onAccepted:
        {
            addImageToList(fileDialog.fileUrls)

            console.log("You chose: " + fileDialog.fileUrls)
            close()
        }

        onRejected: close()

        Component.onCompleted: visible = true
    }
    */
}
