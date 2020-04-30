#ifndef APPDEFS_H
#define APPDEFS_H

#include <QtGlobal>
#include <QQmlEngine>

class AppDef : public QObject
{
    Q_OBJECT

public:
    AppDef() : QObject() {}

    enum AppInitEnum
    {
        AppInit_NoData = 0,
        AppInit_UserExist = 2,
        AppInit_CreateTank = 3,
        AppInit_TankExist = 4,
        AppInit_Completed = AppInit_TankExist
    };

    Q_ENUMS(AppInitEnum)

    static void declareQML() {  qmlRegisterType<AppDef>("AppInitEnum", 1, 0, "AppInitEnum");     }
};

/*
class PageSett : public QObject
{
    Q_OBJECT

public:
    PageSett() : QObject() {}

    enum Pages
    {
        //Network settings
        PAGE_DATETIME = 1,
        PAGE_ALARMS = 2,
        PAGE_DISPLAY = 3,
        PAGE_LIGHT = 4,
    };

    Q_ENUMS(Pages)

    static void declareQML() {  qmlRegisterType<PageSett>("Pages", 1, 0, "Pages");     }
};
*/

#endif // APPDEFS_H
