#include "dbmanager.h"
#include <QtSql>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QQmlContext>
#include <QDateTime>
#include <QDebug>
#include <QList>
#include <QStringList>
#include "AppDefs.h"
#include "dbobjects.h"

#ifdef  Q_OS_ANDROID
#include <QtAndroidExtras>
const static QStringList permissions = { "android.permission.READ_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE" };
#endif

const static QString aquariumTypeNames[AquariumType::EndOfList] =
{
    QString("Fish Reef"),           /* 0 */
    QString("Soft Coral Reef"),     /* 1 */
    QString("Mixed Reef"),          /* 2 */
    QString("SPS Reef"),            /* 3 */
    QString("Cyhlids"),             /* 4 */
    QString("Discus aquarium"),     /* 5 */
    QString("Fresh aquarium"),      /* 6 */
    QString("Fresh scape")          /* 7 */
};

const static QMap<QString, QString> paramTranslationMap =
{
    {   "TEMP",     "Temperature"   },
    {   "SAL",      "Salinity"      },
    {   "CA",   "Calcium"           },
    {   "PH",   "pH"                },
    {   "KH",   "kH"                },
    {   "GH",   "gH"                },
    {   "PO4",  "Phosphates"        },
    {   "NO2",  "Nitrite"           },
    {   "NO3",  "Nitrate"           },
    {   "NH3",  "Ammonia"           },
    {   "MG",   "Magnesium"         },
    {   "SI",   "Silicates"         },
    {   "K",    "Potassium"         },
    {   "I",    "Iodine"            },
    {   "SR",   "Strontium"         },
    {   "FE",   "Ferrum"            },
    {   "B",    "Boron"             },
    {   "MO",   "Molybdenum"        },
    {   "ORP",  "ORP"               }
};

DBManager::DBManager(QQmlApplicationEngine *engine, QObject *parent) : QObject(parent)
{
    bool initRequired = false;

    if (QDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder).exists() == false)
    {
        QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder);
        initRequired = true;
    }

    dbFileLink = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder + "/" +dbFile;
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(dbFileLink);
    db.open();

    qDebug() << dbFileLink;

    //if (initRequired == true)
        initDB();

    qmlEngine = engine;

    actionList = new ActionList();

    aquariumTypeList.clear();

    for (int i = 0; i < AquariumType::EndOfList; i++)
    {
        TankTypeObj *obj = new TankTypeObj(i, getAquariumTypeString((AquariumType)i));
        aquariumTypeList.append(obj);
    }

    qmlEngine->rootContext()->setContextProperty("aquariumTypesListModel", QVariant::fromValue(aquariumTypeList));

    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onGuiUserCreate(QString, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int, QString)), this, SLOT(onGuiTankCreate(QString, int, int, int, int, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, double)), this, SLOT(onGuiAddRecord(int, int, double)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecordNotes(int, QString, QString)), this, SLOT(onGuiAddRecordNote(int, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddAction(QString, QString, int, int, int)), this, SLOT(onGuiAddActionRecord(QString, QString, int, int, int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigRefreshData()), this, SLOT(onGuiRefreshData()));

    curSelectedObjs.lastSmpId = getLastSmpId();
    setLastSmpId(curSelectedObjs.lastSmpId);

    getCurrentObjs();

#ifdef Q_OS_ANDROID
    for (int i = 0; i < permissions.size(); i++)
    {
        QtAndroid::PermissionResult r = QtAndroid::checkPermission(permissions.at(i));

        QtAndroid::requestPermissionsSync( QStringList() << permissions.at(i) );

        r = QtAndroid::checkPermission(permissions.at(i));

        qDebug() << "Permission " << permissions.at(i) << ((r == QtAndroid::PermissionResult::Denied) ? " DENIED" : " GRANTED ");
    }
#endif

    imageGallery = new ImageGallery();
    qmlEngine->rootContext()->setContextProperty("imageGalleryListModel", QVariant::fromValue(imageGallery->getGalleryObjList()));
}

