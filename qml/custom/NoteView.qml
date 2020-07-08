import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: noteView
    visible: false
    opacity: 0

    property bool   isOpened: false
    property alias  noteText: textNote.text
    property string noteImages: ""

    ListModel { id: listOfImages }

    function hide()
    {
        hideAnimation.stop()
        showAnimation.stop()

        hideAnimation.start()
    }

    function getImages()
    {
        var imgs = []

        listOfImages.clear()

        imgs = noteImages.split(';')

        for (var i = 0; i < imgs.length; i++)
            listOfImages.append( { "fileLink": imgs[i] })

        if (imgs.length === 0)
            imagesListView.width = 0
        else if (imgs.length === 1)
            imagesListView.width = AppTheme.rowHeightMin * app.scale
        else
            imagesListView.width = AppTheme.rowHeightMin * app.scale + (imgs.length - 1) * AppTheme.rowHeightMin / 4  * app.scale
    }

    SequentialAnimation
    {
        id: dragAnimation

        ScaleAnimator
        {
            target: noteView
            from: 1
            to: 0.95
            easing.type: Easing.OutBack
            duration: 100
            running: false
        }

        ScaleAnimator
        {
            target: noteView
            from: 0.95
            to: 1
            easing.type: Easing.OutBack
            duration: 500
            running: false
        }
    }

    NumberAnimation
    {
        id: hideAnimation
        target: noteView
        property: "opacity"
        duration: 200
        from: 1
        to: 0
        easing.type: Easing.InOutQuad
        onFinished:
        {
            noteView.visible = false

            if (noteText.length > 0)
            {
                getImages()
                showAnimation.start()
            }
        }
    }

    NumberAnimation
    {
        id: showAnimation
        target: noteView
        property: "opacity"
        duration: 200
        from: 0
        to: 1
        easing.type: Easing.InOutQuad
        onStarted: noteView.visible = true
    }

    Rectangle
    {
        id: rectNoteFound
        anchors.fill: parent
        height: (AppTheme.rowHeight + AppTheme.compHeight) * app.scale
        color: AppTheme.backLightBlueColor

        MouseArea
        {
            anchors.fill: parent
            onPressed: dragAnimation.start()
        }

        Text
        {
            id: textNoteFound
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("NOTE FOUND")
        }

        Rectangle
        {
            anchors.top: textNoteFound.bottom
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: imagesListView.left
            anchors.rightMargin: AppTheme.padding * app.scale
            height: 1 * app.scale
            color: AppTheme.backLightBlueColor
        }

        ListView
        {
            id: imagesListView
            anchors.top: parent.top
            anchors.topMargin: AppTheme.compHeight * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            width: 0
            height: AppTheme.rowHeightMin * app.scale
            orientation: ListView.Horizontal
            spacing: -AppTheme.rowHeightMin * 3 / 4 * app.scale
            clip: true
            model: listOfImages
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
                color: AppTheme.lightBlueColor


                Image
                {
                    anchors.fill: parent
                    anchors.leftMargin: 2 * app.scale
                    anchors.rightMargin: 2 * app.scale
                    anchors.topMargin: 2 * app.scale
                    anchors.bottomMargin: 2 * app.scale
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

        Rectangle
        {
            id: imgNotePhotoMask
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: AppTheme.compHeight * app.scale
            height: AppTheme.rowHeight * app.scale
            width: height
            radius: height / 2
            visible: false
        }

        Text
        {
            id: textNote
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: imagesListView.left
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.verticalCenter: imagesListView.verticalCenter
            height: contentHeight + AppTheme.padding * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.greyColor
            text: ""
            wrapMode: Text.WordWrap
        }
    }
}
