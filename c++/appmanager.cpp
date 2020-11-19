#include "appmanager.h"
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QQmlContext>
#include <QDateTime>
#include <QDebug>
#include <QList>
#include <QStringList>
#include <QImage>
#include <QGuiApplication>
#include <QTranslator>
#include <QDirIterator>
#include <QThread>
#include <QLocale>
#include <QFuture>
#include <QtConcurrent>
#include "AppDefs.h"
#include "dbobjects.h"
#include "position.h"
#include "version.h"

const static QString settMagicKey = "ww2SD6^&A8293487";

const static QString SETT_LANG = "lang";
const static QString SETT_MAGICKEY = "magickey";
const static QString SETT_DIMENSIONUNITS = "dimunits";
const static QString SETT_VOLUMEUNITS = "volumeunits";
const static QString SETT_DATEFORMAT = "dateformat";

const static QMap<QString, QString> langNamesMap =
{
    {   "en",   QObject::tr("English")      },
    {   "ru",   QObject::tr("Русский")      },
    {   "be",   QObject::tr("Беларускi")    },
};

#ifdef  Q_OS_ANDROID
#include <QtAndroidExtras>
#include <QAndroidIntent>
const static QStringList permissions = { "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE" };
#endif

AppManager::AppManager(QQmlApplicationEngine *engine, QObject *parent) : DBManager(false, parent)
{
    qmlEngine = engine;

    connect(qmlEngine, SIGNAL(objectCreated(QObject*, const QUrl)), this, SLOT(onQmlEngineLoaded(QObject*, const QUrl)));

    readAppSett();

    actionList = new ActionList();
    fMan = new FileManager(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));

    /* Initializing all models to avoid Qml reference error */
    qmlEngine->rootContext()->setContextProperty("tanksListModel", QVariant::fromValue(curSelectedObjs.listOfUserTanks));
    qmlEngine->rootContext()->setContextProperty("actionsListModel", QVariant::fromValue(*actionList->getData()));
    qmlEngine->rootContext()->setContextProperty("allParamsListModel", QVariant::fromValue(paramsGuiList));
    qmlEngine->rootContext()->setContextProperty("curValuesListModel", QVariant::fromValue(curSelectedObjs.listOfCurrValues));
    qmlEngine->rootContext()->setContextProperty("graphPointsList", QVariant::fromValue(pointList));
    qmlEngine->rootContext()->setContextProperty("datesList", QVariant::fromValue(datesList));
    qmlEngine->rootContext()->setContextProperty("importFileListModel", QVariant::fromValue(fMan->getFileList()));

    createTankTypesList();

    openDB();

    curSelectedObjs.lastSmpId = getLastSmpId();
    curSelectedObjs.curSmpId = curSelectedObjs.lastSmpId;

    createLangList();

    loadTranslations(appSett.value(SETT_LANG).toInt());

    position = new Position();

    connect(position, SIGNAL(positionDetected()), this, SLOT(onPositionDetected()));

#ifdef  Q_OS_ANDROID
    QAndroidIntent serviceIntent(QtAndroid::androidActivity().object(),
                                        "org/tikava/AquariumNotes/Background");
    QAndroidJniObject result = QtAndroid::androidActivity().callObjectMethod(
                "startService",
                "(Landroid/content/Intent;)Landroid/content/ComponentName;",
                serviceIntent.handle().object());
#endif
}

