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


    if (initRequired == true)
        initDB();

    qmlEngine = engine;

    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onGuiUserCreate(QString, QString, QString)));
    connect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, int, int, int, int)));

    curUser = getCurrentUser();

    if (curUser != nullptr)
    {
        getUserTanksList(curUser->man_id);

        if (listOfUserTanks.size() > 0)
        {
            setInitialDialogStage(AppDef::AppInit_Completed, curUser->uname);

            qmlEngine->rootContext()->setContextProperty("tanksListModel", QVariant::fromValue(listOfUserTanks));
        }
        else
            setInitialDialogStage(AppDef::AppInit_UserExist, curUser->uname);
    }
    else
        setInitialDialogStage(AppDef::AppInit_NoData, "User");
}

DBManager::~DBManager()
{
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateAccount(QString, QString, QString)), this, SLOT(onUserCreate(QString, QString, QString)));
    disconnect(qmlEngine->rootObjects().first(), SIGNAL(sigCreateTank(QString, int, int, int, int)), this, SLOT(onGuiTankCreate(QString, int, int, int, int)));

    if (curUser != nullptr)
        delete curUser;
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


void DBManager::onGuiUserCreate(QString uname, QString upass, QString email)
{
    qDebug() << "onGuiUserCreate";

    if (createUser(uname, upass, "123", email) == true)
    {
        curUser = getCurrentUser();
        setInitialDialogStage(AppDef::AppInit_UserExist, curUser->uname);
    }
}

void DBManager::onGuiTankCreate(QString name, int type, int l, int w, int h)
{
    qDebug() << "onGuiTankCreate";

    if (createTank(name, curUser->man_id, type, l, w, h) == true)
    {
        setInitialDialogStage(AppDef::AppInit_Completed, curUser->uname);
    }
}

UserObj *DBManager::getCurrentUser()
{
    bool res = false;
    QSqlQuery query("SELECT * FROM UTABLE");
    UserObj *user = nullptr;

    while (query.next())
    {
        /* Read only one User */
        user = new UserObj(&query);
        break;
    }

    return user;
}

QList<QObject *> *DBManager::getUserTanksList(QString manId)
{
    TankObj *obj = nullptr;
    QSqlQuery query("SELECT * FROM TANKSTABLE WHERE MAN_ID='"+manId+"'");

    listOfUserTanks.clear();

    while (query.next())
    {
        obj = new TankObj(&query);
        listOfUserTanks.append(obj);

        qDebug() << obj->name() << obj->desc() << obj->volume();
    }

    return &listOfUserTanks;
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
    if (name.length() > 0 && name.length() <= 64)
    {
        QSqlQuery query;
        bool res = false;

        query.prepare("INSERT INTO TANKSTABLE (TANK_ID, MAN_ID, TYPE, NAME, STATUS, L, W, H, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:tank_id, :man_id, :type, :name, :status, :l, :w, :h, :date_create, :date_edit)");

        query.bindValue(":tank_id", randId());
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

        return res;
    }
    else
        return false;
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
                "(MAN_ID varchar(32), "
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
                "(TANK_ID varchar(32), "
                "MAN_ID varchar(32), "
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
                "(ID integer PRIMARY KEY NOT NULL, "
                "SMP_ID integer, "
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

    return true;
}
