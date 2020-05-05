#include "dbmanager.h"
#include <QtSql>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QStandardPaths>
#include <QQmlContext>
#include <QDateTime>
#include <QDebug>
#include <QList>
#include "AppDefs.h"
#include "dbobjects.h"

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

    if (initRequired == true)
        initDB();

    qmlEngine = engine;

    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onGuiUserCreate(QString, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, int, int, int, int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, double)), this, SLOT(onGuiAddRecord(int, int, double)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));

    curSelectedObjs.lastSmpId = getLastSmpId();
    setLastSmpId(curSelectedObjs.lastSmpId);

    getCurrentObjs();
}

DBManager::~DBManager()
{
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onUserCreate(QString, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, int, int, int, int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigAddRecord(int, int, float)), this, SLOT(onGuiAddRecord(int, int, float)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigTankSelected(int)), this, SLOT(onGuiTankSelected(int)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigPersonalParamStateChanged(int, bool)), this, SLOT(onGuiPersonalParamStateChanged(int, bool)));

    if (curSelectedObjs.user != nullptr)
        delete curSelectedObjs.user;
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

            getParamsList(currentTankSelected()->tankId());

            getLatestParams();

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

void DBManager::onGuiUserCreate(QString uname, QString upass, QString email)
{
    if (createUser(uname, upass, "123", email) == true)
    {
        getCurrentUser();
        setInitialDialogStage(AppDef::AppInit_UserExist, curSelectedObjs.user->uname);
    }
}

void DBManager::onGuiTankCreate(QString name, int type, int l, int w, int h)
{
    if (createTank(name, curSelectedObjs.user->man_id, type, l, w, h) == true)
    {
        setInitialDialogStage(AppDef::AppInit_Completed, curSelectedObjs.user->uname);
    }
}

void DBManager::onGuiAddRecord(int smpId, int paramId, double value)
{
    if (addParamRecord(smpId, paramId, value) == true)
    {
        getLatestParams();
    }
}

void DBManager::onGuiTankSelected(int tankIdx)
{
    curSelectedObjs.tankIdx = tankIdx;

    getLatestParams();
}

void DBManager::onGuiPersonalParamStateChanged(int paramId, bool en)
{
    editPersonalParamState(currentTankSelected()->tankId(), paramId, en);
}

bool DBManager::getParamsList()
{
    bool res = false;
    QSqlQuery query("SELECT * FROM DICTTABLE");
    ParamObj *obj = nullptr;
    int i = 0;

    paramsGuiList.clear();

    while (query.next())
    {
        if (i > 0)
        {
            obj = new ParamObj(&query);
            paramsGuiList.append(obj);
            res = true;
        }

        i++;
    }

    return res;
}

bool DBManager::getParamsList(QString tankId)
{
    bool res = false;
    QSqlQuery query("SELECT * FROM DICTTABLE");
    QSqlQuery queryPersonal("SELECT * FROM PERSONALPARAMTABLE WHERE TANK_ID = '"+tankId+"'");
    ParamObj *obj = nullptr;
    QMap<int, bool> mapPersonal;
    int i = 0;

    mapPersonal.clear();

    while (queryPersonal.next())
    {
        mapPersonal.insert(queryPersonal.value(queryPersonal.record().indexOf("PARAM_ID")).toInt(),
                           queryPersonal.value(queryPersonal.record().indexOf("ENABLED")).toBool());
    }

    paramsGuiList.clear();

    while (query.next())
    {
        if (i > 0)
        {
            obj = new ParamObj(&query);
            obj->setEn(mapPersonal[obj->paramId()]);

            paramsGuiList.append(obj);

            res = true;
        }

        i++;
    }

    qmlEngine->rootContext()->setContextProperty("allParamsListModel", QVariant::fromValue(paramsGuiList));

    return res;
}

bool DBManager::getLatestParams()
{
    bool found = false;
    LastDataParamRecObj *recObj = nullptr;
    QList<int> smpIdList;
    QSqlQuery query0("SELECT SMP_ID FROM LOGTABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"' ORDER BY SMP_ID DESC");

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
        QSqlQuery query("SELECT * FROM LOGTABLE "
                        "WHERE SMP_ID = '"+QString::number(smpIdList.at(0))+"'");

        while (query.next())
        {
            recObj = new LastDataParamRecObj(query.value(query.record().indexOf("PARAM_ID")).toInt(),
                                             query.value(query.record().indexOf("SMP_ID")).toInt(),
                                             -1,
                                             query.value(query.record().indexOf("VALUE")).toFloat(),
                                             -1);

            curSelectedObjs.listOfCurrValues.append(recObj);
        }

        if (smpIdList.size() > 1)
        {
            QSqlQuery query1("SELECT * FROM LOGTABLE "
                                    "WHERE SMP_ID='"+QString::number(smpIdList.at(1))+"'");

            while (query1.next())
            {
                found = false;

                for (int i = 0; i < curSelectedObjs.listOfCurrValues.size(); i++)
                {
                    recObj = (LastDataParamRecObj*) curSelectedObjs.listOfCurrValues.at(i);

                    if (query1.value(query1.record().indexOf("PARAM_ID")).toInt() == recObj->paramId())
                    {
                        recObj->setValuePrev(query1.value(query1.record().indexOf("VALUE")).toFloat());
                        recObj->setSmpIdPrev(query1.value(query1.record().indexOf("SMP_ID")).toInt());

                        found = true;
                    }
                }

                if (found == false)
                {
                    recObj = new LastDataParamRecObj(query1.value(query1.record().indexOf("PARAM_ID")).toInt(),
                                                     -1,
                                                     query1.value(query1.record().indexOf("SMP_ID")).toInt(),
                                                     -1,
                                                     query1.value(query1.record().indexOf("VALUE")).toFloat());

                    curSelectedObjs.listOfCurrValues.append(recObj);
                }
            }
        }
    }

    qmlEngine->rootContext()->setContextProperty("curValuesListModel", QVariant::fromValue(curSelectedObjs.listOfCurrValues));

    return false;
}

