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

    enum AppDefines
    {
        MAX_TANKNAME_SIZE = 32,
        MAX_TANKDESC_SIZE = 256,
        MAX_USERNAME_SIZE = 32,
        MAX_EMAIL_SIZE = 64,
        MAX_PASS_SIZE = 16,
        MAX_TANKDIMENSION_SIZE = 4,

        MAX_USERTANKS_COUNT = 16
    };

    Q_ENUMS(AppInitEnum)
    Q_ENUMS(EnumActionRepeat)
    Q_ENUMS(EnumActionViewPeriod)
    Q_ENUMS(EnumMenuSelected)
    Q_ENUMS(AppDefines)

    static void declareQML()
    {
        qmlRegisterType<AppDef>("AppDefs", 1, 0, "AppDefs");
    }
};

#endif // APPDEFS_H