AppManager::~AppManager()
{
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString, QString)), this, SLOT(onGuiUserCreate(QString, QString, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigEditAccount(QString, QString, QString, QString)), this, SLOT(onGuiUserEdit(QString, QString, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteAccount()), this, SLOT(onGuiUserDelete()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, QString, int, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigEditTank(QString, QString, QString, int, int, int, int, QString)), this, SLOT(onGuiTankEdit(QString, QString, QString, int, int, int, int, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteTank()), this, SLOT(onGuiTankDelete()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, float)), this, SLOT(onGuiAddRecord(int, int, float)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigEditRecord(int, int, double)), this, SLOT(onGuiEditRecord(int, int, double)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecordNotes(int, QString, QString)), this, SLOT(onGuiAddRecordNote(int, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigEditRecordNotes(int, QString, QString)), this, SLOT(onGuiEditRecordNote(int, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddAction(QString, QString, int, int, int)), this, SLOT(onGuiAddActionRecord(QString, QString, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigEditAction(int, QString, QString, int, int, int)), this, SLOT(onGuiEditActionRecord(int, QString, QString, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteAction(int)), this, SLOT(onGuiDeleteActionRecord(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigActionViewPeriodChanged(int)), this, SLOT(onGuiActionViewPeriodChanged(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigRefreshData()), this, SLOT(onGuiRefreshData()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigFullRefreshData()), this, SLOT(onGuiFullRefreshData()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCurrentSmpIdChanged(int)), this, SLOT(onGuiCurrentSmpIdChanged(int)));
    disconnect(qmlEngine, SIGNAL(objectCreated(QObject*, const QUrl)), this, SLOT(onQmlEngineLoaded(QObject*, const QUrl)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigOpenGallery()), this, SLOT(onGuiOpenGallery()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigLanguageChanged(int)), this, SLOT(onGuiLanguageChanged(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigDimensionUnitsChanged(int)), this, SLOT(onGuiDimensionUnitsChanged(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigVolumeUnitsChanged(int)), this, SLOT(onGuiVolumeUnitsChanged(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigDateFormatChanged(int)), this, SLOT(onGuiDateFormatChanged(int)));
    disconnect(position, SIGNAL(positionDetected), this, SLOT(onPositionDetected));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigTankStoryLoad(int)), this, SLOT(onGuiTankStoryLoad(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigRegisterApp()), this, SLOT(onGuiRegisterApp()));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigExportData(QString)), this, SLOT(onGuiExportData(QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigImportData(QString)), this, SLOT(onGuiImportData(QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigGetImportFilesList()), this, SLOT(onGuiGetImportFilesList()));

    disconnect(cloudMan, SIGNAL(response_error(int)), this, SLOT(onCloudResponse_Error(int)));
    disconnect(cloudMan, SIGNAL(response_registerApp(int, QString, QString, QString)), this, SLOT(onCloudResponse_Register(int, QString, QString, QString)));
    disconnect(cloudMan, SIGNAL(response_appUpdates(int, int)), this, SLOT(onCloudResponse_AppUpdates(int, int)));

    if (position != nullptr)
        delete position;

    if (curSelectedObjs.user != nullptr)
        delete curSelectedObjs.user;

    if (actionList != nullptr)
        delete actionList;
}

void AppManager::init()
{
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString, QString)), this, SLOT(onGuiUserCreate(QString, QString, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigEditAccount(QString, QString, QString, QString)), this, SLOT(onGuiUserEdit(QString, QString, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteAccount()), this, SLOT(onGuiUserDelete()));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, QString, int, int, int, int, QString)), this, SLOT(onGuiTankCreate(QString, QString, int, int, int, int, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigEditTank(QString, QString, QString, int, int, int, int, QString)), this, SLOT(onGuiTankEdit(QString, QString, QString, int, int, int, int, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteTank(QString)), this, SLOT(onGuiTankDelete(QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, double)), this, SLOT(onGuiAddRecord(int, int, double)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigEditRecord(int, int, double)), this, SLOT(onGuiEditRecord(int, int, double)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecordNotes(int, QString, QString)), this, SLOT(onGuiAddRecordNote(int, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigEditRecordNotes(int, QString, QString)), this, SLOT(onGuiEditRecordNote(int, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddAction(QString, QString, int, int, int)), this, SLOT(onGuiAddActionRecord(QString, QString, int, int, int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigEditAction(int, QString, QString, int, int, int)), this, SLOT(onGuiEditActionRecord(int, QString, QString, int, int, int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigDeleteAction(int)), this, SLOT(onGuiDeleteActionRecord(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigActionViewPeriodChanged(int)), this, SLOT(onGuiActionViewPeriodChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigRefreshData()), this, SLOT(onGuiRefreshData()));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigFullRefreshData()), this, SLOT(onGuiFullRefreshData()));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCurrentSmpIdChanged(int)), this, SLOT(onGuiCurrentSmpIdChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigOpenGallery()), this, SLOT(onGuiOpenGallery()));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigLanguageChanged(int)), this, SLOT(onGuiLanguageChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigDimensionUnitsChanged(int)), this, SLOT(onGuiDimensionUnitsChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigVolumeUnitsChanged(int)), this, SLOT(onGuiVolumeUnitsChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigDateFormatChanged(int)), this, SLOT(onGuiDateFormatChanged(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigTankStoryLoad(int)), this, SLOT(onGuiTankStoryLoad(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigRegisterApp()), this, SLOT(onGuiRegisterApp()));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigExportData(QString)), this, SLOT(onGuiExportData(QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigImportData(QString)), this, SLOT(onGuiImportData(QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigGetImportFilesList()), this, SLOT(onGuiGetImportFilesList()));

    setSettAfterQMLReady();

    position->get();

#ifdef  Q_OS_ANDROID
    setAndroidFlag(true);
#endif
    setLastSmpId(curSelectedObjs.lastSmpId);

    qmlEngine->rootContext()->setContextProperty("aquariumTypesListModel", QVariant::fromValue(aquariumTypeList));

    getCurrentObjs(true);

    if (curSelectedObjs.user != 0)
        cloudMan = new CloudManager(curSelectedObjs.user->man_id);
    else
        cloudMan = new CloudManager("");

    connect(cloudMan, SIGNAL(response_error(int, QString)), this, SLOT(onCloudResponse_Error(int, QString)));
    connect(cloudMan, SIGNAL(response_registerApp(int, QString, QString, QString)), this, SLOT(onCloudResponse_Register(int, QString, QString, QString)));
    connect(cloudMan, SIGNAL(response_appUpdates(int, int)), this, SLOT(onCloudResponse_AppUpdates(int, int)));

    checkAppRegistered();

    cloudMan->request_getAppUpdates();

#ifdef Q_OS_ANDROID
    for (int i = 0; i < permissions.size(); i++)
    {
        QtAndroid::PermissionResult r = QtAndroid::checkPermission(permissions.at(i));

        QtAndroid::requestPermissionsSync( QStringList() << permissions.at(i) );

        r = QtAndroid::checkPermission(permissions.at(i));

        qDebug() << "Permission " << permissions.at(i) << ((r == QtAndroid::PermissionResult::Denied) ? " DENIED" : " GRANTED ");
    }
#endif
}

void AppManager::readAppSett()
{
    if (appSett.value(SETT_MAGICKEY) != settMagicKey)
    {
        appSett.setValue(SETT_DIMENSIONUNITS, AppDef::Dimensions_CM);
        appSett.setValue(SETT_VOLUMEUNITS, AppDef::Volume_L);
        appSett.setValue(SETT_DATEFORMAT, AppDef::DateFormat_DD_MM_YYYY);
        appSett.setValue(SETT_MAGICKEY, settMagicKey);

        if (QLocale::system().name().section(' ', 0, 0) == "ru_RU" ||
            QLocale::system().name().section(' ', 0, 0) == "ru_BY")
            appSett.setValue(SETT_LANG, AppDef::Lang_Russian);
        else if (QLocale::system().name().section(' ', 0, 0) == "be_BY")
            appSett.setValue(SETT_LANG, AppDef::Lang_Belarussian);
        else
            appSett.setValue(SETT_LANG, AppDef::Lang_English);
    }
    else
    {
        if (appSett.value(SETT_LANG) >= AppDef::Lang_End)
            appSett.setValue(SETT_LANG, AppDef::Lang_English);

        if (appSett.value(SETT_DIMENSIONUNITS) >= AppDef::Dimensions_End)
            appSett.setValue(SETT_DIMENSIONUNITS, AppDef::Dimensions_CM);

        if (appSett.value(SETT_VOLUMEUNITS) >= AppDef::Volume_End)
            appSett.setValue(SETT_VOLUMEUNITS, AppDef::Volume_L);

        if (appSett.value(SETT_DATEFORMAT) >= AppDef::DateFormat_End)
            appSett.setValue(SETT_DATEFORMAT, AppDef::DateFormat_DD_MM_YYYY);
    }
}

void AppManager::setSettAfterQMLReady()
{
    setQmlParam("app", "global_DIMUNITS", QVariant(appSett.value(SETT_DIMENSIONUNITS).toInt()));
    setQmlParam("app", "global_VOLUNITS", QVariant(appSett.value(SETT_VOLUMEUNITS).toInt()));
    setQmlParam("app", "global_DATEFORMAT", QVariant(appSett.value(SETT_DATEFORMAT).toInt()));

    setQmlParam("app", "global_APP_VERSION", APP_VERSION);
    setQmlParam("app", "global_APP_NAME", APP_NAME);
    setQmlParam("app", "global_APP_DOMAIN", APP_DOMAIN);
    setQmlParam("app", "global_USERREGION", position->userRegion());
    setQmlParam("app", "global_USERCOUNTRY", position->userCountry());
    setQmlParam("app", "global_USERCITY", position->userCity());

    setQmlParam("comboLang", "currentIndex", QVariant(appSett.value(SETT_LANG).toInt()));
    setQmlParam("comboDimensions", "currentIndex", QVariant(appSett.value(SETT_DIMENSIONUNITS).toInt()));
    setQmlParam("comboVolumeUnits", "currentIndex", QVariant(appSett.value(SETT_VOLUMEUNITS).toInt()));
    setQmlParam("comboDateFormat", "currentIndex", QVariant(appSett.value(SETT_DATEFORMAT).toInt()));
}

void AppManager::checkAppRegistered()
{
//#define FULL_FEATURES_ENABLED

#ifdef FULL_FEATURES_ENABLED
    setQmlParam("app", "global_FULLFEATURES", true);
    setQmlParam("app", "global_APP_TYPE", AppDef::UStatus_EnabledPro);
#else
    if (currentSelectedObjs()->user != 0)
    {
        QString appKey = getAppKey();

        if (cloudMan->isKeyValid(appKey) == true)
            setQmlParam("app", "global_FULLFEATURES", true);

        setQmlParam("app", "global_APP_TYPE", AppDef::UStatus_Enabled);
    }
#endif
}

bool AppManager::loadTranslations(int id)
{
    LangObj *obj = nullptr;

    if (id < langNamesMap.count())
    {
        obj = (LangObj*) langsList.at(id);

        if (obj != nullptr)
        {
            qApp->removeTranslator(&translator);

            if (translator.load(obj->fileName()) == true)
                qApp->installTranslator(&translator);
            else
                qDebug() << "Cannot load translation #" << id;

            return true;
        }
        else
            return false;
    }

    return false;
}

void AppManager::createTankTypesList()
{
    aquariumTypeList.clear();

    for (int i = 0; i < AquariumType::EndOfList; i++)
    {
        TankTypeObj *obj = new TankTypeObj(i, getAquariumTypeString((AquariumType)i));
        aquariumTypeList.append(obj);
    }

    qmlEngine->rootContext()->setContextProperty("aquariumTypesListModel", QVariant::fromValue(aquariumTypeList));
}

void AppManager::createLangList()
{
    QString curFileName = "";
    QString curLangName = "";

    QDirIterator it(":/resources/langs", QDirIterator::Subdirectories);
    int id = 0;

    langsList.clear();

    while (it.hasNext())
    {
        curFileName = it.next();

        for (QMap<QString, QString>::const_iterator i = langNamesMap.begin(); i != langNamesMap.end(); i++)
        {
            if (curFileName.contains(i.key()) == true)
                curLangName = i.value();
        }

        LangObj *obj = new LangObj(id, curLangName, curFileName);
        langsList.append(obj);
    }
}

bool AppManager::getCurrentObjs(bool isFullUpdate)
{
    getCurrentUser();

    qDebug() << "Current user = " << curSelectedObjs.user;

    if (curSelectedObjs.user != nullptr)
    {
        getUserTanksList();

        setCurrentUser(curSelectedObjs.user->uname,
                       curSelectedObjs.user->email,
                       curSelectedObjs.user->avatar_img,
                       curSelectedObjs.user->date_create);


        if (curSelectedObjs.listOfUserTanks.size() > 0)
        {
            setInitialDialogStage(AppDef::AppInit_Completed, curSelectedObjs.user->uname);

            if (isFullUpdate == true)
                curSelectedObjs.tankIdx = 0;

            qmlEngine->rootContext()->setContextProperty("tanksListModel", QVariant::fromValue(curSelectedObjs.listOfUserTanks));

            getParamsListGui();

            getLatestParamsGui();

            getHistoryParams();

            getActionCalendarGui();

            return true;
        }
        else
            setInitialDialogStage(AppDef::AppInit_UserExist, curSelectedObjs.user->uname);
    }
    else
        setInitialDialogStage(AppDef::AppInit_NoData, "");

    return false;
}

void AppManager::getParamsListGui()
{
    getParamsList(currentTankSelected()->tankId(), (AquariumType) currentTankSelected()->type());

    qmlEngine->rootContext()->setContextProperty("allParamsListModel", QVariant::fromValue(paramsGuiList));
}

void AppManager::getLatestParamsGui()
{
    getLatestParams();

    qmlEngine->rootContext()->setContextProperty("curValuesListModel", QVariant::fromValue(curSelectedObjs.listOfCurrValues));
}

void AppManager::getActionCalendarGui()
{
    getActionCalendar(currentTankSelected()->tankId(), false);

    setQmlParam("tab_Action", "totalActionsCnt", actionList->getTotalCnt());
    qmlEngine->rootContext()->setContextProperty("actionsListModel", QVariant::fromValue(*actionList->getData()));
}

bool AppManager::getHistoryParams()
{
    QList<int> idList;
    QVariantMap points;
    QList<QVariantMap> curveList;
    int pointCntMax = 0;
    int xMin = INT_MAX, xMax = INT_MIN;
    float yMin = __FLT_MAX__, yMax = __FLT_MIN__;

    curveList.clear();

    getParamIdList(&idList);

    pointList.clear();
    datesList.clear();

    for (int i = 0; i < idList.size(); i++)
    {
        QSqlQuery qParams("SELECT SMP_ID, VALUE, TIMESTAMP FROM HISTORY_VALUE_TABLE "
                          "WHERE PARAM_ID = '"+QString::number(idList.at(i))+"' AND "
                          "TANK_ID = '" + currentTankSelected()->tankId() + "'");

        points.clear();

        while (qParams.next())
        {
            if (i == 0)
            {
                PointObj *pt = new PointObj(qParams.value(0).toInt(), qParams.value(2).toInt(), qParams.value(1).toFloat());
                pointList.append(pt);
                datesList.append(pt);
            }

            points.insert(QString::number(qParams.value(2).toInt()), qParams.value(1).toFloat());
        }

        if (points.size() > pointCntMax)
            pointCntMax = points.size();

        curveList.append(points);
    }

    std::sort(datesList.begin(), datesList.end(), less);

    qmlEngine->rootContext()->setContextProperty("datesList", QVariant::fromValue(datesList));

    for (int i = 0; i < curveList.size(); i++)
    {
        /* Looking for min max Dates */
        for (QVariantMap::const_iterator it = curveList.at(i).begin(); it != curveList.at(i).end(); it++)
        {
            if (it.key().toInt() < xMin)
                xMin = it.key().toInt();

            if (it.key().toInt() > xMax)
                xMax = it.key().toInt();
        }
    }

    clearDiagrams();

    for (int i = 0; i < curveList.size(); i++)
    {
        yMin = __FLT_MAX__;
        yMax = __FLT_MIN__;

        /* Looking for min\max for current curve */
        for (QVariantMap::const_iterator it = curveList.at(i).begin(); it != curveList.at(i).end(); it++)
        {
            if (it.value().toFloat() < yMin)
                yMin = it.value().toFloat();

            if (it.value().toFloat() > yMax)
                yMax = it.value().toFloat();
        }

        if (yMin > 0)
            yMin -= (yMax - yMin) * DIAGRAMM_DRAW_GAP_BOTTOM;

        if (yMin < 0.1)
            yMin = 0;

        if (yMax > 0)
            yMax += (yMax - yMin) * DIAGRAMM_DRAW_GAP_TOP;

        addDiagram(0, idList.at(i), xMin, xMax, yMin, yMax, curveList.at(i));
    }

    drawDiagrams(pointCntMax - 1);

    qmlEngine->rootContext()->setContextProperty("graphPointsList", QVariant::fromValue(pointList));

    return false;
}

void AppManager::setInitialDialogStage(int stage, QString name)
{
    if (stage != AppDef::AppInit_Completed)
        //setQmlParam("app", "isAccountCreated", false);
        setQmlParam("page_AccountWizard", "visible" , true);

    setQmlParam("page_AccountWizard", "stage", stage);
    setQmlParam("page_AccountWizard", "currentUName", name);

    setQmlParam("rectAppLoadingSpinner", "visible", false);
}

void AppManager::setLastSmpId(int id)
{
    setQmlParam("app", "lastSmpId", id);
}

void AppManager::setAndroidFlag(bool flag)
{
    setQmlParam("app", "isAndro", flag);
}

void AppManager::setGalleryImageSelected(QString imgUrl)
{
    setQmlParam("imageList", "galleryImageSelected", imgUrl);
    setQmlParam("imgUserAvatar", "galleryImageSelected", imgUrl);
    setQmlParam("imgTankAvatar", "galleryImageSelected", imgUrl);
}

void AppManager::setCurrentUser(QString uname, QString email, QString imgLink, int dt)
{
    setQmlParam("app", "curUserName", uname);
    setQmlParam("app", "curUserEmail", email);
    setQmlParam("app", "curUserAvatar", imgLink);
    setQmlParam("app", "curUserDateCreate", dt);
}

void AppManager::setExportingState(QString message)
{
    setQmlParam("exportDialog", "inProgress", false);
    setQmlParam("exportDialog", "message", message);
}

void AppManager::setImportingState(QString message)
{
    setQmlParam("importDialog", "inProgress", false);
    setQmlParam("importDialog", "message", message);
}

void AppManager::resetStoryView()
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tankStory");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "clearStory");
    else
        qDebug() << "tankStory not found!";
}

bool AppManager::setQmlParam(QString objName, QString name, QVariant value)
{
    QObject *obj = nullptr;
    bool res = false;

    if (qmlEngine->rootObjects().first()->objectName() == objName)
       obj = qmlEngine->rootObjects().first();
    else
        obj = qmlEngine->rootObjects().first()->findChild<QObject*>(objName);

    if (obj != nullptr)
    {
        obj->setProperty(name.toLocal8Bit(), value);
        res = true;
    }
    else
        qDebug() << "Cannot find "<< objName << "object";

    return res;
}

QString AppManager::generateExportFileName()
{
    QString name = QString(APP_EXPORT_FILE_TEMPLATE).arg(QDateTime::currentDateTime().toString("yyyyMMdd_hhmm"));

    return name;
}

void AppManager::clearDiagrams()
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tab_Graph");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "clearDiagrams");
}

void AppManager::showAppUpdateNotification(int version, int releasedate)
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("page_Main");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "showAppUpdated",
                                  Q_ARG(QVariant, version),
                                  Q_ARG(QVariant, releasedate));
    else
        qDebug() << "page_Main not found!";
}

void AppManager::addDiagram(int num, int paramId, int xMin, int xMax, float yMin, float yMax, QVariantMap points)
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tab_Graph");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "addDiagram",
                                  Q_ARG(QVariant, num),
                                  Q_ARG(QVariant, paramId),
                                  Q_ARG(QVariant, xMin),
                                  Q_ARG(QVariant, xMax),
                                  Q_ARG(QVariant, yMin),
                                  Q_ARG(QVariant, yMax),
                                  Q_ARG(QVariant, QVariant::fromValue(points)));
    else
        qDebug() << "tab_Graph not found!";
}

void AppManager::drawDiagrams(int selectedPoint)
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tab_Graph");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "redraw", Q_ARG(QVariant, selectedPoint));
}

