import QtQuick 2.12
import QtGraphicalEffects 1.12
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

        Rectangle
        {
            id: rectContainerShadow
            anchors.fill: parent
            radius: width/2
            color: AppTheme.blueColor
        }

        DropShadow
        {
            anchors.fill: rectContainerShadow
            horizontalOffset: 0
            verticalOffset: 2 * app.scale
            radius: 14.0 * app.scale
            samples: 20
            color: "#40000000"
            source: rectContainerShadow
        }

        Rectangle
        {
            anchors.fill: rectContainerShadow
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
