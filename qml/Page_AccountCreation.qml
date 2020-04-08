import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "custom"

Item
{
    id: page_AccountCreation

    function openAccountDialog(open)
    {
        if (open === true)
        {
            animationBack.stop();
            animationNext.start();
        }
        else
        {
            animationNext.stop();
            animationBack.start();
        }
    }

    ListModel
    {
        id: tankTypesModel

        ListElement {   name: "Reef aquarium";      desc:   ""  }
        ListElement {   name: "Fresh aquarium";     desc:   ""  }
        ListElement {   name: "Cichlid aquarium";   desc:   ""  }

    }


    Rectangle
    {
        id: rectContainer
        anchors.fill: parent
        color: "#00000000"

        Flickable
        {
            id: flickView
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            contentWidth: width
            contentHeight: app.height * 2

            flickableDirection: Flickable.VerticalFlick
            interactive: false

            NumberAnimation on contentY
            {
                id: animationNext
                from: 0
                to: app.height
                duration: 500
                easing.type: Easing.OutExpo
                running: false
            }

            NumberAnimation on contentY
            {
                id: animationBack
                from: app.height
                to: 0
                duration: 500
                easing.type: Easing.OutExpo
                running: false
            }

            Rectangle
            {
                id: rectNoAccount
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                height: app.height
                color: "#00000000"

                Column
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 100 * app.scale
                    height: 300 * app.scale
                    width: parent.width
                    spacing: AppTheme.padding * app.scale

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Hello") + ", " +qsTr("User")
                    }

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("There is no active account detected")
                    }

                    StandardButton
                    {
                        id: buttonGoToAccount
                        anchors.horizontalCenter: parent.horizontalCenter
                        bText: qsTr("Create account")

                        onSigButtonClicked: page_AccountCreation.openAccountDialog(true)
                     }
                }
            }

            Rectangle
            {
                id: rectCreateAccount
                anchors.top: rectNoAccount.bottom
                anchors.left: parent.left
                anchors.leftMargin: AppTheme.margin * app.scale
                anchors.right: parent.right
                anchors.rightMargin: AppTheme.margin * app.scale
                height: app.height
                color: "#00000000"

                Column
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 100 * app.scale
                    height: 300 * app.scale
                    width: parent.width
                    spacing: AppTheme.padding * app.scale

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Creating account:")
                    }

                    TextInput
                    {
                        id: textUserName
                        placeholderText: qsTr("User name")
                        width: parent.width
                    }

                    TextInput
                    {
                        id: textUserPass
                        placeholderText: qsTr("User password")
                        width: parent.width
                    }

                    TextInput
                    {
                        id: textUserEmail
                        placeholderText: qsTr("User email")
                        width: parent.width
                    }

                    ComboList
                    {
                        id: comboTankType
                        propertyName: qsTr("Select a tank type:");
                        width: parent.width
                        model: tankTypesModel
                    }

                    Item { height: 1; width: 1;}

                    Rectangle
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        StandardButton
                        {
                            id: buttonCancel
                            anchors.left: parent.left
                            width: 130 * app.scale
                            bText: qsTr("Cancel")

                            onSigButtonClicked: page_AccountCreation.openAccountDialog(false)
                        }

                        StandardButton
                        {
                            id: buttonCreate
                            anchors.right: parent.right
                            width: 130 * app.scale
                            bText: qsTr("Create account")

                            onSigButtonClicked:
                            {
                                app.sigCreateAccount(textUserName.text,
                                                     textUserPass.text,
                                                     textUserEmail.text,
                                                     comboTankType.currentIndex)
                            }
                        }
                    }
                }
            }
        }
    }
}