void AppManager::onQmlEngineLoaded(QObject *object, const QUrl &url)
{
    Q_UNUSED(url);

    if (object != 0)
        init();
}

void AppManager::onGuiUserCreate(QString uname, QString upass, QString email, QString img)
{
#ifdef FULL_FEATURES_ENABLED
    AppDef::AppUserStatus status = AppDef::UStatus_EnabledPro;
#else
    AppDef::AppUserStatus status = AppDef::UStatus_Enabled;
#endif

    if (createUser(uname, upass, "", email, img, status) == true)
    {
        getCurrentUser();
        setInitialDialogStage(AppDef::AppInit_UserExist, curSelectedObjs.user->uname);

        cloudMan->setUserId(curSelectedObjs.user->man_id);
        checkAppRegistered();
    }
}

void AppManager::onGuiUserEdit(QString uname, QString upass, QString email, QString img)
{
    if (editUser(uname, "", "", email, img) == true)
    {
        getCurrentUser();

        setCurrentUser(curSelectedObjs.user->uname,
                       curSelectedObjs.user->email,
                       curSelectedObjs.user->avatar_img,
                       curSelectedObjs.user->date_create);
    }
}

void AppManager::onGuiUserDelete()
{
    if (deleteUser() == true)
    {
        getCurrentObjs(true);

        setCurrentUser("", "", "", 0);
    }
}

