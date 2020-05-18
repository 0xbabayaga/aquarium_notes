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

    function formattedColor(paramId, val)
    {
        var min = app.getParamById(paramId).min
        var max = app.getParamById(paramId).max

        if (val >= min && val <= max)
            return "#A000C000"
        else
            return "#A0C00000"
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectMainTableHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: AppTheme.compHeight * app.scale
            color: "#00000000"

            Text
            {
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                width: 80 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("LAST MEASURED: ")
            }

            Text
            {
                anchors.right: parent.right
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: "[" +app.printDate(curParamsListView.model[0].dtNow)+ "]"
            }
        }

        ListView
        {
            id: curParamsListView
            anchors.fill: parent
            anchors.topMargin: rectMainTableHeader.height
            spacing: 0

            delegate: Rectangle
            {
                width: parent.width
                height: AppTheme.compHeight * app.scale
                //color: "#00000000"
                color: (index%2 === 0) ? "#2000adbc" : "#0000adbc"

                Row
                {
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.right: parent.right

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                        width: 140 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: app.getParamById(paramId).fullName
                    }

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        height: AppTheme.compHeight * app.scale
                        width: 50 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: app.getParamById(paramId).unitName
                    }

                    Text
                    {
                        width: 90 * app.scale
                        height: AppTheme.compHeight * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        font.bold: true
                        color: AppTheme.blueColor
                        text: formattedValue(valueNow)
                    }

                    Rectangle
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12 * app.scale
                        height: width
                        radius: height/2
                        color: formattedColor(paramId, valueNow) //AppTheme.hideColor
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
