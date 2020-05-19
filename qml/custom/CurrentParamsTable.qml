import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: currentParamsTable

    property alias model: curValuesListView.model

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

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        Rectangle
        {
            id: rectDataHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: AppTheme.compHeight * app.scale
            color: "#00000000"

            Row
            {
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.right: parent.right

                Text
                {
                    verticalAlignment: Text.AlignVCenter
                    height: AppTheme.compHeight * app.scale
                    width: 125 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: ""
                }

                Text
                {
                    verticalAlignment: Text.AlignVCenter
                    height: AppTheme.compHeight * app.scale
                    width: 35 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.greyColor
                    text: ""
                }

                Rectangle
                {
                    height: AppTheme.compHeight * app.scale
                    width: 55 * app.scale
                    color: AppTheme.blueColor

                    Text
                    {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                        color: AppTheme.whiteColor
                        visible: (curValuesListView.model.length > 0)
                        text: app.printDate(curValuesListView.model[0].dtNow)
                    }
                }

                Text
                {
                    height: AppTheme.compHeight * app.scale
                    width: 60 * app.scale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                    color: AppTheme.greyColor
                    visible: (curValuesListView.model.length > 0)
                    text: app.printDate(curValuesListView.model[0].dtPrev)
                }

                Text
                {
                    height: AppTheme.compHeight * app.scale
                    width: 40 * app.scale
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    color: AppTheme.blueColor
                    text: ""
                }
            }
        }

        ListView
        {
            id: curValuesListView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: AppTheme.compHeight * app.scale
            spacing: 0
            interactive: false

            onModelChanged: height = curValuesListView.model.length * AppTheme.compHeight * app.scale

            delegate: Rectangle
            {
                width: parent.width
                height: AppTheme.compHeight * app.scale
                color: (index%2 === 0) ? "#2000adbc" : "#0000adbc"

                Row
                {
                    anchors.left: parent.left
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.right: parent.right

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        width: 110 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: app.getParamById(paramId).fullName
                    }

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        width: 50 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: app.getParamById(paramId).unitName
                    }

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        width: 55 * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
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
                            visible: (index === curValuesListView.model.length - 1)
                        }
                    }

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        width: 55 * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: formattedValue(valuePrev)
                    }

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        width: 30 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: formattedDiffValue(valuePrev, valueNow)
                    }
                }

                /*
                Rectangle
                {
                    width: parent.width
                    height: 1 * app.scale
                    anchors.bottom: parent.bottom
                    color: ((index + 1) === curValuesListView.model.count) ? "#00000000" : AppTheme.shideColor
                }
                */
            }
        }

        Text
        {
            anchors.top: curValuesListView.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueColor
            text: "Note found"
        }

        Text
        {
            id: textNote
            anchors.top: curValuesListView.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.greyColor
            text: "Note found"
        }
    }
}
