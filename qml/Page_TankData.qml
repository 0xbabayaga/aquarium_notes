import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Item
{
    id: page_TankData
    visible: false
    width: app.width
    height: app.height

    function showPage(vis, tankName, tankType)
    {
        scaleAnimation.stop()

        if (vis === true)
        {
            page_TankData.visible = true
            scaleAnimation.from = 0
            scaleAnimation.to = 1

            textTankName.text = tankName
            textTankName.color = (tankType === 0) ? AppTheme.blueColor : AppTheme.greenColor
            arrowOverlay.color = textTankName.color
        }
        else
        {
            scaleAnimation.to = 0
            scaleAnimation.from = 1
        }

        scaleAnimation.start()
    }

    function formattedValue(val_prev, val_curr)
    {
        var str = ""

        if (val_curr > val_prev)
            str = "+"

        str += Math.round((val_curr - val_prev) * 100) / 100

        return str
    }

    ListModel
    {
        id: tmpDetailedParamModel

        ListElement     {   pname:  "Salinity"; punit: "ppm";   pvalue_curr: 33.5;  pvalue_prev: 33.6; }
        ListElement     {   pname:  "Ca";       punit: "mg\\l"; pvalue_curr: 390;   pvalue_prev: 397;  }
        ListElement     {   pname:  "kH";       punit: "dKh";   pvalue_curr: 9.7;   pvalue_prev: 9.5;  }
        ListElement     {   pname:  "pH";       punit: "";      pvalue_curr: 33.5;  pvalue_prev: 33.6; }
        ListElement     {   pname:  "NO3";      punit: "ppm";   pvalue_curr: 3.5;   pvalue_prev: 3.6;  }
        ListElement     {   pname:  "PO4";      punit: "ppm";   pvalue_curr: 0.25;  pvalue_prev: 0.25; }
    }

    ScaleAnimator
    {
        id: scaleAnimation
        target: page_TankData
        from: 0
        to: 1
        duration: 200
        running: false
        onFinished: if (to === 0) page_TankData.visible = false
    }

    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor
    }

    DropShadow
    {
        anchors.fill: rectContainer
        horizontalOffset: 0
        verticalOffset: -3
        radius: 10.0 * app.scale
        samples: 16
        color: "#20000000"
        source: rectContainer
    }

    Rectangle
    {
        id: rectRealContainer
        anchors.fill: parent
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -(AppTheme.rowHeightMin - AppTheme.margin) * app.scale
            anchors.right: parent.right
            //fillMode: Image.PreserveAspectFit
            source: "qrc:/resources/img/back_waves.png"
            opacity: 0.15
        }

        Image
        {
            id: imgArrowBack
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.top: parent.top
            anchors.topMargin: AppTheme.padding * app.scale
            height: AppTheme.compHeight * app.scale
            width: height
            fillMode: Image.PreserveAspectFit
            mipmap: true
            source: "qrc:/resources/img/icon_arrow_left.png"

            ColorOverlay
            {
                id: arrowOverlay
                anchors.fill: imgArrowBack
                source: imgArrowBack
                color: AppTheme.blueColor
            }

            MouseArea
            {
                anchors.fill: parent
                onClicked: showPage(false, "")
            }
        }

        Text
        {
            id: textTankName
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            height: AppTheme.rowHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontBigSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("Not defined")
        }

        Rectangle
        {
            id: rectDataContainer
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.topMargin: AppTheme.rowHeight * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
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
                    anchors.right: parent.right

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        width: 100 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: ""
                    }

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        width: 60 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: ""
                    }

                    Text
                    {
                        width: 70 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: "[" + qsTr("current") + "]"
                    }

                    Text
                    {
                        width: 70 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: "[" + qsTr("previous") + "]"
                    }

                    Text
                    {
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
                id: paramListView
                anchors.fill: parent
                anchors.topMargin: AppTheme.compHeight * app.scale
                spacing: 0
                model: tmpDetailedParamModel

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
                            width: 100 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBigSize * app.scale
                            color: AppTheme.blueColor
                            text: pname
                        }

                        Text
                        {
                            verticalAlignment: Text.AlignBottom
                            width: 60 * app.scale
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: punit
                        }

                        Text
                        {
                            width: 70 * app.scale
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBigSize * app.scale
                            color: AppTheme.blueColor
                            text: pvalue_curr
                        }

                        Text
                        {
                            width: 70 * app.scale
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBigSize * app.scale
                            color: AppTheme.greyColor
                            text: pvalue_prev
                        }

                        Text
                        {
                            width: 40 * app.scale
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignRight
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontBigSize * app.scale
                            color: AppTheme.blueColor
                            text: page_TankData.formattedValue(pvalue_prev, pvalue_curr)
                        }
                    }

                    Rectangle
                    {
                        width: parent.width
                        height: 1 * app.scale
                        anchors.bottom: parent.bottom
                        color: ((index + 1) === paramListView.model.count) ? "#00000000" : AppTheme.shideColor
                    }
                }
            }
        }
    }
}
