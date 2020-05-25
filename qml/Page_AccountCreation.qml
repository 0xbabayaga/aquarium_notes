import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import "custom"
import AppInitEnum 1.0

Item
{
    id: page_AccountCreation

    property string currentUName: qsTr("User")
    property int stage: -1

    onStageChanged: if (stage !== -1)   openAccountDialog(stage)

    signal sigAppInitCompleted()

    function openAccountDialog(page)
    {
        animationToPage.stop()

        animationToPage.from = animationToPage.to
        animationToPage.to = app.height * page

        if (page === AppInitEnum.AppInit_Completed)
        {
            page_AccountCreation.visible = false
            sigAppInitCompleted()
        }

        animationToPage.start()
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
            contentHeight: app.height * 4

            flickableDirection: Flickable.VerticalFlick
            interactive: false

            NumberAnimation on contentY
            {
                id: animationToPage
                from: 0
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
                        text: qsTr("Hello") + ", " + currentUName
                    }

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("There is no active account found")
                    }

                    Item { height: 1; width: 1;}
                    Item { height: 1; width: 1;}

                    StandardButton
                    {
                        id: buttonGoToAccount
                        anchors.horizontalCenter: parent.horizontalCenter
                        bText: qsTr("CREATE")

                        onSigButtonClicked: page_AccountCreation.openAccountDialog(1)
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
                    anchors.verticalCenterOffset: 60 * app.scale
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

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textUserName
                        placeholderText: qsTr("User name")
                        width: parent.width
                        focus: true
                        KeyNavigation.tab: textUserEmail
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textUserEmail
                        placeholderText: qsTr("User email")
                        width: parent.width
                        focus: true
                        KeyNavigation.tab: textUserPass
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textUserPass
                        placeholderText: qsTr("User password")
                        width: parent.width
                        focus: true
                        KeyNavigation.tab: buttonCancel
                    }

                    Item { height: 1; width: 1;}
                    Item { height: 1; width: 1;}
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
                            bText: qsTr("CANCEL")
                            focus: true
                            KeyNavigation.tab: buttonCreate

                            onSigButtonClicked: page_AccountCreation.openAccountDialog(0)
                        }

                        StandardButton
                        {
                            id: buttonCreate
                            anchors.right: parent.right
                            width: 130 * app.scale
                            bText: qsTr("CREATE")
                            focus: true
                            KeyNavigation.tab: textUserName

                            onSigButtonClicked:
                            {
                                app.sigCreateAccount(textUserName.text,
                                                     textUserPass.text,
                                                     textUserEmail.text)
                            }
                        }
                    }
                }
            }

            Rectangle
            {
                id: rectNoTanc
                anchors.top: rectCreateAccount.bottom
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
                        text: qsTr("Hello") + ", " + currentUName
                    }

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("There is no active tank found")
                    }

                    Item { height: 1; width: 1;}
                    Item { height: 1; width: 1;}

                    StandardButton
                    {
                        id: buttonGoToTank
                        anchors.horizontalCenter: parent.horizontalCenter
                        bText: qsTr("CREATE")

                        onSigButtonClicked:
                        {
                            stage = AppInitEnum.AppInit_CreateTank
                            textTankName.forceActiveFocus()
                            app.sigDebug()
                        }
                     }
                }
            }

            Rectangle
            {
                id: rectCreateTank
                anchors.top: rectNoTanc.bottom
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
                    anchors.verticalCenterOffset: 60 * app.scale
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
                        text: qsTr("Creating tank:")
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textTankName
                        placeholderText: qsTr("Tank name")
                        width: parent.width
                        focus: false
                        KeyNavigation.tab: textTankL
                    }

                    Item { height: 1; width: 1;}

                    Rectangle
                    {
                        id: rectRow
                        width: parent.width
                        height: AppTheme.compHeight * app.scale
                        color: "#00000000"

                        property int unitWidth: 20 * app.scale

                        TextInput
                        {
                            id: textTankL
                            anchors.left: parent.left
                            placeholderText: qsTr("100")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: textTankW

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }

                        TextInput
                        {
                            id: textTankW
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: textTankH

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }

                        TextInput
                        {
                            id: textTankH
                            anchors.right: parent.right
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: 4
                            validator : RegExpValidator { regExp : /[0-9]+[0-9]+/ }
                            focus: true
                            KeyNavigation.tab: comboTankType

                            Text
                            {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                font.family: AppTheme.fontFamily
                                font.pixelSize: AppTheme.fontNormalSize * app.scale
                                color: AppTheme.blueColor
                                text: qsTr("cm")
                            }
                        }
                    }


                    Item { height: 1; width: 1;}

                    ComboList
                    {
                        id: comboTankType
                        propertyName: qsTr("Select a tank type:");
                        width: parent.width
                        model: aquariumTypesListModel
                        //KeyNavigation.tab: textFileName
                    }

                    Item { height: 1; width: 1;}

                    ImageList
                    {
                        id: imagesList
                        width: parent.width
                        propertyName: qsTr("Select a photo:")
                        model: imageGalleryListModel
                    }

                    Item { height: 1; width: 1;}
                    Item { height: 1; width: 1;}

                    Rectangle
                    {
                        width: parent.width
                        height: AppTheme.compHeight * app.scale

                        StandardButton
                        {
                            id: buttonCancel2
                            anchors.left: parent.left
                            width: 130 * app.scale
                            bText: qsTr("CANCEL")
                            KeyNavigation.tab: buttonCreate2

                            onSigButtonClicked: page_AccountCreation.openAccountDialog(2)
                        }

                        StandardButton
                        {
                            id: buttonCreate2
                            anchors.right: parent.right
                            width: 130 * app.scale
                            bText: qsTr("CREATE")
                            KeyNavigation.tab: textTankName

                            onSigButtonClicked:
                            {
                                app.sigCreateTank(textTankName.text,
                                                  comboTankType.currentIndex,
                                                  textTankL.text,
                                                  textTankW.text,
                                                  textTankH.text,
                                                  imagesList.getSelectedImageLink())
                            }
                        }
                    }
                }
            }
        }
    }
}
