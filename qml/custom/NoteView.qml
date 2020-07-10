import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.1
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

    function showDetails(vis)
    {
        if (vis === true)
        {
            rectDetailedContainer.visible = true
            showDetailsAnimation.start()
        }
        else
            hideDetailsAnimation.start()
    }

    SequentialAnimation
    {
        id: showDetailsAnimation

        onStarted: rectDetailedContainer.visible = true

        NumberAnimation
        {
            target: rectDetailedContainer
            property: "opacity"
            duration: 200
            from: 0
            to: 1
            easing.type: Easing.InOutQuad
        }

        NumberAnimation
        {
            target: rectShadowNoteDetails
            property: "anchors.topMargin"
            duration: 200
            from: rectDetailedContainer.height
            to: AppTheme.padding * 9 * app.scale
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation
    {
        id: hideDetailsAnimation

        NumberAnimation
        {
            target: rectShadowNoteDetails
            property: "anchors.topMargin"
            duration: 200
            from: AppTheme.padding * 9 * app.scale
            to: rectDetailedContainer.height
            easing.type: Easing.InOutQuad
        }

        NumberAnimation
        {
            target: rectDetailedContainer
            property: "opacity"
            duration: 200
            from: 1
            to: 0
            easing.type: Easing.InOutQuad
        }

        onFinished: rectDetailedContainer.visible = false
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
        anchors.left: parent.left
        anchors.top: parent.top
        width: parent.width
        height: (textNote.contentHeight + AppTheme.padding * 4) * app.scale
        color: AppTheme.whiteColor

        Behavior on height {    NumberAnimation {   duration:  200 } }

        MouseArea
        {
            anchors.fill: parent
            onPressed: dragAnimation.start()
            onReleased: showDetails(true)
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
            height: (AppTheme.rowHeightMin + 2) * app.scale
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
                width: AppTheme.rowHeightMin * app.scale
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
            anchors.top: textNoteFound.bottom
            height: contentHeight + AppTheme.padding * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.greyColor
            text: ""
            wrapMode: Text.WordWrap
        }
    }


    Rectangle
    {
        id: rectDetailedContainer
        anchors.fill: parent
        parent: Overlay.overlay
        color: "#20000000"
        visible: false

        MouseArea { anchors.fill: parent    }

        Rectangle
        {
            id: rectShadowNoteDetails
            width: parent.width
            height: imgCurrent.height + AppTheme.rowHeight * 3 * app.scale
            radius: AppTheme.radius * 2 * app.scale
            anchors.top: parent.top
            anchors.topMargin: rectDetailedContainer.height
            anchors.bottom: parent.bottom
            color: AppTheme.whiteColor
            clip: true
        }

        DropShadow
        {
            anchors.fill: rectShadowNoteDetails
            horizontalOffset: 0
            verticalOffset: 3
            radius: 10.0 * app.scale
            samples: 16
            color: "#20000000"
            source: rectShadowNoteDetails
        }

        Rectangle
        {
            id: rectNoteDetails
            anchors.fill: rectShadowNoteDetails
            radius: AppTheme.radius * 2 * app.scale
            clip: true

            Behavior on height { NumberAnimation { duration: 200 } }

            onVisibleChanged:
            {
                textNoteDetailed.text = textNote.text

                if(listOfImages.count > 0)
                    imgCurrent.source = "file:///" + listOfImages.get(0).fileLink
            }

            Item
            {
                id: photoFrame
                anchors.top: parent.top
                width: parent.width
                height: 400

                Image
                {
                    id: imgCurrent
                    anchors.fill: parent
                    anchors.bottomMargin: 2

                    onStatusChanged:
                    {
                        if (status == Image.Ready)
                        {
                            var sc = sourceSize.width / photoFrame.width
                            photoFrame.height = sourceSize.height / sc
                            photoFrame.scale = 1
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
                id: detailedImagesListView
                anchors.top: photoFrame.bottom
                anchors.topMargin: AppTheme.padding * app.scale + (photoFrame.scale - 1) * photoFrame.height / 2
                anchors.horizontalCenter: parent.horizontalCenter
                width: listOfImages.count * (AppTheme.compHeight + AppTheme.padding / 2) * app.scale
                height: AppTheme.compHeight * app.scale
                orientation: ListView.Horizontal
                spacing: AppTheme.padding / 2 * app.scale
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
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                anchors.top: detailedImagesListView.bottom
                anchors.topMargin: AppTheme.padding / 2 * app.scale
                height: contentHeight + AppTheme.padding * app.scale
                verticalAlignment: Text.AlignVCenter
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: ""
                wrapMode: Text.WordWrap
            }

            IconSimpleButton
            {
                anchors.top: parent.top
                anchors.topMargin: rectDetailedContainer.height - AppTheme.rowHeight / 2 *  app.scale - AppTheme.rowHeight * 3 * app.scale
                anchors.horizontalCenter: parent.horizontalCenter
                image: "qrc:/resources/img/icon_ok.png"

                onSigButtonClicked: showDetails(false)
            }
        }
    }
}