void AppManager::onGuiTankCreate(QString name, QString desc, int type, int l, int w, int h, QString imgFile)
{
    if (createTank(name, desc, curSelectedObjs.user->man_id, type, l, w, h, imgFile) == true)
    {
        getCurrentObjs(true);
        setInitialDialogStage(AppDef::AppInit_Completed, curSelectedObjs.user->uname);
    }
}

void AppManager::onGuiTankEdit(QString tankId, QString name, QString desc, int type, int l, int w, int h, QString imgFile)
{
    if (editTank(tankId, name, desc, type, l, w, h, imgFile) == true)
    {
        getCurrentObjs(true);
    }
}

void AppManager::onGuiTankDelete(QString tankId)
{
    if (deleteTank(tankId) == true)
    {
        getCurrentObjs(true);
    }
}

void AppManager::onGuiAddRecord(int smpId, int paramId, double value)
{
    addParamRecord(smpId, paramId, value);
}

void AppManager::onGuiEditRecord(int smpId, int paramId, double value)
{
    if (editParamRecord(smpId, paramId, value) == false)
        /* Means there is no such records. So create a new one. */
        addParamRecord(smpId, paramId, value);
}

void AppManager::onGuiRefreshData()
{
    curSelectedObjs.lastSmpId = getLastSmpId();
    setLastSmpId(curSelectedObjs.lastSmpId);

    getLatestParamsGui();
    getHistoryParams();
}

