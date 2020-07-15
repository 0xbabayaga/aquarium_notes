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

    enum EnumActionRepeat
    {
        ActionRepeat_None = 0,
        ActionRepeat_EveryDay = 1,
        ActionRepeat_EveryWeek = 2,
        ActionRepeat_EveryMonth = 3
    };

    enum EnumActionViewPeriod
    {
        ActionView_None = 0,
        ActionView_Today = 1,
        ActionView_ThisWeek = 2,
        ActionView_ThisMonth = 3
    };

    enum EnumMenuSelected
    {
        Menu_None = 0,
        Menu_Account = 1,
        Menu_TankInfo = 2,
        Menu_Settings = 3
    };

    Q_ENUMS(AppInitEnum)
    Q_ENUMS(EnumActionRepeat)
    Q_ENUMS(EnumActionViewPeriod)
    Q_ENUMS(EnumMenuSelected)

    static void declareQML()
    {
        qmlRegisterType<AppDef>("AppDefs", 1, 0, "AppDefs");
        //qmlRegisterType<AppDef>("EnumActionRepeat", 1, 0, "EnumActionRepeat");
    }
};

/*
class ActionRepeat : public QObject
{
    Q_OBJECT

public:
    ActionRepeat() : QObject() {}

    enum EnumActionRepeat
    {
        ActionRepeat_None = 0,
        ActionRepeat_EveryDay = 1,
        ActionRepeat_EveryWeek = 2,
        ActionRepeat_EveryMonth = 3
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
