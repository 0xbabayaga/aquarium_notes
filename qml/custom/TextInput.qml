import QtQuick 2.0
import QtQuick.Controls 2.12
import "../"

Item
{
    id: textInput
    width: 150 * app.scale
    height: AppTheme.compHeight * app.scale
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    property alias text: textArea.text
    property alias echoMode: textArea.echoMode
    property string placeholderText: "sometext"

    TextInput
    {
        id: textArea
        width: textInput.width
        height: textInput.height
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        horizontalAlignment: Text.AlignLeft
        color: enabled ? AppTheme.blueColor : AppTheme.hideColor

        Text
        {
            text: textInput.placeholderText
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.hideColor
            visible: !textArea.text
        }
    }

    Rectangle
    {
        id: rectUnderLine
        anchors.top: textArea.bottom
        anchors.left: textArea.left
        anchors.right: textArea.right
        height: 1 * app.scale
        color: textArea.enabled ? AppTheme.blueColor : AppTheme.hideColor
        opacity: textInput.opacity
    }
}