void AppManager::onGuiFullRefreshData()
{
    getCurrentObjs(false);

    curSelectedObjs.lastSmpId = getLastSmpId();
    setLastSmpId(curSelectedObjs.lastSmpId);
}

void AppManager::onGuiAddRecordNote(int smpId, QString note, QString imageLink)
{
    if (smpId >= 0)
    {
        if (addNoteRecord(smpId, note, imageLink) == true)
        {
            curSelectedObjs.curSmpId = getLastSmpId();
            getLatestParamsGui();
            getHistoryParams();
        }
    }
    else
    {
        curSelectedObjs.curSmpId = getLastSmpId();
        getLatestParamsGui();
        getHistoryParams();
    }
}

void AppManager::onGuiEditRecordNote(int smpId, QString note, QString imageLink)
{
    if (smpId >= 0)
    {
        if (editNoteRecord(smpId, note, imageLink) == true)
        {
            curSelectedObjs.curSmpId = getLastSmpId();
            getLatestParamsGui();
            getHistoryParams();
        }
    }
    else
    {
        curSelectedObjs.curSmpId = getLastSmpId();
        getLatestParamsGui();
        getHistoryParams();
    }
}

void AppManager::onGuiAddActionRecord(QString name, QString desc, int periodType, int period, int tm)
{
    if (addActionRecord(currentTankSelected()->tankId(), name, desc, periodType, period, tm) == true)
        getActionCalendarGui();
}