DBManager::~DBManager()
{
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onUserCreate(QString, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, int, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, float)), this, SLOT(onGuiAddRecord(int, int, float)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecordNotes(int, QString, QString)), this, SLOT(onGuiAddRecordNote(int, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddAction(QString, QString, int, int, int)), this, SLOT(onGuiAddActionRecord(QString, QString, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigRefreshData()), this, SLOT(onGuiRefreshData()));

    if (curSelectedObjs.user != nullptr)
        delete curSelectedObjs.user;

    if (actionList != nullptr)
        delete actionList;
}

bool DBManager::getCurrentObjs()
{
    getCurrentUser();

    if (curSelectedObjs.user != nullptr)
    {
        getUserTanksList();

        if (curSelectedObjs.listOfUserTanks.size() > 0)
        {
            setInitialDialogStage(AppDef::AppInit_Completed, curSelectedObjs.user->uname);

            curSelectedObjs.tankIdx = 0;

            qmlEngine->rootContext()->setContextProperty("tanksListModel", QVariant::fromValue(curSelectedObjs.listOfUserTanks));

            getParamsList(currentTankSelected()->tankId(), (AquariumType) currentTankSelected()->type());

            getLatestParams();

            getHistoryParams();

            getActionCalendar();

            return true;
        }
        else
            setInitialDialogStage(AppDef::AppInit_UserExist, curSelectedObjs.user->uname);
    }
    else
        setInitialDialogStage(AppDef::AppInit_NoData, "User");

    return false;
}

TankObj *DBManager::currentTankSelected()
{
    TankObj *obj = nullptr;

    if (curSelectedObjs.listOfUserTanks.size() > curSelectedObjs.tankIdx)
        obj = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    return obj;
}

void DBManager::setInitialDialogStage(int stage, QString name)
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("page_AccountCreation");

    if (obj != nullptr)
    {
        obj->setProperty("stage", stage);
        obj->setProperty("currentUName", name);
    }
}

void DBManager::setLastSmpId(int id)
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first();

    if (obj != nullptr)
    {
        obj->setProperty("lastSmpId", id);
    }
}

void DBManager::clearDiagrams()
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tab_Graph");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "clearDiagrams");
}

void DBManager::addDiagram(int num, int paramId, int xMin, int xMax, float yMin, float yMax, QVariantMap points)
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

void DBManager::drawDiagrams()
{
    QObject *obj = nullptr;

    obj = qmlEngine->rootObjects().first()->findChild<QObject*>("tab_Graph");

    if (obj != nullptr)
        QMetaObject::invokeMethod(obj, "drawDiagrams");
}


void DBManager::onGuiUserCreate(QString uname, QString upass, QString email)
{
    if (createUser(uname, upass, "123", email) == true)
    {
        getCurrentUser();
        setInitialDialogStage(AppDef::AppInit_UserExist, curSelectedObjs.user->uname);
    }
}

void DBManager::onGuiTankCreate(QString name, int type, int l, int w, int h, QString imgFile)
{
    if (createTank(name, curSelectedObjs.user->man_id, type, l, w, h, imgFile) == true)
    {
        setInitialDialogStage(AppDef::AppInit_Completed, curSelectedObjs.user->uname);
    }
}

void DBManager::onGuiAddRecord(int smpId, int paramId, double value)
{
    addParamRecord(smpId, paramId, value);
}

void DBManager::onGuiRefreshData()
{
    curSelectedObjs.lastSmpId = getLastSmpId();
    setLastSmpId(curSelectedObjs.lastSmpId);

    getLatestParams();
    getHistoryParams();
}

void DBManager::onGuiAddRecordNote(int smpId, QString note, QString imageLink)
{
    if (addNoteRecord(smpId, note, imageLink) == true)
    {
        getLatestParams();
        getHistoryParams();
    }
}

void DBManager::onGuiAddActionRecord(QString name, QString desc, int type, int period, int tm)
{
    if (addActionRecord(currentTankSelected()->tankId(), name, desc, type, period, tm) == true)
    {

    }
}

