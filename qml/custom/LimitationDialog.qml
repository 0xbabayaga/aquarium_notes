import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../"
import AppDefs 1.0

Item
{
    id: limitationDialog
    width: app.width
    height: app.height
    opacity: enabled ? AppTheme.opacityEnabled : AppTheme.opacityDisabled

    function showDialog(vis)
    {
        rectContOpacityAnimation.stop()

        if (vis === true)
        {
            rectCont.visible = true
            rectContOpacityAnimation.from = 0
            rectContOpacityAnimation.to = 1
        }
        else
        {
            rectContOpacityAnimation.from = 1
            rectContOpacityAnimation.to = 0
        }

        rectContOpacityAnimation.start()
    }

    ListModel
    {
        id: limitationsModel

        ListElement   {   option: "";                           limited:    qsTr("Limited");                 pro: qsTr("PRO");  }
        ListElement   {   option: qsTr("Tanks count");          limited:    AppDefs.TANKS_COUNT_LIMIT;       pro: qsTr("Full");  }
        ListElement   {   option: qsTr("Action list");          limited:    AppDefs.ACTIONS_COUNT_LIMIT;     pro: qsTr("Full");  }
        ListElement   {   option: qsTr("Images count");         limited:    AppDefs.NOTE_IMAGES_COUNT_LIMIT; pro: qsTr("Full");  }
        ListElement   {   option: qsTr("Story view period");    limited:    AppDefs.STORY_VIEW_MONTH_LIMIT;  pro: qsTr("Full");  }
        ListElement   {   option: qsTr("Support");              limited:    qsTr("No");                      pro: qsTr("Yes");  }
    }

    Rectangle
    {
        id: rectCont
        anchors.fill: parent
        parent: Overlay.overlay
        focus: true
        clip: true
        visible: false
        color: "#00000000"

        MouseArea { anchors.fill: parent }

        NumberAnimation
        {
            id: rectContOpacityAnimation
            target: rectCont
            property: "opacity"
            duration: 300
            easing.type: Easing.InOutQuad
            from: 0
            to: 1

            onFinished: if (to === 0) rectCont.visible = false
        }

        Rectangle
        {
            color: AppTheme.backHideColor
            anchors.fill: parent

            Rectangle
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - AppTheme.margin * app.scale
                height: 400 * app.scale - AppTheme.margin * app.scale
                radius: AppTheme.radius / 2 * app.scale
                color: AppTheme.whiteColor

                Text
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: AppTheme.padding * app.scale
                    verticalAlignment: Text.AlignVCenter
                    height: AppTheme.compHeight * app.scale
                    font.family: AppTheme.fontFamily
                    font.pixelSize: AppTheme.fontNormalSize * app.scale
                    color: AppTheme.blueFontColor
                    text: qsTr("LIMITATIONS")
                }

                ListView
                {
                    id: curParamsListView
                    anchors.fill: parent
                    anchors.leftMargin: AppTheme.padding * app.scale
                    anchors.rightMargin: AppTheme.padding * app.scale
                    anchors.topMargin: AppTheme.rowHeight * app.scale
                    spacing: 0
                    interactive: false
                    model: limitationsModel

                    delegate: Rectangle
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale
                        color: (index%2 === 1) ? AppTheme.backLightBlueColor : "#00000000"

                        Row
                        {
                            anchors.left: parent.left
                            anchors.leftMargin: AppTheme.padding * app.scale
                            anchors.right: parent.right

                            Text
                            {
                                verticalAlignment: Text.AlignVCenter
                                height: AppTheme.compHeight * app.scale
                                width: 160 * app.scale
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueFontColor
                                text: option
                            }

                            Text
                            {
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                height: AppTheme.compHeight * app.scale
                                width: 60 * app.scale
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: (index === 0) ? AppTheme.blueColor : AppTheme.greyColor
                                text: limited
                            }

                            Text
                            {
                                width: 60 * app.scale
                                height: AppTheme.compHeight * app.scale
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: (index === 0) ? AppTheme.blueColor : AppTheme.greyColor
                                text: pro
                            }
                        }
                    }
                }

                IconSimpleButton
                {
                    id: buttonOk
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.padding * app.scale
                    anchors.horizontalCenter: parent.horizontalCenter
                    image: "qrc:/resources/img/icon_ok.png"

                    onSigButtonClicked: showDialog(false)
                }
            }
        }
    }
}