void AppManager::onGuiEditActionRecord(int id, QString name, QString desc, int periodType, int period, int tm)
{
    if (editActionRecord(id, currentTankSelected()->tankId(), name, desc, periodType, period, tm) == true)
        getActionCalendarGui();
}

void AppManager::onGuiDeleteActionRecord(int id)
{
    if (deleteActionRecord(id, currentTankSelected()->tankId()) == true)
        getActionCalendarGui();
}

void AppManager::onGuiActionViewPeriodChanged(int period)
{
    actionList->setViewPeriod((eActionListView)period);
    getActionCalendarGui();
}

void AppManager::onGuiTankStoryLoad(int index)
{
    //QDateTime t1, t2;

    //t1 = QDateTime::currentDateTime();

    getTankStoryList(index);

    //t2 = QDateTime::currentDateTime();

    //qDebug() << "#" << index << "Done in msec = " << t1.msecsTo(t2);

    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tankStory");

    for (int i = 0; i < tankStoryList.size(); i++)
    {
        if (obj != nullptr)
            QMetaObject::invokeMethod(obj, "addStoryRecord",
                                      Q_ARG(QVariant, tankStoryList.at(i)->smpId()),
                                      Q_ARG(QVariant, tankStoryList.at(i)->desc()),
                                      Q_ARG(QVariant, tankStoryList.at(i)->imgList()),
                                      Q_ARG(QVariant, tankStoryList.at(i)->dt()),
                                      Q_ARG(QVariant, QVariant::fromValue(*tankStoryList.at(i)->paramsMap())));
        else
            qDebug() << "tankStory not found!";
    }
}

