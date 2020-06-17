import QtQuick 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: iconSmallSimpleButton
    width: AppTheme.compHeight * app.scale
    height: AppTheme.compHeight * app.scale

    property alias image: buttonImage.source

    signal sigButtonClicked()

    Rectangle
    {
        id: rectContainer

        anchors.fill: parent
        color: "#00000000"

        Behavior on color
        {
            NumberAnimation {   duration: 200 }
        }

        Image
        {
            id: buttonImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: AppTheme.rowHeightMin / 2 * app.scale
            height: width
            source: "qrc:/resources/img/icon_cancel.png"
            mipmap: true
        }

        ColorOverlay
        {
            id: arrowOverlay
            anchors.fill: buttonImage
            source: buttonImage
            color: AppTheme.blueColor
        }

        MouseArea
        {
            anchors.fill: parent
            onPressed: scaleAnimation2.start()
            onReleased: iconSmallSimpleButton.sigButtonClicked()
        }
    }

    ScaleAnimator
    {
        id: scaleAnimation2
        target: rectContainer
        from: 1
        to: 0.95
        easing.type: Easing.OutBack
        duration: 100
        running: false
        onFinished: scaleAnimation1.start()
    }

    ScaleAnimator
    {
        id: scaleAnimation1
        target: rectContainer
        from: 0.95
        to: 1
        easing.type: Easing.OutBack
        duration: 500
        running: false
    }
}
