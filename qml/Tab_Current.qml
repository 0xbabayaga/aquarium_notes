import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"
import ".."


Item
{
    id: tab_Current

    function savePersonalParams(isSave)
    {
        if (isSave === true)
        {
            for (var i = 0; i < personalParamsListView.model.length; i++)
            {
                app.sigPersonalParamStateChanged(personalParamsListView.model[i].paramId,
                                                 personalParamsListView.model[i].en)
            }
        }

        rectPersonalParamsDialog.opacity = 0
        rectAddRecordDialog.opacity = 1

        dialogAddParamNote.addParamsListModel = app.getAllParamsListModel()
    }

    function addLogRecord(isEdit)
    {
        if (isEdit !== true)
            app.lastSmpId++

        for (var i = 0; i < dialogAddParamNote.addParamsListModel.length; i++)
        {
            if (dialogAddParamNote.addParamsListModel[i].en === true &&
                dialogAddParamNote.addParamsListModel[i].value !== -1)
            {
                if (isEdit === false)
                {
                    app.sigAddRecord(app.lastSmpId,
                                     dialogAddParamNote.addParamsListModel[i].paramId,
                                     dialogAddParamNote.addParamsListModel[i].value)
                }
                else
                {
                    app.sigEditRecord(app.lastSmpId,
                                      dialogAddParamNote.addParamsListModel[i].paramId,
                                      dialogAddParamNote.addParamsListModel[i].value)
                }
            }
        }

        if (dialogAddParamNote.note.length > 0 || dialogAddParamNote.selectedImagesList.count > 0)
        {
            var links = ""

            if (isEdit === false)
            {
                for (i = 0; i < dialogAddParamNote.selectedImagesList.count; i++)
                {
                    if (i !== 0)
                        links += ";"

                    links += dialogAddParamNote.selectedImagesList.get(i).fileLink
                }

                sigAddRecordNotes(app.lastSmpId,
                                  dialogAddParamNote.note,
                                  links)
            }
            else
            {
                sigEditRecordNotes(app.lastSmpId,
                                   dialogAddParamNote.note,
                                   links)
            }
        }

        sigRefreshData()
    }

    function getParamListRealCount()
    {
        var size = 0

        for (var i = 0; i < dialogAddParamNote.addParamsListModel.length; i++)
            if (dialogAddParamNote.addParamsListModel[i].en === true)
                size++;

        return size
    }

    function checkIfTodayRecordExist()
    {
        var lastRecId = -1
        var lastDate
        var todayDate

        if (paramsTable.model)
        {
            lastRecId = paramsTable.model.length - 1
            lastDate = new Date(paramsTable.model[lastRecId].dtNow * 1000)
            todayDate = new Date()
        }

        if (lastRecId > -1 &&
            lastDate.getYear() === todayDate.getYear() &&
            lastDate.getMonth() === todayDate.getMonth() &&
            lastDate.getDate() === todayDate.getDate())
        {
            confirmDialog.showDialog(true, qsTr("WARNING"), qsTr("The record for today is exist. Do you want to update existing?"))
        }
        else
            showAddParamDialog(false)
    }

    function showAddParamDialog(isEdit)
    {
        dialogAddParamNote.setEdit(isEdit)
        dialogAddParamNote.show(true)

        if (isEdit === true)
        {
            for (var i = 0; i < dialogAddParamNote.addParamsListModel.length; i++)
            {
                if (dialogAddParamNote.addParamsListModel[i].en === true)
                {
                    for (var p = 0; p < paramsTable.model.length; p++)
                    {
                        if (dialogAddParamNote.addParamsListModel[i].paramId === paramsTable.model[p].paramId)
                        {
                            app.getAllParamsListModel()[i].value = paramsTable.model[p].valueNow
                            break
                        }
                    }
                }
            }
        }

        dialogAddParamNote.addParamsListModel = 0
        dialogAddParamNote.addParamsListModel = app.getAllParamsListModel()
    }

    Rectangle
    {
        id: rectDataContainer
        anchors.fill: parent
        anchors.leftMargin: AppTheme.padding * app.scale
        anchors.rightMargin: AppTheme.padding * app.scale
        color: "#00002000"

        Behavior on opacity
        {
            NumberAnimation {   duration: 200 }
        }

        CurrentParamsTable
        {
            id: paramsTable
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            model: curValuesListModel
            height: 300 * app.scale
        }

        Rectangle
        {
            anchors.fill: paramsTable
            visible: (curValuesListModel) ? (curValuesListModel.length === 0) : false
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

        PointList
        {
            id: ptList
            anchors.top: paramsTable.top
            anchors.left: parent.left
            anchors.leftMargin: -AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: -AppTheme.padding * app.scale
            model:  datesList

            onModelChanged: currentIndex = 0
            onSigCurIndexChanged:
            {
                if (ptList.model && ptList.model.length > id)
                    app.sigCurrentSmpIdChanged(ptList.model[id].smpId)
            }
        }

        IconSimpleButton
        {
            id: addRecordButton
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale

            onSigButtonClicked: checkIfTodayRecordExist()
        }
    }

    DialogAddParamNote
    {
        id: dialogAddParamNote
        visible: false

        onSigOk: addLogRecord(dialogAddParamNote.isEdit)
    }


    Rectangle
    {
        id: rectPersonalParamsDialog
        anchors.fill: parent
        anchors.leftMargin: AppTheme.padding * 2 * app.scale
        anchors.rightMargin: AppTheme.padding * 2 * app.scale
        color: "#00000020"
        opacity: 0
        visible: (opacity === 0) ? false : true

        Behavior on opacity
        {
            NumberAnimation {   duration: 200 }
        }

        Text
        {
            id: textListOfParamsHeader
            anchors.top: parent.top
            anchors.left: parent.left
            verticalAlignment: Text.AlignVCenter
            width: 100 * app.scale
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontBigSize * app.scale
            color: AppTheme.blueColor
            text: qsTr("List of params:")
        }

        Text
        {
            anchors.top: textListOfParamsHeader.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.left: parent.left
            verticalAlignment: Text.AlignVCenter
            width: 100 * app.scale
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.greyColor
            text: qsTr("Please select a set of parameters for monitoring")
        }

        ListView
        {
            id: personalParamsListView
            anchors.fill: parent
            anchors.topMargin: AppTheme.compHeight * 2 * app.scale
            anchors.bottomMargin: AppTheme.rowHeight * 2 * app.scale
            spacing: 0
            model: app.getAllParamsListModel()

            delegate: Rectangle
            {
                width: parent.width
                height: AppTheme.rowHeightMin * app.scale
                color: "#00000000"

                Text
                {
                    id: textFullName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    verticalAlignment: Text.AlignVCenter
                    width: 100 * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: en ? AppTheme.blueColor : AppTheme.greyColor
                    text: fullName
                }

                SwitchButton
                {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    checked: en
                    onCheckedChanged: {
                        en = checked
                        textFullName.color = en ? AppTheme.blueColor : AppTheme.greyColor
                    }
                }
            }

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: personalParamsListView.parent
                anchors.top: personalParamsListView.top
                anchors.left: personalParamsListView.right
                anchors.leftMargin: AppTheme.padding * app.scale
                anchors.bottom: personalParamsListView.bottom

                contentItem: Rectangle
                {
                    implicitWidth: 2
                    implicitHeight: 100
                    radius: width / 2
                    color: AppTheme.hideColor
                }
            }
        }

        IconSimpleButton
        {
            id: buttonBack
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale
            anchors.left: parent.left
            image: "qrc:/resources/img/icon_cancel.png"

            onSigButtonClicked: savePersonalParams(false)
        }

        IconSimpleButton
        {
            id: buttonSave
            anchors.bottom: parent.bottom
            anchors.bottomMargin: AppTheme.margin * app.scale
            anchors.right: parent.right
            image: "qrc:/resources/img/icon_ok.png"

            onSigButtonClicked: savePersonalParams(true)
        }
    }

    ConfirmDialog
    {
        id: confirmDialog
        onSigAccept: showAddParamDialog(true)
    }
}