void AppManager::onGuiRegisterApp()
{
    cloudMan->request_registerApp(currentSelectedObjs()->user);
}

void AppManager::onGuiGetImportFilesList()
{
    fMan->scanDirectory("*." + QString(APP_IMPORT_FILE_EXT));

    qmlEngine->rootContext()->setContextProperty("importFileListModel", QVariant::fromValue(fMan->getFileList()));
}

void AppManager::onGuiExportData(QString fileName)
{
    exportFileName = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation) + "/" + generateExportFileName();

    db.close();

    connect(&exportWatcher, &QFutureWatcher<int>::finished, this, &AppManager::onExportFinished);
    exportFuture = QtConcurrent::run(exportToFile, exportFileName);
    exportWatcher.setFuture(exportFuture);
}

void AppManager::onGuiImportData(QString fileName)
{
    exportFileName = fileName;

    db.close();

    connect(&importWatcher, &QFutureWatcher<int>::finished, this, &AppManager::onImportFinished);
    importFuture = QtConcurrent::run(importFromFile, exportFileName);
    importWatcher.setFuture(importFuture);
}

void AppManager::onExportFinished()
{
    bool exportResult = exportFuture.result();

    disconnect(&exportWatcher, &QFutureWatcher<int>::finished, this, &AppManager::onExportFinished);

    if (exportResult == true)
        setExportingState("Data exported to file:  " + exportFileName + "\n\n"
                          "Now you can Import this data on another device.");
    else
        setExportingState(tr("Error on data exporting"));

    db.open();
}

void AppManager::onImportFinished()
{
    bool importResult = importFuture.result();

    disconnect(&importWatcher, &QFutureWatcher<int>::finished, this, &AppManager::onImportFinished);

    if (importResult == true)
        setImportingState("Data imported from file:  " + exportFileName + "\nsuccessfully");
    else
        setImportingState(tr("Error on data importing"));

    db.open();

    getCurrentObjs(true);
}

void AppManager::onGuiTankSelected(int tankIdx)
{
    if (tankIdx >= 0)
    {
        if (curSelectedObjs.tankIdx != tankIdx)
        {
            resetStoryView();

            curSelectedObjs.tankIdx = tankIdx;
            isParamDataChanged = true;

            getParamsListGui();
            getLatestParamsGui();
            getHistoryParams();
            getActionCalendarGui();
        }
    }
}

void AppManager::onGuiPersonalParamStateChanged(int paramId, bool en)
{
    editPersonalParamState(currentTankSelected()->tankId(), paramId, en);
}

