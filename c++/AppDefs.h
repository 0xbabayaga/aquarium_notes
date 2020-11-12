#ifndef APPDEFS_H
#define APPDEFS_H

#include <QtGlobal>
#include <QQmlEngine>

#define APP_ORG                         "AquariumNotes"
#define APP_DOMAIN                      "www.tikava.by"
#define APP_NAME                        "AquariumNotes"
#define APP_EXPORT_FILE_TEMPLATE        "ExportedData_%1.as"

class AppDef : public QObject
{
    Q_OBJECT

public:
    AppDef() : QObject() {}

    enum AppInitEnum
    {
        AppInit_NoData = 0,
        AppInit_CreateUser = 1,
        AppInit_UserExist = 2,
        AppInit_CreateTank = 3,
        AppInit_TankExist = 4,
        AppInit_Completed = AppInit_TankExist
    };

    enum AppUserStatus
    {
        UStatus_Disabled = 0,
        UStatus_Enabled = 1,
        UStatus_EnabledPro = 2,
        UStatus_Blocked = -1
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
        Menu_Settings = 3,
        Menu_About = 4
    };

    enum AppDefines
    {
        MAN_ID_LENGTH = 32,

        MAN_ID_CUT_MD5 = 7,

        APP_KEY_LENGTH = 256,
        APP_KEY_SEED = 77,

        MAX_TANKNAME_SIZE = 20,
        MAX_TANKDESC_SIZE = 256,
        MAX_USERNAME_SIZE = 32,
        MAX_EMAIL_SIZE = 64,
        MAX_PASS_SIZE = 16,
        MAX_TANKDIMENSION_SIZE = 4,
        MAX_ACTIONDESC_SIZE = 256,
        MAX_ACTIONNAME_SIZE = 128,
        MAX_ACTIONDESCSHORT_SIZE = 64,

        MAX_FILENAME_SIZE = 32,

        MAX_USERTANKS_COUNT = 16,

        TANKS_COUNT_LIMIT = 1,
        TANKS_COUNT_FULL_LIMIT = MAX_USERTANKS_COUNT,
        ACTIONS_COUNT_LIMIT = 2,
        ACTIONS_COUNT_FULL_LIMIT = 32,
        NOTE_IMAGES_COUNT_LIMIT = 1,
        NOTE_IMAGES_COUNT_FULL_LIMIT = 8,
        STORY_VIEW_MONTH_LIMIT = 1,

        MAX_NOTETEXT_SIZE = 128,

        MAX_IMAGE_WIDTH = 1280,
        MAX_IMAGE_HEIGHT = 1280,
        APP_TIP_SHOW_TIME = 5000
    };

    enum EnumDateFormat
    {
        DateFormat_MM_DD_YYYY = 0,
        DateFormat_DD_MM_YYYY = 1,
        DateFormat_YYYY_MM_DD = 2,
        DateFormat_End = 3
    };

    enum EnumSystemMeasurement
    {
        System_Metric = 0,
        System_Imperial = 1,
        System_End = 2
    };

    enum EnumDimensions
    {
        Dimensions_CM = 0,
        Dimensions_INCH = 1,
        Dimensions_End = 2
    };

    enum EnumVolume
    {
        Volume_L = 0,
        Volume_G_US = 1,
        Volume_G_UK = 2,
        Volume_End = 3
    };

    enum EnumLang
    {
        Lang_English = 0,
        Lang_Belarussian = 1,
        Lang_Russian = 2,
        Lang_End = 3
    };

    Q_ENUMS(AppInitEnum)
    Q_ENUMS(EnumActionRepeat)
    Q_ENUMS(EnumActionViewPeriod)
    Q_ENUMS(EnumMenuSelected)
    Q_ENUMS(EnumLang)
    Q_ENUMS(EnumDateFormat)
    Q_ENUMS(EnumSystemMeasurement)
    Q_ENUMS(EnumDimensions)
    Q_ENUMS(EnumVolume)
    Q_ENUMS(AppDefines)
    Q_ENUMS(AppUserStatus)

    static void declareQML()
    {
        qmlRegisterType<AppDef>("AppDefs", 1, 0, "AppDefs");
    }
};

#endif // APPDEFS_H
