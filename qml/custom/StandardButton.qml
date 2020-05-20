import QtQuick 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: standardButton
    width: 100 * app.scale
    height: AppTheme.compHeight * app.scale
    property alias bText: buttonText.text

    signal sigButtonClicked()

    Rectangle
    {
        id: rectContainer

        anchors.fill: parent
        radius: width/2
        color: AppTheme.blueColor

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
            verticalOffset: 0
            radius: 14.0
            samples: 20
            color: "#40000000"
            source: rectContainerShadow
        }

        Rectangle
        {
            id: rectCont
            anchors.fill: parent
            radius: width/2
            color: AppTheme.blueColor

            Text
            {
                id: buttonText
                text: qsTr("Ok")
                wrapMode: Text.WordWrap
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.Center
                color: AppTheme.whiteColor
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                font.family: AppTheme.fontFamily
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked: standardButton.sigButtonClicked()
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
