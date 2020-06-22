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
    property alias maximumLength: textArea.maximumLength
    property alias validator: textArea.validator

    onFocusChanged:
    {
        if (focus === true)
        {
            textArea.forceActiveFocus()
            rectUnderLine.color = AppTheme.blueColor
        }
    }

    TextInput
    {
        id: textArea
        width: textInput.width
        height: textInput.height
        font.family: AppTheme.fontFamily
        font.pixelSize: AppTheme.fontNormalSize * app.scale
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: enabled ? AppTheme.blueColor : AppTheme.hideColor
        wrapMode: Text.WordWrap

        Text
        {
            text: textInput.placeholderText
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.greyColor
            height: parent.height
            visible: !textArea.text
        }

        onContentHeightChanged: textInput.height = contentHeight + AppTheme.padding * app.scale
        onFocusChanged: focus ? rectUnderLine.color = AppTheme.blueColor : rectUnderLine.color = AppTheme.hideColor
    }

    Rectangle
    {
        id: rectUnderLine
        anchors.top: textArea.bottom
        anchors.left: textArea.left
        anchors.right: textArea.right
        height: 1 * app.scale
        color: AppTheme.hideColor
        opacity: textInput.opacity
    }
}