void AppManager::onGuiCurrentSmpIdChanged(int smpId)
{
    curSelectedObjs.curSmpId = smpId;
    getLatestParamsGui();
}

void AppManager::onGuiLanguageChanged(int id)
{
    if (id < AppDef::Lang_End && appSett.value(SETT_LANG).toInt() != id)
    {
        if (loadTranslations(id) == true)
        {
            qmlEngine->retranslate();

            createTankTypesList();
            getCurrentObjs(false);

            appSett.setValue(SETT_LANG, id);
        }
    }
}

void AppManager::onGuiDimensionUnitsChanged(int id)
{
    if (id < AppDef::Dimensions_End)
    {
        appSett.setValue(SETT_DIMENSIONUNITS, id);
        setQmlParam("app", "global_DIMUNITS", id);
    }
}

void AppManager::onGuiVolumeUnitsChanged(int id)
{
    if (id < AppDef::Volume_End)
    {
        appSett.setValue(SETT_VOLUMEUNITS, id);
        setQmlParam("app", "global_VOLUNITS", id);

        createTankTypesList();
        getCurrentObjs(false);
    }
}

void AppManager::onGuiDateFormatChanged(int id)
{
    if (id < AppDef::DateFormat_End && appSett.value(SETT_DATEFORMAT).toInt() != id)
    {
        appSett.setValue(SETT_DATEFORMAT, id);
        setQmlParam("app", "global_DATEFORMAT", id);

        createTankTypesList();
        getCurrentObjs(false);
    }
}

void AppManager::onPositionDetected()
{
    setQmlParam("app", "global_USERREGION", position->userRegion());
    setQmlParam("app", "global_USERCOUNTRY", position->userCountry());
    setQmlParam("app", "global_USERCITY", position->userCity());

    saveUserLocationIfRequired(position->userCountry(), position->userCity(), position->coorLat(), position->coorLong());
}

void AppManager::onCloudResponse_AppUpdates(int version, int date)
{
    if (version > APP_VERSION)
        showAppUpdateNotification(version, date);
}

void AppManager::onCloudResponse_Register(int error, QString errorText, QString manId, QString key)
{
    CloudManager::ReponseError err = (CloudManager::ReponseError) error;

    if (err == CloudManager::ReponseError::NoError)
    {
        if (currentSelectedObjs()->user->man_id == manId)
        {
            setAppKey(key);

            setQmlParam("cloudCommWaitDialog", "message", tr("Application is successfully registered!"));
            setQmlParam("app", "global_FULLFEATURES", true);
            setQmlParam("app", "global_APP_TYPE", AppDef::UStatus_Enabled);
        }
    }
    else if (error == CloudManager::ReponseError::Error_Specific)
    {
        setQmlParam("cloudCommWaitDialog", "header", tr("Application is not registered!"));
        setQmlParam("cloudCommWaitDialog", "message", tr("Error: ") + errorText);
    }
    else
    {
        setQmlParam("cloudCommWaitDialog", "message", tr("Application is not registered!"));
        setQmlParam("cloudCommWaitDialog", "message", tr("Error: #") + QString::number(error));
    }
}

void AppManager::onCloudResponse_Error(int error, QString errorText)
{
    if (error == CloudManager::ReponseError::Error_Specific)
    {
        setQmlParam("cloudCommWaitDialog", "header", tr("Application is not registered!"));
        setQmlParam("cloudCommWaitDialog", "message", tr("Error: ") + errorText);
    }
    else
    {
        setQmlParam("cloudCommWaitDialog", "message", tr("Application is not registered!"));
        setQmlParam("cloudCommWaitDialog", "message", tr("Error: #") + QString::number(error));
    }
}

#ifdef  Q_OS_ANDROID
QString selectedFileName;

#ifdef __cplusplus
extern "C" {
#endif
JNIEXPORT void JNICALL
Java_org_tikava_AquariumNotes_AquariumNotes_fileSelected(JNIEnv *, jobject , jstring results)
{
    qDebug() << "File selected = " << selectedFileName << "1234567890";

    selectedFileName = QAndroidJniObject(results).toString();
}
#ifdef __cplusplus
}
#endif
#endif

#ifdef  Q_OS_ANDROID
void AppManager::onGuiOpenGallery()
{
    selectedFileName = "#";

    QAndroidJniObject::callStaticMethod<void>("org/tikava/AquariumNotes/AquariumNotes",
                                              "openAnImage",
                                              "()V");
    while(selectedFileName == "#")
        qApp->processEvents();

    qDebug() << selectedFileName;

    setGalleryImageSelected(selectedFileName);
}
#else
void AppManager::onGuiOpenGallery()
{

}
#endif
