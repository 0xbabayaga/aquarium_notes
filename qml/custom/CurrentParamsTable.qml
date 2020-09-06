import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../../js/datetimeutility.js" as DateTimeUtils
import "../"

Item
{
    id: currentParamsTable

    property alias model: curValuesListView.model

    function realModelLength()
    {
        var size = 0

        if (curValuesListView.model)
            for (var i = 0; i < curValuesListView.model.length; i++)
            {
                if (model[i].en === true)
                    size++
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

    function paramProgressState(paramId, val, prevVal)
    {
        var min = app.getParamById(paramId).min
        var max = app.getParamById(paramId).max
        var color = ""
        var sign = ""

        if (val !== -1 && prevVal !== -1)
        {
            if (val > prevVal)
            {
                sign = "\u2197"

                if (val > 0.75 * (max - min) + min)
                    color = AppTheme.negativeChangesColor
                else if (val < 0.25 * (max - min) + min)
                    color = AppTheme.negativeChangesColor
                else
                    color = AppTheme.positiveChangesColor
            }
            else if (val < prevVal)
            {
                sign = "\u2199"

                if (val > 0.25 * (max - min) + min)
                    color = AppTheme.positiveChangesColor
                else
                    color = AppTheme.negativeChangesColor
            }
            else
            {
                sign = "-"
                color = AppTheme.greyColor
            }

            return [sign, color]
        }
        else
            return ["-", AppTheme.greyColor]
    }

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        ListView
        {
            id: curValuesListView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: AppTheme.compHeight * app.scale
            spacing: 0
            interactive: false

            onModelChanged:
            {
                height = realModelLength() * AppTheme.compHeight * app.scale

                noteViewDialog.hide()

                if (curValuesListView.model.length > 0)
                {
                    noteViewDialog.noteText = curValuesListView.model[0].note
                    noteViewDialog.noteImages = curValuesListView.model[0].imgLink
                }
            }

            delegate: Rectangle
            {
                width: parent.width
                height: en ? AppTheme.compHeight * app.scale : 0
                visible: en
                color: (index%2 === 0) ? AppTheme.backLightBlueColor : "#00000000"

                Rectangle
                {
                    anchors.fill: parent
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.rightMargin: AppTheme.padding * app.scale
                    color: "#00000000"

                    Text
                    {
                        id: textValueNow
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        height: AppTheme.compHeight * app.scale
                        width: 70 * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: formattedColor(paramId, valueNow)
                        text: formattedValue(valueNow)

                        Rectangle
                        {
                            anchors.left: parent.left
                            width: 1 * app.scale
                            height: parent.height
                            color: AppTheme.blueColor
                        }

                        Rectangle
                        {
                            anchors.right: parent.right
                            width: 1 * app.scale
                            height: parent.height
                            color: AppTheme.blueColor
                        }

                        Rectangle
                        {
                            anchors.bottom: parent.bottom
                            height: 1 * app.scale
                            width: parent.width
                            color: AppTheme.blueColor
                            visible: (index === currentParamsTable.realModelLength() - 1)
                        }
                    }

                    Text
                    {
                        anchors.top: parent.top
                        anchors.right: textValueNow.left
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        width: 120 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueFontColor
                        text: app.getParamById(paramId).fullName
                    }

                    Text
                    {
                        id: textDiffValue
                        anchors.top: parent.top
                        anchors.left: textValueNow.right
                        height: AppTheme.compHeight * app.scale
                        width: 60 * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: formattedDiffValue(valuePrev, valueNow)
                    }

                    Text
                    {
                        id: textProgressSign
                        anchors.top: parent.top
                        anchors.left: textDiffValue.right
                        height: AppTheme.compHeight * app.scale
                        width: 20 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        font.bold: true
                        color: paramProgressState(paramId, valueNow, valuePrev)[1]
                        text: paramProgressState(paramId, valueNow, valuePrev)[0]
                    }

                    Text
                    {
                        anchors.top: parent.top
                        anchors.left: textProgressSign.right
                        height: AppTheme.compHeight * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: 46 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSmallSize * app.scale
                        color: AppTheme.greyColor
                        text: app.getParamById(paramId).unitName
                    }
                }
            }
        }

        NoteViewDialog
        {
            id: noteViewDialog
            anchors.top: curValuesListView.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            anchors.right: parent.right
            height: (AppTheme.rowHeight + AppTheme.compHeight) * app.scale

            noteDate: (curValuesListView.model.length > 0) ? (new DateTimeUtils.DateTimeUtil()).printShortDate(curValuesListView.model[0].dtNow) : ""
            noteText: (curValuesListView.model.length > 0) ? curValuesListView.model[0].note : ""
            noteImages: (curValuesListView.model.length > 0 && curValuesListView.model[0].imgLink.length > 0) ? curValuesListView.model[0].imgLink : ""
        }
    }
}
