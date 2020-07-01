import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtMultimedia 5.11
import "../"
import "../custom"

Item
{
    id: dialogAddImage
    width: app.width
    height: app.height

    signal sigCancel()
    signal sigOk()

    function show(visible)
    {
        if (visible === true)
        {
            showDialogAnimation.start()
            rectFakeDataContainer.anchors.topMargin = AppTheme.padding * 9 * app.scale
        }
        else
        {
            rectFakeDataContainer.anchors.topMargin = rectContainer.height
            hideDialogAnimation.start()
        }
    }

    function showCameraFrame(visible)
    {
        if (visible === true)
        {
            rectCamera.anchors.horizontalCenterOffset = 0
            rectCamera.width = 300 * app.scale
        }
        else
        {
            rectCamera.anchors.horizontalCenterOffset = width + AppTheme.padding * app.scale
            rectCamera.width = AppTheme.rowHeight * app.scale
        }
    }

    NumberAnimation
    {
        id: showDialogAnimation
        target: rectContainer
        property: "opacity"
        duration: 100
        from: 0
        to: 1
        easing.type: Easing.InOutQuad
        onStarted: rectContainer.visible = true
    }

    NumberAnimation
    {
        id: hideDialogAnimation
        target: rectContainer
        property: "opacity"
        duration: 100
        from: 1
        to: 0
        easing.type: Easing.InOutQuad
        onStopped: rectContainer.visible = false
    }


    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        parent: Overlay.overlay
        color: "#20000000"
        opacity: 0
        visible: false

        MouseArea { anchors.fill: parent }

        Rectangle
        {
            id: rectFakeDataContainer
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: 200 * app.scale
            width: parent.width - AppTheme.padding * app.scale
            radius: AppTheme.radius * 2 * app.scale
        }

        Rectangle
        {
            id: rectDataContainer
            anchors.fill: rectFakeDataContainer
            radius: AppTheme.radius * 2 * app.scale

            Rectangle
            {
                id: rectAddRecordDialog
                anchors.fill: parent
                anchors.topMargin: AppTheme.padding * app.scale
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.rightMargin: AppTheme.padding * app.scale
                color: AppTheme.whiteColor

                Text
                {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    height: AppTheme.rowHeightMin * app.scale
                    width: 100 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueColor
                    text: qsTr("Select an image source")
                }

                Rectangle
                {
                    id: rectCamera
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: width + AppTheme.padding * app.scale
                    width: AppTheme.rowHeight * app.scale
                    height: width
                    color: "#40003000"

                    Behavior on anchors.horizontalCenterOffset
                    {
                        NumberAnimation { duration: 200 }
                    }

                    Behavior on width
                    {
                        NumberAnimation { duration: 200 }
                    }

                    Camera
                    {
                        id: camera
                        imageCapture
                        {
                            onImageCaptured:
                            {
                                // Show the preview in an Image
                                photoPreview.source = preview
                            }
                        }
                    }

                    VideoOutput
                    {
                        source: camera
                        focus : visible // to receive focus and capture key events when visible
                        anchors.fill: parent
                        autoOrientation: true

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked: camera.imageCapture.capture()
                        }
                    }

                    Image
                    {
                        id: photoPreview
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            visible = false
                            dialogAddImage.showCameraFrame(true)
                        }
                    }
                }

                Rectangle
                {
                    id: rectGallery
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: - width - AppTheme.padding * app.scale
                    width: AppTheme.rowHeight * app.scale
                    height: width
                    color: "#40000030"
                }

                /*
                IconSimpleButton
                {
                    id: buttonCancel
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.left: parent.left
                    image: "qrc:/resources/img/icon_cancel.png"

                    onSigButtonClicked:
                    {
                        dialogAddParamNote.show(false)
                        sigCancel()
                    }
                }

                IconSimpleButton
                {
                    id: buttonAdd
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.right: parent.right
                    image: "qrc:/resources/img/icon_ok.png"

                    onSigButtonClicked:
                    {
                        dialogAddParamNote.show(false)
                        sigOk()
                    }
                }
                */
            }
        }
    }
}
