import QtQuick 2.12
import "../"

Item
{
    id: iconButton
    width: AppTheme.rowHeightMin * app.scale
    height: AppTheme.rowHeightMin * app.scale

    signal sigButtonClicked()

    Rectangle
    {
        id: rectContainer

        anchors.fill: parent
        radius: width/2
        color: AppTheme.blueColor

        Image
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: AppTheme.rowHeight / 2 * app.scale
            height: width
            source: "qrc:/resources/img/icon_plus.png"
            mipmap: true
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: iconButton.sigButtonClicked()
            onPressed: scaleAnimation2.start()
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
