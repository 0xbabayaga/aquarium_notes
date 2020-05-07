import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: currentParamsTable

    property alias model: curParamsListView.model

    onModelChanged: currParamsMainTable.height = (model.length + 1) * AppTheme.compHeight * app.scale

    Behavior on height
    {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    function formattedValue(val)
    {
        var str = ""

        if (val !== -1)
        {
            if (val > 50)
                str += Math.round(val)
            else
                str += Math.round(val * 100) / 100
        }
        else
            str = "-"

        return str
    }

    function formattedDiffValue(val_prev, val_curr)
    {
        var str = ""

        if (val_curr !== -1 && val_prev !== -1)
        {
            if (val_curr > val_prev)
                str = "+"

            str += Math.round((val_curr - val_prev) * 100) / 100
        }
        else
            str = "-"

        return str
    }

    function formattedValueStatus(val, min, max)
    {
        var str = ""

        //if ()
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        ListView
        {
            id: curParamsListView
            anchors.fill: parent
            spacing: 0

            delegate: Rectangle
            {
                width: parent.width
                height: AppTheme.compHeight * app.scale
                color: "#00000000"

                Row
                {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                        width: 120 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: app.getParamById(paramId).fullName
                    }

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                        width: 80 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: app.getParamById(paramId).unitName
                    }

                    Text
                    {
                        width: 50 * app.scale
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: formattedValue(valueNow)
                    }

                    Text
                    {
                        width: 60 * app.scale
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: (valueNow === -1) ? "-" : "Good"
                    }
                }

                Rectangle
                {
                    width: parent.width
                    height: 1 * app.scale
                    anchors.bottom: parent.bottom
                    color: ((index + 1) === curParamsListView.model.count) ? "#00000000" : AppTheme.shideColor
                }
            }
        }
    }
}
