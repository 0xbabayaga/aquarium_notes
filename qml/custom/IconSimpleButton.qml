import QtQuick 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: iconSimpleButton
    width: AppTheme.rowHeightMin * app.scale
    height: AppTheme.rowHeightMin * app.scale

    property alias image: buttonImage.source

    signal sigButtonClicked()

    Rectangle
    {
        id: rectContainer

        anchors.fill: parent
        radius: width/2
        color: "#00000000"

        Image
        {
            id: buttonImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: AppTheme.rowHeight / 2 * app.scale
            height: width
            source: "qrc:/resources/img/icon_plus.png"
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
            onPressed:
            {
                scaleAnimation2.start()
                rectContainer.color = AppTheme.shideColor
            }
            onReleased:
            {
                rectContainer.color = "#00000000"
                iconSimpleButton.sigButtonClicked()
            }
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
