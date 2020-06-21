import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
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
                    width: 135 * app.scale
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
                    width: 60 * app.scale
                    color: AppTheme.blueColor
                    visible: (realModelLength() !== 0)

                    Text
                    {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                        color: AppTheme.whiteColor
                        visible: (curValuesListView.model) ? (curValuesListView.model.length > 0) : false
                        text: (curValuesListView.model) ? app.printDate(curValuesListView.model[0].dtNow) : ""
                    }
                }

                Text
                {
                    height: AppTheme.compHeight * app.scale
                    width: 65 * app.scale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                    color: AppTheme.greyColor
                    visible: (realModelLength() > 0)
                    text: (curValuesListView.model) ? app.printDate(curValuesListView.model[0].dtPrev) : ""
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

            onModelChanged: height = realModelLength() * AppTheme.compHeight * app.scale

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
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        width: 120 * app.scale
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
                        width: 60 * app.scale
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
                        height: AppTheme.compHeight * app.scale
                        width: 55 * app.scale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: formattedDiffValue(valuePrev, valueNow)
                    }

                    Text
                    {
                        height: AppTheme.compHeight * app.scale
                        width: 30 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        font.bold: true
                        color: paramProgressState(paramId, valueNow, valuePrev)[1]
                        text: paramProgressState(paramId, valueNow, valuePrev)[0]
                    }
                }
            }
        }

        Rectangle
        {
            id: rectNoteFound
            anchors.top: curValuesListView.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            anchors.right: parent.right
            height: AppTheme.rowHeight * app.scale
            color: AppTheme.backLightBlueColor
            visible: (realModelLength() !== 0 && curValuesListView.model[0].note.length > 0)

            Image
            {
                id: imgNotePhoto
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding/2 * app.scale
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding * app.scale
                height: AppTheme.rowHeightMin * app.scale
                width: height
                mipmap: true
                source: (curValuesListView.model) ? "file:///"+curValuesListView.model[0].imgLink : ""

                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: imgNotePhotoMask
                }
            }

            Rectangle
            {
                id: imgNotePhotoMask
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: AppTheme.compHeight * app.scale
                height: AppTheme.rowHeight * app.scale
                width: height
                radius: AppTheme.radius * app.scale
                visible: false
            }

            Text
            {
                id: textNote
                anchors.top: parent.top
                anchors.topMargin: AppTheme.padding/2 * app.scale
                anchors.left: imgNotePhoto.right
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.padding * app.scale
                height: AppTheme.compHeight * app.scale
                verticalAlignment: Text.AlignVCenter
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontSmallSize * app.scale
                color: AppTheme.greyColor
                text: (curValuesListView.model) ? curValuesListView.model[0].note : ""
                wrapMode: Text.WordWrap
            }
        }
    }
}
