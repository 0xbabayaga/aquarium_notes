import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.0
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import "custom"
import AppDefs 1.0

Item
{
    id: page_AccountWizard

    property string currentUName: qsTr("")
    property int stage: -1

    onStageChanged: if (stage !== -1)   openAccountDialog(stage)

    signal sigAppInitCompleted()

    function openAccountDialog(page)
    {
        animationToPage.stop()

        animationToPage.from = animationToPage.to
        animationToPage.to = app.height * page

        if (page === AppDefs.AppInit_Completed)
        {
            page_AccountWizard.visible = false
            sigAppInitCompleted()
        }

        animationToPage.start()
    }

    function isCredentialsGood()
    {
        var uname = textUserName.text
        //var upass = textUserPass.text
        var email = textUserEmail.text

        if (uname.length > 0 && uname.length <= AppDefs.MAX_USERNAME_SIZE)
        {
            if (email.includes('@') === true && email.includes('.') === true)
                return true
            else
                textUserEmail.setError()
        }
        else
        {
            textUserName.setError()
        }

        return false
    }

    function isTankParamsGood()
    {
        var name = textTankName.text
        var imgCnt = imgTankAvatar.selectedImagesList.count

        if (name.length > 0 && name.length <= AppDefs.MAX_TANKNAME_SIZE)
        {
            if (imgCnt > 0)
                return true
        }
        else
            textTankName.setError()

        return false
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
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Hello") + ((currentUName.length > 0) ? ", " + currentUName : "")
                        wrapMode: Text.WordWrap
                    }

                    Item {  width: 1; height: 1;    }

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("There is no active account found")
                        wrapMode: Text.WordWrap
                    }
                }

                IconSimpleButton
                {
                    id: buttonGoToAccount
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.horizontalCenter: parent.horizontalCenter

                    onSigButtonClicked: stage = AppDefs.AppInit_CreateUser
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
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Creating account")
                        wrapMode: Text.WordWrap
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textUserName
                        placeholderText: qsTr("User name")
                        width: parent.width
                        maximumLength: AppDefs.MAX_USERNAME_SIZE
                        focus: true
                        KeyNavigation.tab: textUserEmail
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textUserEmail
                        placeholderText: qsTr("User email")
                        width: parent.width
                        maximumLength: AppDefs.MAX_EMAIL_SIZE
                        focus: true
                        KeyNavigation.tab: textUserPass
                        validator: RegExpValidator { regExp:/^[0-9a-zA-Z]+([0-9a-zA-Z]*[-._+])*[0-9a-zA-Z]+@[0-9a-zA-Z]+([-.][0-9a-zA-Z]+)*([0-9a-zA-Z]*[.])[a-zA-Z]{2,6}$/ }
                    }

                    Item { height: 1; width: 1;}

                    /*
                    TextInput
                    {
                        id: textUserPass
                        placeholderText: qsTr("User password")
                        width: parent.width
                        maximumLength: AppDefs.MAX_PASS_SIZE
                        focus: true
                        KeyNavigation.tab: buttonCancel
                    }

                    Item { height: 1; width: 1;}
                    */

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueFontColor
                        text: qsTr("User photo")
                    }

                    ImageList
                    {
                        id: imgAccountAvatar
                        imagesCountMax: 1
                    }
                }

                IconSimpleButton
                {
                    id: buttonCancel
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    image: "qrc:/resources/img/icon_cancel.png"
                    KeyNavigation.tab: buttonCreate

                    onSigButtonClicked: stage = AppDefs.AppInit_NoData
                }

                IconSimpleButton
                {
                    id: buttonCreate
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    KeyNavigation.tab: textUserName

                    onSigButtonClicked:
                    {
                        var imgLink = ""

                        if (imgAccountAvatar.selectedImagesList.count > 0)
                            imgLink = imgAccountAvatar.selectedImagesList.get(0).fileLink

                        if (isCredentialsGood() === true)
                        {
                            app.sigCreateAccount(textUserName.text,
                                             "",//textUserPass.text,
                                             textUserEmail.text,
                                             imgLink)
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
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Hello") + ", " + currentUName
                        wrapMode: Text.WordWrap
                    }

                    Item {  width: 1; height: 1;    }

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.greyColor
                        text: qsTr("There is no active tank found")
                        wrapMode: Text.WordWrap
                    }
                }

                IconSimpleButton
                {
                    id: buttonGoToTank
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    anchors.horizontalCenter: parent.horizontalCenter

                    onSigButtonClicked:
                    {
                        stage = AppDefs.AppInit_CreateTank
                        textTankName.forceActiveFocus()
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
                    anchors.verticalCenterOffset: 32 * app.scale
                    height: 300 * app.scale
                    width: parent.width
                    spacing: AppTheme.padding * app.scale

                    Text
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: AppTheme.compHeight * app.scale
                        width: parent.width - AppTheme.padding * 2 * app.scale
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontBigSize * app.scale
                        color: AppTheme.blueColor
                        text: qsTr("Creating tank profile")
                        wrapMode: Text.WordWrap
                    }

                    Item { height: 1; width: 1;}

                    TextInput
                    {
                        id: textTankName
                        placeholderText: qsTr("Tank name")
                        width: parent.width
                        maximumLength: AppDefs.MAX_TANKNAME_SIZE
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
                                color: AppTheme.blueFontColor
                                text: app.currentDimensionUnits()
                            }
                        }

                        TextInput
                        {
                            id: textTankW
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
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
                                color: AppTheme.blueFontColor
                                text: app.currentDimensionUnits()
                            }
                        }

                        TextInput
                        {
                            id: textTankH
                            anchors.right: parent.right
                            placeholderText: qsTr("50")
                            width: (parent.width - rectRow.unitWidth * 3) / 3
                            maximumLength: AppDefs.MAX_TANKDIMENSION_SIZE
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
                                color: AppTheme.blueFontColor
                                text: app.currentDimensionUnits()
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

                    Text
                    {
                        verticalAlignment: Text.AlignVCenter
                        font.family: AppTheme.fontFamily
                        font.pixelSize: AppTheme.fontNormalSize * app.scale
                        color: AppTheme.blueFontColor
                        text: qsTr("Tank image")
                    }

                    ImageList
                    {
                        id: imgTankAvatar
                        imagesCountMax: 1
                    }
                }

                IconSimpleButton
                {
                    id: buttonCancel2
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    image: "qrc:/resources/img/icon_cancel.png"
                    KeyNavigation.tab: buttonCreate2

                    onSigButtonClicked: stage = AppDefs.AppInit_UserExist
                }

                IconSimpleButton
                {
                    id: buttonCreate2
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: AppTheme.margin * app.scale
                    KeyNavigation.tab: textTankName

                    onSigButtonClicked:
                    {
                        var imgLink = ""

                        if (imgTankAvatar.selectedImagesList.count > 0)
                            imgLink = imgTankAvatar.selectedImagesList.get(0).fileLink

                        if (isTankParamsGood() === true)
                        {
                            app.sigCreateTank(textTankName.text,
                                              "",
                                              comboTankType.currentIndex,
                                              app.deconvertDimension(textTankL.text),
                                              app.deconvertDimension(textTankW.text),
                                              app.deconvertDimension(textTankH.text),
                                              imgLink)
                        }
                    }
                }
            }
        }
    }
}
