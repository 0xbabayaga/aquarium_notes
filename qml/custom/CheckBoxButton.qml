import QtQuick 2.12
import QtQuick.Controls 2.12
import "../"

Item
{
    id: checkBoxButton
    width: 24 * app.scale
    height: 24 * app.scale

    property bool checked: false

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        radius: width / 2
        color: (checkBoxButton.checked === true) ? AppTheme.blueColor : AppTheme.whiteColor
        border.color: AppTheme.blueColor
        border.width: 2 * app.scale

        Image
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 16 * app.scale
            height: width
            source: "qrc:/resources/img/icon_ok.png"
            mipmap: true
        }

        Behavior on color
        {
            ColorAnimation {}
        }

        MouseArea
        {
            anchors.fill: parent
            onPressed: scaleAnimation2.start()
            onReleased:
            {
                checkedChanged()
                checkBoxButton.checked = !checkBoxButton.checked
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
