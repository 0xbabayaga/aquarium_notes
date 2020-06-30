pragma Singleton
import QtQuick 2.12

QtObject
{
    property real opacityEnabled: 1
    property real opacityDisabled: 0.5
    property int rowSpacing: 8
    property int padding: 16
    property int margin: 32
    property int radius: 8

    property int rightWidth: 261
    property int leftWidth: 82
    property int rowHeightMin: 48
    property int rowHeight: 64
    property int compHeight: 32

    //property string fontFamily: "Century Gothic"

    property color whiteColor: "#ffffff"
    property color blueColor: "#00a7b8"
    property color greenColor: "#00c082"
    property color hideColor: "#20000000"
    property color greyColor: "#919191"
    property color greyDarkColor: "#808080"
    property color shideColor: "#20bababa"

    property color positiveChangesColor: "#D000A000"
    property color negativeChangesColor: "#C0C00000"

    property color backLightBlueColor: "#1000adbc"
    property color lightBlueColor: "#e9feff"
    property color lightGreenColor: "#e7fef2"

    property int fontSuperSmallSize: 12
    property int fontSmallSize: 14
    property int fontNormalSize: 16
    property int fontBigSize: 22
    property int fontSuperBigSize: 32

    property FontLoader appFont: FontLoader { source: "qrc:/resources/font/Century.otf" }

    property string fontFamily: appFont.name
}
