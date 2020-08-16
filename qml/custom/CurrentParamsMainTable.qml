import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/datetimeutility.js" as DateTimeUtils
import "../"

Item
{
    id: currentParamsTable

    property alias model: curParamsListView.model
    property var dtUtils: 0

    onModelChanged:
    {
        if (dtUtils === 0)
            dtUtils = new DateTimeUtils.DateTimeUtil()

        if (model.length > 0)
            textTableHeader.text = qsTr("LAST MEASURED") + " [" + dtUtils.printDate(curParamsListView.model[0].dtNow)+ "]"
        else
            textTableHeader.text = qsTr("No data found for this aquarium")

        currParamsMainTable.height = (currentParamsTable.realModelLength() + 1) * AppTheme.compHeight * app.scale
    }

    Behavior on height
    {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    function realModelLength()
    {
        var size = 0

        if (curParamsListView.model)
        {
            for (var i = 0; i < curParamsListView.model.length; i++)
            {
                if (model[i].en === true)
                    size++
            }
        }

        return size
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
            return AppTheme.positiveChangesColor
        else
            return AppTheme.negativeChangesColor
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectMainTableHeader
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.top: parent.top
            height: AppTheme.rowHeightMin * app.scale
            color: "#00000000"

            Text
            {
                id: textTableHeader
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                width: parent.width
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontNormalSize * app.scale
                color: AppTheme.greyColor
                text: qsTr("LAST MEASURED")
                wrapMode: Text.WordWrap
            }
        }

        ListView
        {
            id: curParamsListView
            anchors.fill: parent
            anchors.topMargin: rectMainTableHeader.height
            spacing: 0
            interactive: false

            delegate: Rectangle
            {
                width: parent.width
                height: en ? AppTheme.compHeight * app.scale : 0
                visible: en
                color: (index%2 === 0) ? AppTheme.backLightBlueColor : "#00000000"

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
                        color: AppTheme.blueColor
                        text: formattedValue(valueNow)
                    }

                    Rectangle
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 12 * app.scale
                        height: width
                        radius: height/2
                        color: formattedColor(paramId, valueNow)
                    }
                }
            }
        }
    }
}
