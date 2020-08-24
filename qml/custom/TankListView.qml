import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"

Item
{
    id: tankListView
    width: app.width

    property alias model: view.model
    property alias currentIndex: view.currentIndex
    property int tankImageHeight: 180

    signal sigCurrentIndexChanged(int id)
    signal sigDoubleClicked(int id)
    signal sigTankSelected(int id)

    Rectangle
    {
        anchors.fill: parent
        color: "#00000000"

        ListView
        {
            id: view
            anchors.fill: parent
            orientation: ListView.Vertical
            spacing: AppTheme.margin * app.scale
            clip: true

            delegate: Rectangle
            {
                width: parent.width
                height: (index === view.currentIndex) ? (tankListView.tankImageHeight * app.scale + (currParamTable.realModelLength() * AppTheme.compHeight + AppTheme.rowHeightMin + AppTheme.padding/2) * app.scale) : tankListView.tankImageHeight * app.scale
                color: "#00000000"

                Behavior on height
                {
                    NumberAnimation
                    {
                        duration: 200
                        easing.type: Easing.OutExpo
                    }
                }

                Rectangle
                {
                    id: rect
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.rightMargin: AppTheme.padding * app.scale
                    anchors.top: parent.top
                    color: AppTheme.whiteColor
                    height: parent.height
                }

                DropShadow
                {
                    anchors.fill: rect
                    horizontalOffset: 0
                    verticalOffset: 0
                    radius: AppTheme.shadowSize * app.scale
                    samples: AppTheme.shadowSamples
                    color: AppTheme.shadowColor
                    source: rect
                }

                Rectangle
                {
                    anchors.fill: rect
                    color: "#00000000"

                    Image
                    {
                        id: imgPhoto
                        anchors.top: parent.top
                        width: parent.width
                        height: tankListView.tankImageHeight * app.scale
                        source: (img.length > 0) ? "data:image/jpg;base64," + img : ""
                        mipmap: true

                        //layer.enabled: true
                        //layer.effect: OpacityMask
                        //{
                        //    maskSource: rectMask
                        //}
                    }

                    /*
                    Rectangle
                    {
                        id: rectMask
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: tankListView.tankImageHeight * app.scale
                        radius: AppTheme.radius * app.scale
                        visible: false
                    }
                    */

                    Image
                    {
                        id: imgWave
                        width: parent.width
                        height: imgPhoto.height * 0.4
                        anchors.bottom: imgPhoto.bottom
                        source: (type < 4) ? "qrc:/resources/img/wave_blue_2.png" : "qrc:/resources/img/wave_green_2.png"
                        mipmap: true
                        opacity: 0.8

                        //layer.enabled: true
                        //layer.effect: OpacityMask
                        //{
                        //    maskSource: rectMask
                        //}
                    }

                    Text
                    {
                        anchors.right: parent.right
                        anchors.rightMargin: AppTheme.padding * app.scale
                        anchors.bottom: imgPhoto.bottom
                        anchors.bottomMargin: AppTheme.padding/2 * app.scale
                        text: app.convertVolume(volume) + app.currentVolumeUnitsShort()
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontSuperBigSize * app.scale
                        color: AppTheme.whiteColor
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                        height: AppTheme.compHeight * app.scale
                    }

                    Text
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: AppTheme.padding * app.scale
                        anchors.bottom: imgPhoto.bottom
                        anchors.bottomMargin: AppTheme.padding/2 * app.scale
                        text: name
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.whiteColor
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                        height: AppTheme.compHeight * app.scale
                    }

                    CurrentParamsMainTable
                    {
                        id: currParamTable
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: imgPhoto.bottom
                        anchors.bottom: parent.bottom
                        model: curValuesListModel
                        opacity: (index === view.currentIndex) ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    MouseArea
                    {
                        anchors.fill: parent
                        onDoubleClicked:
                        {
                            view.currentIndex = index
                            sigDoubleClicked(index)
                        }

                        onClicked:
                        {
                            view.currentIndex = index
                            sigCurrentIndexChanged(index)
                        }
                    }

                    IconSimpleButton
                    {
                        anchors.right: parent.right
                        anchors.rightMargin: AppTheme.padding * app.scale
                        anchors.top: parent.top
                        anchors.topMargin: AppTheme.padding * app.scale
                        image: "qrc:/resources/img/icon_arrow_right.png"
                        inverted: true

                        onSigButtonClicked:
                        {
                            view.currentIndex = index
                            sigTankSelected(view.currentIndex)
                        }
                    }
                }
            }

            onCurrentIndexChanged: sigCurrentIndexChanged(currentIndex)

            ScrollBar.vertical: ScrollBar
            {
                policy: ScrollBar.AlwaysOn
                parent: view.parent
                anchors.top: view.top
                anchors.left: view.right
                anchors.leftMargin: -AppTheme.margin / 3 * app.scale
                anchors.bottom: view.bottom

                contentItem: Rectangle
                {
                    implicitWidth: 2
                    implicitHeight: 100
                    radius: width / 2
                    color: AppTheme.hideColor
                }
            }
        }
    }
}
