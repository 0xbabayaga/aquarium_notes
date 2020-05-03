import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"

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

    function addLogRecord(isAdd)
    {
        if (isAdd === true)
        {
            for (var i = 0; i < addRecordListView.model.length; i++)
            {
                if (addRecordListView.model[i].value !== -1)
                {
                    app.sigAddRecord(app.lastSmpId,
                                     addRecordListView.model[i].paramId,
                                     addRecordListView.model[i].value)
                }
            }

            app.lastSmpId++
        }

        rectAddRecordDialog.opacity = 0
        rectDataContainer.opacity = 1
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
        anchors.bottomMargin: AppTheme.rowHeightMin * app.scale
        radius: AppTheme.radius * 2 * app.scale
        color: AppTheme.whiteColor

        Image
        {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: -(AppTheme.rowHeightMin - AppTheme.margin) * app.scale
            width: parent.width
            height: width * 0.75
            //anchors.right: parent.right
            //fillMode: Image.PreserveAspectFit
            source: "qrc:/resources/img/back_waves.png"
            opacity: 0.3
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
                onClicked:
                {
                    addLogRecord(false)
                    showPage(false, "")
                }
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
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            anchors.topMargin: AppTheme.rowHeight * 2 * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
            color: "#00002000"

            Behavior on opacity
            {
                NumberAnimation {   duration: 400 }
            }

            CurrentParamsTable
            {
                id: paramsTable
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 400 * app.scale
                model: curParamsModel
            }

            Rectangle
            {
                anchors.fill: paramsTable
                visible: (curParamsModel.length === 0)
                color: "#00000000"

                Text
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 250 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontBigSize * app.scale
                    wrapMode: Text.WordWrap
                    color: AppTheme.greyColor
                    text: qsTr("No record found for this aquarium")
                }
            }

            IconButton
            {
                id: addRecordButton
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: AppTheme.margin * app.scale

                onSigButtonClicked:
                {
                    rectAddRecordDialog.opacity = 1
                    rectDataContainer.opacity = 0
                }
            }
        }

        Rectangle
        {
            id: rectAddRecordDialog
            anchors.fill: parent
            anchors.leftMargin: AppTheme.padding * 2 * app.scale
            anchors.rightMargin: AppTheme.padding * 2 * app.scale
            anchors.topMargin: AppTheme.rowHeight * 2 * app.scale
            anchors.bottomMargin: AppTheme.padding * app.scale
            color: "#00000020"
            opacity: 0
            visible: (opacity === 0) ? false : true

            Behavior on opacity
            {
                NumberAnimation {   duration: 400 }
            }

            Text
            {
                anchors.top: parent.top
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
                width: 100 * app.scale
                font.family: AppTheme.fontFamily
                font.pixelSize: AppTheme.fontBigSize * app.scale
                color: AppTheme.blueColor
                text: qsTr("Add record:")
            }

            ListView
            {
                id: addRecordListView
                anchors.fill: parent
                anchors.topMargin: AppTheme.compHeight * app.scale
                anchors.bottomMargin: AppTheme.rowHeight * 2 * app.scale
                spacing: 0
                model: app.getParamsModel()
                clip: true

                delegate: Rectangle
                {
                    width: parent.width
                    height: AppTheme.rowHeightMin * app.scale
                    color: "#00000000"

                    Text
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        verticalAlignment: Text.AlignVCenter
                        width: 100 * app.scale
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueColor
                        text: fullName
                    }

                    TextInput
                    {
                        id: textInputValue
                        anchors.right: parent.right
                        placeholderText: "0"
                        width: 100 * app.scale
                        maximumLength: 4

                        onTextChanged: value = textInputValue.text

                        Text
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            verticalAlignment: Text.AlignVCenter
                            font.family: AppTheme.fontFamily
                            font.pixelSize: AppTheme.fontNormalSize * app.scale
                            color: AppTheme.greyColor
                            text: unitName
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar
                {
                    policy: ScrollBar.AlwaysOn
                    parent: addRecordListView.parent
                    anchors.top: addRecordListView.top
                    anchors.left: addRecordListView.right
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.bottom: addRecordListView.bottom

                    contentItem: Rectangle
                    {
                        implicitWidth: 2
                        implicitHeight: 100
                        radius: width / 2
                        color: AppTheme.hideColor
                    }
                }
            }

            StandardButton
            {
                id: buttonCancel
                anchors.top: addRecordListView.bottom
                anchors.topMargin: AppTheme.margin * app.scale
                anchors.left: parent.left
                bText: qsTr("CANCEL")

                onSigButtonClicked: addLogRecord(false)
            }

            StandardButton
            {
                id: buttonAdd
                anchors.top: addRecordListView.bottom
                anchors.topMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                bText: qsTr("ADD")

                onSigButtonClicked: addLogRecord(true)
            }
        }
    }
}
