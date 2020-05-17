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

    property string fontFamily: "Century Gothic"

    property color whiteColor: "#ffffff"
    property color blueColor: "#00adbc"
    property color greenColor: "#00c082"
    property color hideColor: "#20000000"
    property color greyColor: "#aaaaaa"
    property color greyDarkColor: "#808080"
    property color shideColor: "#20bababa"

    property color lightBlueColor: "#e9feff"
    property color lightGreenColor: "#e7fef2"

    property int fontSmallSize: 14
    property int fontNormalSize: 16
    property int fontBigSize: 22
    property int fontSuperBigSize: 32
}