int DBManager::getLastSmpId()
{
    int id = 0;

    QSqlQuery query("SELECT MAX(ID) FROM LOGTABLE");

    if(query.next())
        id = query.value(0).toInt();

    return id;
}

bool DBManager::getCurrentUser()
{
    QSqlQuery query("SELECT * FROM UTABLE");

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
    QSqlQuery query("SELECT * FROM TANKSTABLE WHERE MAN_ID='"+curSelectedObjs.user->man_id+"'");

    curSelectedObjs.listOfUserTanks.clear();

    while (query.next())
    {
        res = true;
        obj = new TankObj(&query);
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

        query.prepare("INSERT INTO UTABLE (MAN_ID, UNAME, UPASS, SELECTED, STATUS, PHONE, EMAIL, DATE_CREATE, DATE_EDIT) "
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

bool DBManager::createTank(QString name, QString manId, int type, int l, int w, int h)
{
    bool res = false;

    if (name.length() > 0 && name.length() <= 64)
    {
        QSqlQuery query;
        QString tankId = randId();

        query.prepare("INSERT INTO TANKSTABLE (TANK_ID, MAN_ID, TYPE, NAME, STATUS, L, W, H, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:tank_id, :man_id, :type, :name, :status, :l, :w, :h, :date_create, :date_edit)");

        query.bindValue(":tank_id", tankId);
        query.bindValue(":man_id", manId);
        query.bindValue(":type", type);
        query.bindValue(":name", name);
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
            res = createTankDefaultParamSet(tankId);
        }
    }

    if (res == true)
        getCurrentObjs();

    return res;
}

bool DBManager::createTankDefaultParamSet(QString tankId)
{
    if (tankId.length() == RAND_ID_LENGTH)
    {
        QSqlQuery query;
        ParamObj *obj = nullptr;

        for (int i = 0; i < paramsGuiList.size(); i++)
        {
            obj = (ParamObj*) paramsGuiList.at(i);

            query.prepare("INSERT INTO PERSONALPARAMTABLE (PARAM_ID, TANK_ID, ENABLED) "
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

    query.prepare("INSERT INTO LOGTABLE (SMP_ID, TANK_ID, PARAM_ID, VALUE, TIMESTAMP) "
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

bool DBManager::editPersonalParamState(QString tankId, int paramId, bool en)
{
    QSqlQuery query;
    bool res = false;

    res = query.exec("UPDATE PERSONALPARAMTABLE SET ENABLED = '"+QString::number(en)+"' WHERE "
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

    query.exec("create table UTABLE "
                "(MAN_ID varchar(16), "
                "UNAME varchar(64), "
                "UPASS varchar(128), "
                "SELECTED integer, "
                "STATUS integer, "
                "PHONE varchar(16), "
                "EMAIL varchar(64), "
                "AVATAR_IMG text, "
                "DATE_CREATE integer, "
                "DATE_EDIT integer )");

    qDebug() << query.lastError();

    query.exec("create table TANKSTABLE "
                "(TANK_ID varchar(16), "
                "MAN_ID varchar(16), "
                "TYPE integer, "
                "NAME varchar(64), "
                "DESC text, "
                "IMG text, "
                "STATUS integer, "
                "L integer, "
                "W integer, "
                "H integer, "
                "DATE_CREATE integer, "
                "DATE_EDIT integer )");

    qDebug() << query.lastError();

    query.exec("create table LOGTABLE "
                "(ID integer PRIMARY KEY AUTOINCREMENT, "
                "SMP_ID integer, "
                "TANK_ID varchar(16), "
                "PARAM_ID integer, "
                "VALUE float, "
                "TIMESTAMP integer)");

    qDebug() << query.lastError();

    query.exec("create table DICTTABLE "
                "(PARAM_ID integer, "
                "SHORT_NAME varchar(8), "
                "FULL_NAME varchar(32), "
                "UNIT_NAME varchar(8))");

    qDebug() << query.lastError();

    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (0, '-', '-', '-')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (1, 'Temp.', 'Temperature', '°C')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (2, 'Sal.', 'Salinity', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (3, 'Ca', 'Calcium', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (4, 'pH', 'pH', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (5, 'kH', 'kH', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (6, 'gH', 'gH', 'dKh')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (7, 'Po4', 'Phosphates', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (8, 'No2', 'Nitrite', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (9, 'No3', 'Nitrate', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (10, 'Nh3', 'Ammonia', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (11, 'Co2', 'Carbon', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (12, 'O2', 'Oxigen', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (13, 'Mg', 'Magnesium', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (14, 'Si', 'Silicates', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (15, 'K', 'Potassium', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (16, 'I', 'Iodine', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (17, 'Sr', 'Strontium', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (18, 'Fe', 'Ferrum', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (19, 'Cu', 'Cuprum', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (20, 'B', 'Boron', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (21, 'Mo', 'Molybdenum', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (22, 'Cl', 'Clorine', 'ppm')");
    query.exec("INSERT INTO DICTTABLE (PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME) "
               "VALUES (23, 'Orp', 'ORP', 'ppm')");

    qDebug() << query.lastError();

    query.exec("create table PERSONALPARAMTABLE "
                "(PARAM_ID integer, "
                "TANK_ID varchar(16), "
                "ENABLED integer)");

    qDebug() << query.lastError();


    return true;
}
