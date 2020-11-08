import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.1
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: noteView
    width: app.width
    height: imgCurrent.height + textNoteDetailed.contentHeight + AppTheme.rowHeight * 3 * app.scale

    property string imagesList: ""
    property alias noteText: textNoteDetailed.text
    property alias noteDate: textNoteDate.text
    property var parameters: []
    property bool isFirstOnList: false

    function loadImage(index)
    {
        imagesPreviewList.currentIndex = index
        imgCurrent.source = "file:///" + imagesListModel.get(index).fileLink

        if (imagesListModel.count < 1)
            imgCurrent.height = 0
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

    function createContent()
    {
        imagesListModel.clear()
        valuesModel.clear()

        var imgs = imagesList.split(";")

        for (var pt in params)
            valuesModel.append({"value": formattedValue(parseFloat(params[pt])), "name": app.getParamById(parseInt(pt)).shortName})

        for (var i = 0; i < imgs.length; i++)
            if (imgs[i].length > 0)
                imagesListModel.append({"fileLink": imgs[i]})
    }


    ListModel { id: imagesListModel }
    ListModel { id: valuesModel }

    Behavior on height { NumberAnimation { duration: 100 } }

    //onImagesListChanged:    createContent()
    onParametersChanged:    createContent()

    Rectangle
    {
        id: rectNoteDetails
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height

        Rectangle
        {
            id: rectLine
            anchors.top: parent.top
            anchors.topMargin: AppTheme.compHeight * app.scale
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            height: 1 * app.scale
            color: AppTheme.blueColor
        }

        Text
        {
            id: textNoteDate
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.top: parent.top
            height: AppTheme.compHeight * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontNormalSize * app.scale
            color: AppTheme.blueFontColor
            text: ""
        }

        ListView
        {
            id: valuesListView
            anchors.top: rectLine.bottom
            anchors.topMargin: AppTheme.padding / 2 * app.scale
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding / 2 * app.scale
            anchors.right: parent.right
            height: AppTheme.compHeight * app.scale
            orientation: ListView.Horizontal
            spacing: AppTheme.padding / 2 * app.scale
            model: valuesModel

            delegate: Rectangle
            {
                width: (valuesListView.width - AppTheme.padding / 2 * app.scale * ((valuesModel.count > 6) ? 6 : valuesModel.count)) / ((valuesModel.count > 6) ? 6 : valuesModel.count)
                height: valuesListView.height
                color: AppTheme.whiteColor

                Text
                {
                    anchors.top: parent.top
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    height: parent.height / 2
                    width: parent.width
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
                    color: AppTheme.greyColor
                    text: name
                }

                Text
                {
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    height: parent.height / 2
                    width: parent.width
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontSuperSmallSize * app.scale
                    color: AppTheme.blueFontColor
                    text: value
                }
            }
        }

        Image
        {
            id: imgCurrent
            anchors.top: valuesListView.bottom
            anchors.topMargin: AppTheme.padding / 2 * app.scale
            width: parent.width
            sourceSize.width: parent.width
            sourceSize.height: 400
            mipmap: true
            fillMode: Image.PreserveAspectFit
            source: imagesListModel.count > 0 ? "file:///" + imagesListModel.get(0).fileLink : ""

            Behavior on height { NumberAnimation { duration: 500 } }

            IconSimpleButton
            {
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.padding/2 * app.scale
                anchors.verticalCenter: parent.verticalCenter
                image: "qrc:/resources/img/icon_arrow_right.png"
                inverted: true
                visible: (imagesListModel.count > 1)
                opacity: 0.5

                onSigButtonClicked:
                {
                    if (imagesPreviewList.currentIndex < (imagesPreviewList.model.count - 1))
                        imagesPreviewList.currentIndex++
                    else
                        imagesPreviewList.currentIndex = 0

                    loadImage(imagesPreviewList.currentIndex)
                }
            }

            IconSimpleButton
            {
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.padding/2 * app.scale
                anchors.verticalCenter: parent.verticalCenter
                image: "qrc:/resources/img/icon_arrow_left.png"
                inverted: true
                visible: (imagesListModel.count > 1)
                opacity: 0.5

                onSigButtonClicked:
                {
                    if (imagesPreviewList.currentIndex > 0)
                        imagesPreviewList.currentIndex--
                    else
                        imagesPreviewList.currentIndex = imagesListModel.count - 1

                    loadImage(imagesPreviewList.currentIndex)
                }
            }
        }

        ListView
        {
            id: imagesPreviewList
            anchors.top: imgCurrent.bottom
            anchors.topMargin: AppTheme.padding * app.scale
            anchors.horizontalCenter: parent.horizontalCenter
            width: imagesListModel.count * AppTheme.padding * app.scale
            height: AppTheme.padding * app.scale
            orientation: ListView.Horizontal
            spacing: AppTheme.padding / 2 * app.scale
            model: imagesListModel
            interactive: false
            visible: (imagesListModel.count > 1)

            delegate: Rectangle
            {
                width: AppTheme.padding / 2 * app.scale
                height: width
                radius: width / 2
                scale: (index === imagesPreviewList.currentIndex) ? 1.5 : 1
                color: (imagesPreviewList.currentIndex === index) ? AppTheme.greyColor : AppTheme.hideColor

                Behavior on scale { NumberAnimation { duration: 200 } }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        imagesPreviewList.currentIndex = index
                        loadImage(imagesPreviewList.currentIndex)
                    }
                }
            }
        }

        Text
        {
            id: textNoteDetailed
            anchors.left: parent.left
            anchors.leftMargin: AppTheme.padding * app.scale
            anchors.right: parent.right
            anchors.rightMargin: AppTheme.padding * app.scale
            anchors.top: imagesPreviewList.bottom
            height: contentHeight + AppTheme.padding * app.scale
            verticalAlignment: Text.AlignVCenter
            font.family: AppTheme.fontFamily
            font.pixelSize: AppTheme.fontSmallSize * app.scale
            color: AppTheme.greyColor
            text: ""
            wrapMode: Text.WordWrap
        }
    }
}
