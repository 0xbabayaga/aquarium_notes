import QtQuick 2.12
import "../"

Item
{
    id: urlButton
    width: 100 * app.scale
    height: AppTheme.compHeight * app.scale
    property string buttonText: qsTr("Ok")

    signal sigButtonClicked()

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        color: "#00000000"

        Text
        {
            id: text
            text: buttonText
            wrapMode: Text.WordWrap
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.Center
            color: AppTheme.greyColor
            font.underline: true
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            font.family: AppTheme.fontFamily
        }

        MouseArea
        {
            anchors.fill: parent
            onClicked: urlButton.sigButtonClicked()
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