void DBManager::onGuiTankSelected(int tankIdx)
{
    curSelectedObjs.tankIdx = tankIdx;

    getLatestParams();
    getHistoryParams();
}

void DBManager::onGuiPersonalParamStateChanged(int paramId, bool en)
{
    editPersonalParamState(currentTankSelected()->tankId(), paramId, en);
}

bool DBManager::getActionCalendar()
{
    bool res = false;
    QSqlQuery query("SELECT * FROM ACTIONS_TABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"' ORDER BY STARTDATE DESC");

    qDebug() << "calendar " << query.lastError();

    if (actionList->setData(&query, ActionView_ThisWeek) != true)
        qDebug() << "actionList->setData error";

    qmlEngine->rootContext()->setContextProperty("actionsListModel", QVariant::fromValue(*actionList->getData()));

    return res;
}

bool DBManager::getParamsList(QString tankId, AquariumType type)
{
    bool res = false;
    QSqlQuery query("SELECT * FROM DICT_TABLE");
    QSqlQuery queryPersonal("SELECT * FROM PERSONAL_PARAM_TABLE WHERE TANK_ID = '"+tankId+"'");
    ParamObj *obj = nullptr;

    mapPersonal.clear();

    while (queryPersonal.next())
    {
        mapPersonal.insert(queryPersonal.value(queryPersonal.record().indexOf("PARAM_ID")).toInt(),
                           queryPersonal.value(queryPersonal.record().indexOf("ENABLED")).toBool());
    }

    paramsGuiList.clear();

    while (query.next())
    {
        obj = new ParamObj(&query, type);
        obj->setEn(mapPersonal[obj->paramId()]);

        paramsGuiList.append(obj);

        res = true;
    }

    for (int i = 0; i < paramsGuiList.size(); i++)
    {
        obj = (ParamObj*) paramsGuiList.at(i);

        obj->setFullName(paramTranslationMap[obj->shortName()]);
    }

    qmlEngine->rootContext()->setContextProperty("allParamsListModel", QVariant::fromValue(paramsGuiList));

    return res;
}

bool DBManager::getLatestParams()
{
    bool found = false;
    LastDataParamRecObj *recObj = nullptr;
    QList<int> smpIdList;
    QSqlQuery query0("SELECT SMP_ID FROM HISTORY_VALUE_TABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"' ORDER BY SMP_ID DESC");

    smpIdList.clear();

    while (query0.next())
    {
        found = false;

        for (int i = 0; i < smpIdList.size(); i++)
        {
            if (query0.value(0).toInt() == smpIdList.at(i))
            {
                found = true;
                break;
            }
        }

        if (found == false)
        {
            smpIdList.append(query0.value(0).toInt());

            if (smpIdList.size() > 1)
                break;
        }
    }

    curSelectedObjs.listOfCurrValues.clear();

    if (smpIdList.size() > 0)
    {
        QSqlQuery query("SELECT v.SMP_ID, v.TANK_ID, v.PARAM_ID, v.VALUE, v.TIMESTAMP, n.TEXT, n.IMAGELINK "
                        "FROM HISTORY_VALUE_TABLE v "
                        "LEFT JOIN HISTORY_NOTES_TABLE n ON n.SMP_ID = v.SMP_ID "
                        "WHERE v.SMP_ID = '"+QString::number(smpIdList.at(0))+"'");

        while (query.next())
        {
            recObj = new LastDataParamRecObj(query.value(query.record().indexOf("PARAM_ID")).toInt(),
                                             query.value(query.record().indexOf("SMP_ID")).toInt(),
                                             -1,
                                             query.value(query.record().indexOf("VALUE")).toFloat(),
                                             -1,
                                             (unsigned int)query.value(query.record().indexOf("TIMESTAMP")).toInt(),
                                             0,
                                             query.value(query.record().indexOf("TEXT")).toString(),
                                             query.value(query.record().indexOf("IMAGELINK")).toString());

            if (mapPersonal.size() > 0)
                recObj->setEn(mapPersonal[recObj->paramId()]);

            curSelectedObjs.listOfCurrValues.append(recObj);
        }

        if (smpIdList.size() > 1)
        {
            QSqlQuery query1("SELECT v.SMP_ID, v.TANK_ID, v.PARAM_ID, v.VALUE, v.TIMESTAMP, n.TEXT, n.IMAGELINK "
                             "FROM HISTORY_VALUE_TABLE v "
                             "LEFT JOIN HISTORY_NOTES_TABLE n ON n.SMP_ID = v.SMP_ID "
                             "WHERE v.SMP_ID = '"+QString::number(smpIdList.at(1))+"'");


            while (query1.next())
            {
                found = false;

                for (int i = 0; i < curSelectedObjs.listOfCurrValues.size(); i++)
                {
                    recObj = (LastDataParamRecObj*) curSelectedObjs.listOfCurrValues.at(i);

                    if (mapPersonal.size() > 0)
                        recObj->setEn(mapPersonal[recObj->paramId()]);

                    if (query1.value(query1.record().indexOf("PARAM_ID")).toInt() == recObj->paramId())
                    {
                        recObj->setValuePrev(query1.value(query1.record().indexOf("VALUE")).toFloat());
                        recObj->setSmpIdPrev(query1.value(query1.record().indexOf("SMP_ID")).toInt());
                        recObj->setDtPrev((unsigned int)query1.value(query1.record().indexOf("TIMESTAMP")).toInt());

                        found = true;
                    }
                }

                if (found == false)
                {
                    recObj = new LastDataParamRecObj(query1.value(query1.record().indexOf("PARAM_ID")).toInt(),
                                                     -1,
                                                     query1.value(query1.record().indexOf("SMP_ID")).toInt(),
                                                     -1,
                                                     query1.value(query1.record().indexOf("VALUE")).toFloat(),
                                                     0,
                                                     (unsigned int)query.value(query.record().indexOf("TIMESTAMP")).toInt(),
                                                     query.value(query.record().indexOf("TEXT")).toString(),
                                                     query.value(query.record().indexOf("IMAGELINK")).toString());

                    if (mapPersonal.size() > 0)
                        recObj->setEn(mapPersonal[recObj->paramId()]);

                    curSelectedObjs.listOfCurrValues.append(recObj);
                }
            }
        }
    }

    qmlEngine->rootContext()->setContextProperty("curValuesListModel", QVariant::fromValue(curSelectedObjs.listOfCurrValues));

    return false;
}

bool DBManager::getHistoryParams()
{
    QList<int> idList;
    QVariantMap points;
    QList<QVariantMap> curveList;
    bool found = false;
    int xMin = INT_MAX, xMax = INT_MIN;
    float yMin = __FLT_MAX__, yMax = __FLT_MIN__;

    idList.clear();
    curveList.clear();

    QSqlQuery qId("SELECT PARAM_ID FROM HISTORY_VALUE_TABLE "
                  "WHERE TANK_ID = '"+currentTankSelected()->tankId()+"'");

    while (qId.next())
    {
        found = false;

        for (int i = 0; i < idList.size(); i++)
        {
            if (idList.at(i) == qId.value(0).toInt())
                found = true;
        }

        if (found == false)
            idList.append(qId.value(0).toInt());
    }

    pointList.clear();

    for (int i = 0; i < idList.size(); i++)
    {
        QSqlQuery qParams("SELECT VALUE, TIMESTAMP FROM HISTORY_VALUE_TABLE "
                          "WHERE PARAM_ID = '"+QString::number(idList.at(i))+"'");

        points.clear();

        while (qParams.next())
        {
            if (i == 0)
            {
                PointObj *pt = new PointObj(qParams.value(1).toInt(), qParams.value(0).toFloat());
                pointList.append(pt);
            }

            points.insert(QString::number(qParams.value(1).toInt()), qParams.value(0).toFloat());
        }

        curveList.append(points);
    }

    qmlEngine->rootContext()->setContextProperty("graphPointsList", QVariant::fromValue(pointList));

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

        /*
        for(int n = 0; n < paramsGuiList.size(); n++)
        {
            ParamObj *obj = (ParamObj*) paramsGuiList.at(n);

            if (idList.at(i) == obj->paramId())
            {
                yMin = obj->min() - (obj->max() - obj->min());

                if (yMin < 0)
                    yMin = 0;

                yMax = obj->max() + (obj->max() - obj->min());
            }
        }
        */

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

    drawDiagrams();

    return false;
}

int DBManager::getLastSmpId()
{
    int id = 0;

    QSqlQuery query("SELECT MAX(ID) FROM HISTORY_VALUE_TABLE");

    if(query.next())
        id = query.value(0).toInt();

    return id;
}

bool DBManager::getCurrentUser()
{
    QSqlQuery query("SELECT * FROM USER_TABLE");

    while (query.next())
    {
        /* Read only one User */
        curSelectedObjs.user = new UserObj(&query);
        return true;
    }

    return false;
}

bool DBManager::getUserTanksList()
{
    bool res = false;
    TankObj *obj = nullptr;
    QSqlQuery query("SELECT * FROM TANKS_TABLE WHERE MAN_ID='"+curSelectedObjs.user->man_id+"'");

    curSelectedObjs.listOfUserTanks.clear();

    while (query.next())
    {
        res = true;
        obj = new TankObj(&query);
        obj->setTypeName(aquariumTypeNames[obj->type()]);
        curSelectedObjs.listOfUserTanks.append(obj);
    }

    return res;
}

bool DBManager::createUser(QString uname, QString upass, QString phone, QString email)
{
    if (uname.length() > 0 && uname.length() <= 64 &&
        upass.length() > 0 && upass.length() <= 128 &&
        phone.length() > 0 && phone.length() <= 16 &&
        email.length() > 0 && email.length() <= 64)
    {
        QSqlQuery query;
        bool res = false;

        query.prepare("INSERT INTO USER_TABLE (MAN_ID, UNAME, UPASS, SELECTED, STATUS, PHONE, EMAIL, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:man_id, :uname, :upass, :selected, :status, :phone, :email, :date_create, :date_edit)");

        query.bindValue(":man_id", randId());
        query.bindValue(":uname", uname);
        query.bindValue(":upass", upass);
        query.bindValue(":selected", true);
        query.bindValue(":status", UStatus_Enabled);
        query.bindValue(":phone", phone);
        query.bindValue(":email", email);
        query.bindValue(":date_create", QDateTime::currentSecsSinceEpoch());
        query.bindValue(":date_edit", QDateTime::currentSecsSinceEpoch());

        res = query.exec();

        if (res == false)
            qDebug() << "Create user error: " << query.lastError();

        return res;
    }
    else
        return false;
}

bool DBManager::createTank(QString name, QString manId, int type, int l, int w, int h, QString imgFile)
{
    bool res = false;
    QFile *file = nullptr;
    QString img = "";

    if (name.length() > 0 && name.length() <= 64)
    {
        QSqlQuery query;
        QString tankId = randId();

        if (imgFile != "")
        {
            qDebug() << "IMG: " << imgFile;

            file = new QFile(imgFile.replace("file:///", ""));

            if (file->exists() == true && file->open(QFile::OpenModeFlag::ReadOnly) == true)
            {
                qDebug() << "Found ";

                QByteArray bin = file->readAll();
                file->close();

                qDebug() << "Size = " << bin.size();

                img = QString(bin.toBase64());
            }

            delete file;
        }

        query.prepare("INSERT INTO TANKS_TABLE (TANK_ID, MAN_ID, TYPE, IMG, NAME, STATUS, L, W, H, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:tank_id, :man_id, :type, :img, :name, :status, :l, :w, :h, :date_create, :date_edit)");

        query.bindValue(":tank_id", tankId);
        query.bindValue(":man_id", manId);
        query.bindValue(":type", type);
        query.bindValue(":name", name);
        query.bindValue(":img", img);
        query.bindValue(":status", UStatus_Enabled);
        query.bindValue(":l", l);
        query.bindValue(":w", w);
        query.bindValue(":h", h);
        query.bindValue(":date_create", QDateTime::currentSecsSinceEpoch());
        query.bindValue(":date_edit", QDateTime::currentSecsSinceEpoch());

        res = query.exec();

        if (res == false)
            qDebug() << "Create tank error: " << query.lastError();
        else
        {
            res = createTankDefaultParamSet(tankId, (AquariumType) type);
        }
    }

    if (res == true)
        getCurrentObjs();

    return res;
}

bool DBManager::createTankDefaultParamSet(QString tankId, AquariumType type)
{
    if (tankId.length() == RAND_ID_LENGTH)
    {
        QSqlQuery query;
        QSqlQuery q0("SELECT * FROM DICT_TABLE");
        ParamObj *obj = nullptr;
        bool res = false;

        paramsGuiList.clear();

        while (q0.next())
        {
            obj = new ParamObj(&q0, type);
            paramsGuiList.append(obj);

            qDebug() << obj->paramId() << obj->fullName() << obj->min() << obj->max();
        }

        for (int i = 0; i < paramsGuiList.size(); i++)
        {
            obj = (ParamObj*) paramsGuiList.at(i);

            query.prepare("INSERT INTO PERSONAL_PARAM_TABLE (PARAM_ID, TANK_ID, ENABLED) "
                          "VALUES (:param_id, :tank_id, :enabled)");

            query.bindValue(":param_id", obj->paramId());
            query.bindValue(":tank_id", tankId);
            query.bindValue(":enabled", 1);

            if (query.exec() != true)
            {
                qDebug() << query.lastError();
                return false;
            }
        }
    }

    return true;
}

bool DBManager::addParamRecord(int smpId, int paramId, double value)
{
    QSqlQuery query;
    bool res = false;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    query.prepare("INSERT INTO HISTORY_VALUE_TABLE (SMP_ID, TANK_ID, PARAM_ID, VALUE, TIMESTAMP) "
                  "VALUES (:smp_id, :tank_id, :param_id, :value, :tm)");

    query.bindValue(":smp_id", smpId);
    query.bindValue(":tank_id", tank->tankId());
    query.bindValue(":param_id", paramId);
    query.bindValue(":value", value);
    query.bindValue(":tm", QDateTime::currentSecsSinceEpoch());

    res = query.exec();

    if (res == false)
        qDebug() << "Add record error: " << query.lastError();

    return res;
}

bool DBManager::addNoteRecord(int smpId, QString note, QString imageLink)
{
    QSqlQuery query;
    bool res = false;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    query.prepare("INSERT INTO HISTORY_NOTES_TABLE (SMP_ID, TANK_ID, TEXT, IMAGEDATA, IMAGELINK, TIMESTAMP) "
                  "VALUES (:smp_id, :tank_id, :text, :imagedata, :imagelink, :tm)");

    query.bindValue(":smp_id", smpId);
    query.bindValue(":tank_id", tank->tankId());
    query.bindValue(":text", note);
    query.bindValue(":imagedata", "");
    query.bindValue(":imagelink", imageLink);
    query.bindValue(":tm", QDateTime::currentSecsSinceEpoch());

    res = query.exec();

    if (res == false)
        qDebug() << "Add Note record error: " << query.lastError();

    return res;
}

bool DBManager::addActionRecord(QString tankId, QString name, QString desc, int type, int period, int tm)
{
    QSqlQuery query;
    bool res = false;

    query.prepare("INSERT INTO ACTIONS_TABLE (TANK_ID, TYPE, NAME, DESC, PERIOD, EN, STARTDATE) "
                  "VALUES (:tank_id, :type, :name, :desc, :period, :en, :tm)");

    query.bindValue(":tank_id", tankId);
    query.bindValue(":type", type);
    query.bindValue(":name", name);
    query.bindValue(":desc", desc);
    query.bindValue(":period", period);
    query.bindValue(":en", 1);
    query.bindValue(":tm", tm);

    res = query.exec();

    if (res == false)
        qDebug() << "Add Action record error: " << query.lastError();

    return res;
}

bool DBManager::editPersonalParamState(QString tankId, int paramId, bool en)
{
    QSqlQuery query;
    bool res = false;

    res = query.exec("UPDATE PERSONAL_PARAM_TABLE SET ENABLED = '"+QString::number(en)+"' WHERE "
                     "TANK_ID = '" +tankId+ "' AND PARAM_ID = '" +QString::number(paramId)+"'");

    if (res == false)
    {
        qDebug() << "Update personal param: " << query.lastQuery();
        qDebug() << "Update personal param: " << query.lastError();
    }

    return res;
}

QString DBManager::randId()
{
    const QString possibleCharacters("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");
    const int randomStringLength = RAND_ID_LENGTH; // assuming you want random strings of 12 characters
    QString randomString;

    for(int i = 0; i < randomStringLength; ++i)
    {
        int index = qrand() % possibleCharacters.length();
        QChar nextChar = possibleCharacters.at(index);
        randomString.append(nextChar);
    }

    return randomString;
}

bool DBManager::initDB()
{
    QSqlQuery query;

    query.exec("CREATE TABLE IF NOT EXISTS USER_TABLE"
                "(MAN_ID varchar(16), "
                "UNAME varchar(64), "
                "UPASS varchar(128), "
                "SELECTED integer, "
                "STATUS integer, "
                "PHONE varchar(16), "
                "EMAIL varchar(64), "
                "AVATAR_IMG blob, "
                "DATE_CREATE integer, "
                "DATE_EDIT integer )");

    qDebug() << query.lastError();

    query.exec("CREATE TABLE IF NOT EXISTS TANKS_TABLE "
                "(TANK_ID varchar(16), "
                "MAN_ID varchar(16), "
                "TYPE integer, "
                "NAME varchar(64), "
                "DESC text, "
                "IMG blob, "
                "STATUS integer, "
                "L integer, "
                "W integer, "
                "H integer, "
                "DATE_CREATE integer, "
                "DATE_EDIT integer )");

    qDebug() << query.lastError();

    query.exec("CREATE TABLE IF NOT EXISTS HISTORY_VALUE_TABLE "
                "(ID integer PRIMARY KEY AUTOINCREMENT, "
                "SMP_ID integer, "
                "TANK_ID varchar(16), "
                "PARAM_ID integer, "
                "VALUE float, "
                "TIMESTAMP integer)");

    qDebug() << query.lastError();

    query.exec("CREATE TABLE IF NOT EXISTS HISTORY_NOTES_TABLE "
                "(SMP_ID integer, "
                "TANK_ID varchar(16), "
                "TEXT text, "
                "IMAGEDATA blob, "
                "IMAGELINK varchar(64),"
                "TIMESTAMP integer)");

    qDebug() << query.lastError();

    /* Limits count must match DbManager::AquariumType */
    query.exec("CREATE TABLE IF NOT EXISTS DICT_TABLE "
                "(PARAM_ID integer, "
                "SHORT_NAME varchar(8), "
                "FULL_NAME varchar(32), "
                "UNIT_NAME varchar(8), "
                "MIN_1 float,"
                "MAX_1 float,"
                "MIN_2 float,"
                "MAX_2 float,"
                "MIN_3 float,"
                "MAX_3 float,"
                "MIN_4 float,"
                "MAX_4 float,"
                "MIN_5 float,"
                "MAX_5 float,"
                "MIN_6 float,"
                "MAX_6 float,"
                "MIN_7 float,"
                "MAX_7 float,"
                "MIN_8 float,"
                "MAX_8 float)");

    qDebug() << query.lastError();

    query.exec("SELECT COUNT(*) FROM DICT_TABLE");

    query.first();

    if (query.value(0).toInt() == 0)
    {
        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (1, 'TEMP', 'Temperature', '°C', 22.2, 25.6, 24.4, 28.3, 24.4, 28.3, 24.4, 28.3, 22.2, 27.8, 24.4, 30, 24.4, 30.0, 24.4, 30.0)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (2, 'SAL', 'Salinity', 'ppt', 26.6, 33.2, 30.6, 35, 33.0, 35.0, 34.0, 35.0, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (3, 'CA', 'Calcium', 'ppm', 350, 450, 380, 450, 380, 450, 380, 450, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (4, 'PH', 'pH', 'ppm', 8.1, 8.4, 8.1, 8.4, 8.1, 8.4, 8.1, 8.4, 7.5, 8.5, 6.0, 7.5, 6.5, 7.5, 6.5, 7.5)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (5, 'KH', 'kH', 'ppm', 8.0, 12.0, 8.0, 12.0, 8.0, 12.0, 8.0, 12.0, 10, 18, 3, 8, 4, 8, 4, 8)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (6, 'GH', 'gH', 'dKh', -1, -1, -1, -1, -1, -1, -1, -1, 12, 20, 3, 8, 4, 12, 4, 12)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (7, 'PO4', 'Phosphates', 'ppm', 0, 0.2, 0, 0.2, 0, 0.05, 0, 0.05, 0, 1, 0, 1, 0, 1, 0, 1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (8, 'NO2', 'Nitrite', 'ppb', 0, 100, 0, 100, 0, 100, 0, 100, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (9, 'NO3', 'Nitrate', 'ppm', 0, 30, 0, 10, 0, 1, 0, 1, 0, 50, 0, 30, 0, 50, 0, 50)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (10, 'NH3', 'Ammonia', 'ppm', 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (11, 'CO2', 'Carbon', 'ppm, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 4, 30, 4, 30')");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (12, 'MG', 'Magnesium', 'ppm', 1150, 1350, 1250, 1350, 1250, 1350, 1250, 1350, 10, -1, 10, -1, 10, -1, 10, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (13, 'SI', 'Silicates', 'ppm', 0, 3, 0.06, 2, 0.06, 2, 0.06, 2, 0, 2, 0, 2, 0, 2, 0, 2)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (14, 'K', 'Potassium', 'ppm', 380, 400, 380, 400, 380, 400, 380, 400, 5, 10, 5, 1, 5, 20, 5, 20)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (15, 'I', 'Iodine', 'ppm', 0.04, 0.1, 0.06, 0.1, 0.06, 0.1, 0.06, 0.1, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (16, 'SR', 'Strontium', 'ppm', 4, 10, 8, 14, 8, 14, 8, 14, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (17, 'FE', 'Ferrum', 'ppm', 0.1, 0.3, 0.1, 0.3, 0.1, 0.3, 0.1, 0.3, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (18, 'B', 'Boron', 'ppm', 0, 10, 0, 10, 0, 10, 0, 10, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (19, 'MO', 'Molybdenum', 'ppm', 0.03, 0.12, 0.03, 0.12, 0.03, 0.12, 0.03, 0.12, -1, -1, -1, -1, -1, -1, -1, -1)");

        query.exec("INSERT OR IGNORE INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (20, 'ORP', 'ORP', 'mV', 250, 400, 250, 400, 250, 200, 250, 400, -1, -1, -1, -1, -1, -1, -1, -1)");
    }

    qDebug() << query.lastError();

    query.exec("CREATE TABLE IF NOT EXISTS PERSONAL_PARAM_TABLE "
                "(PARAM_ID integer, "
                "TANK_ID varchar(16), "
                "ENABLED integer)");

    qDebug() << query.lastError();


    query.exec("CREATE TABLE IF NOT EXISTS ACTIONS_TABLE "
               "(ID integer PRIMARY KEY AUTOINCREMENT,"
               "TANK_ID varchar(16),"
               "TYPE integer,"
               "NAME text,"
               "DESC text,"
               "PERIOD integer,"
               "EN integer,"
               "STARTDATE integer)");

    qDebug() << query.lastError();

    return true;
}

QString DBManager::getAquariumTypeString(AquariumType type)
{
    if (type < EndOfList)
        return aquariumTypeNames[type];
    else
        return QString("");
}
