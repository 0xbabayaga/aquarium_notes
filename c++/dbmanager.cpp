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
#include <QImage>
#include <QTranslator>
#include "AppDefs.h"
#include "dbobjects.h"

const static QString aquariumTypeNames[AquariumType::EndOfList] =
{
    QString(QObject::tr("Fish Reef")),           /* 0 */
    QString(QObject::tr("Soft Coral Reef")),     /* 1 */
    QString(QObject::tr("Mixed Reef")),          /* 2 */
    QString(QObject::tr("SPS Reef")),            /* 3 */
    QString(QObject::tr("Cyhlids")),             /* 4 */
    QString(QObject::tr("Discus aquarium")),     /* 5 */
    QString(QObject::tr("Fresh aquarium")),      /* 6 */
    QString(QObject::tr("Fresh scape"))          /* 7 */
};

const static QMap<QString, QString> paramTranslationMap =
{
    {   "TEMP", QObject::tr("Temperature")   },
    {   "SAL",  QObject::tr("Salinity")      },
    {   "CA",   QObject::tr("Calcium")           },
    {   "PH",   QObject::tr("pH")                },
    {   "KH",   QObject::tr("kH")                },
    {   "GH",   QObject::tr("gH")                },
    {   "PO4",  QObject::tr("Phosphates")        },
    {   "NO2",  QObject::tr("Nitrite")           },
    {   "NO3",  QObject::tr("Nitrate")           },
    {   "NH3",  QObject::tr("Ammonia")           },
    {   "MG",   QObject::tr("Magnesium")         },
    {   "SI",   QObject::tr("Silicates")         },
    {   "K",    QObject::tr("Potassium")         },
    {   "I",    QObject::tr("Iodine")            },
    {   "SR",   QObject::tr("Strontium")         },
    {   "FE",   QObject::tr("Ferrum")            },
    {   "B",    QObject::tr("Boron")             },
    {   "MO",   QObject::tr("Molybdenum")        },
    {   "ORP",  QObject::tr("ORP")               }
};

DBManager::DBManager(QObject *parent) : QObject(parent)
{
#ifdef  Q_OS_ANDROID
    appPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    if (QDir(appPath + "/" + appFolder).exists() == false)
    {
        qInfo() << "Creating " << appPath + "/" + appFolder << "   "
                << QDir().mkdir(appPath + "/" + appFolder);
        qInfo() << "Creating " << appPath + "/" + appFolder + "/" + dbFolder + "/" << "   "
                << QDir().mkdir(appPath + "/" + appFolder + "/" + dbFolder + "/");
    }

    if (QDir(appPath + "/" + appFolder + "/" + imgFolder).exists() == false)
        qInfo() << "Creating " << appPath + "/" + appFolder + "/" + imgFolder + "/"
                << QDir().mkdir(appPath + "/" + appFolder + "/" + imgFolder + "/");

    dbFileLink = appPath + "/" + appFolder + "/" + dbFolder + "/" +dbFile;

    qWarning() << "dbFileLink = " << dbFileLink;
#else
    if (QDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder).exists() == false)
        QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder);

    if (QDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + imgFolder).exists() == false)
        QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + imgFolder);

    dbFileLink = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + dbFolder + "/" + dbFile;
#endif

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(dbFileLink);
    db.open();

    qDebug() << "DB file = " << dbFileLink;

    initDB();

    isParamDataChanged = true;
}

DBManager::~DBManager()
{

}

TankObj *DBManager::currentTankSelected()
{
    TankObj *obj = nullptr;

    if (curSelectedObjs.listOfUserTanks.size() > curSelectedObjs.tankIdx)
        obj = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    return obj;
}

bool DBManager::getActionCalendar()
{
    bool res = false;
    QSqlQuery query("SELECT * FROM ACTIONS_TABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"' ORDER BY STARTDATE ASC");

    if (actionList->setData(&query) != true)
        qDebug() << "actionList->setData error";

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

        obj->setFullName(QObject::tr(paramTranslationMap[obj->shortName()].toLocal8Bit()));
    }

    return res;
}

bool DBManager::getLatestParams()
{
    bool found = false;
    LastDataParamRecObj *recObj = nullptr;
    int curIdx = 0;
    unsigned int lastDateRecord = 0;

    QSqlQuery qDt("SELECT MAX(TIMESTAMP) FROM HISTORY_VALUE_TABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"'");

    if (qDt.next())
        lastDateRecord = qDt.value(0).toInt();

    if (isParamDataChanged == true)
    {
        smpIdList.clear();

        QSqlQuery query0("SELECT SMP_ID FROM HISTORY_VALUE_TABLE WHERE TANK_ID='"+currentTankSelected()->tankId()+"' ORDER BY SMP_ID DESC");

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
                smpIdList.append(query0.value(0).toInt());
        }

        isParamDataChanged = true;
    }

    for (int i = 0; i < smpIdList.size(); i++)
        if (smpIdList.at(i) == curSelectedObjs.curSmpId)
        {
            curIdx = i;
            break;
        }

    curSelectedObjs.listOfCurrValues.clear();

    if (smpIdList.size() > 0)
    {
        QSqlQuery query("SELECT v.SMP_ID, v.TANK_ID, v.PARAM_ID, v.VALUE, v.TIMESTAMP, n.TEXT, n.IMAGELINK "
                        "FROM HISTORY_VALUE_TABLE v "
                        "LEFT JOIN HISTORY_NOTES_TABLE n ON n.SMP_ID = v.SMP_ID "
                        "WHERE v.SMP_ID = '"+QString::number(smpIdList.at(curIdx))+"'");

        while (query.next())
        {
            recObj = new LastDataParamRecObj(query.value(query.record().indexOf("PARAM_ID")).toInt(),
                                             query.value(query.record().indexOf("SMP_ID")).toInt(),
                                             -1,
                                             query.value(query.record().indexOf("VALUE")).toFloat(),
                                             -1,
                                             (unsigned int)query.value(query.record().indexOf("TIMESTAMP")).toInt(),
                                             0,
                                             lastDateRecord,
                                             query.value(query.record().indexOf("TEXT")).toString(),
                                             query.value(query.record().indexOf("IMAGELINK")).toString());

            if (mapPersonal.size() > 0)
                recObj->setEn(mapPersonal[recObj->paramId()]);

            curSelectedObjs.listOfCurrValues.append(recObj);
        }

        if (smpIdList.size() > 1 && (curIdx + 1) < smpIdList.size())
        {
            QSqlQuery query1("SELECT v.SMP_ID, v.TANK_ID, v.PARAM_ID, v.VALUE, v.TIMESTAMP, n.TEXT, n.IMAGELINK "
                             "FROM HISTORY_VALUE_TABLE v "
                             "LEFT JOIN HISTORY_NOTES_TABLE n ON n.SMP_ID = v.SMP_ID "
                             "WHERE v.SMP_ID = '"+QString::number(smpIdList.at(curIdx + 1))+"'");


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
                                                     lastDateRecord,
                                                     query.value(query.record().indexOf("TEXT")).toString(),
                                                     query.value(query.record().indexOf("IMAGELINK")).toString());

                    if (mapPersonal.size() > 0)
                        recObj->setEn(mapPersonal[recObj->paramId()]);

                    curSelectedObjs.listOfCurrValues.append(recObj);
                }
            }
        }
    }

    return false;
}

int DBManager::getLastSmpId()
{
    int id = 0;

    QSqlQuery query("SELECT MAX(SMP_ID) FROM HISTORY_VALUE_TABLE");

    if(query.next())
        id = query.value(0).toInt();

    return id;
}

bool DBManager::getCurrentUser()
{
    QSqlQuery query("SELECT * FROM USER_TABLE WHERE STATUS != -1");

    if (curSelectedObjs.user != nullptr)
    {
        delete curSelectedObjs.user;
        curSelectedObjs.user = nullptr;
    }

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
    QSqlQuery query("SELECT * FROM TANKS_TABLE WHERE MAN_ID='"+curSelectedObjs.user->man_id+"' AND STATUS != -1");

    curSelectedObjs.listOfUserTanks.clear();

    while (query.next())
    {
        res = true;
        obj = new TankObj(&query);
        obj->setTypeName(QObject::tr(aquariumTypeNames[obj->type()].toLocal8Bit()));
        curSelectedObjs.listOfUserTanks.append(obj);
    }

    return res;
}

bool DBManager::getParamIdList(QList<int> *idList)
{
    bool found = false;

    if (idList != 0)
    {
        QSqlQuery qId("SELECT PARAM_ID FROM HISTORY_VALUE_TABLE "
                      "WHERE TANK_ID = '"+currentTankSelected()->tankId()+"'");

        while (qId.next())
        {
            found = false;

            for (int i = 0; i < idList->size(); i++)
            {
                if (idList->at(i) == qId.value(0).toInt())
                    found = true;
            }

            if (found == false)
                idList->append(qId.value(0).toInt());
        }

        return true;
    }
    else
        return false;
}

bool DBManager::createUser(QString uname, QString upass, QString phone, QString email, QString img)
{
    QByteArray base64Img = 0;

    if (uname.length() > 0 && uname.length() <= AppDef::MAX_USERNAME_SIZE &&
        upass.length() > 0 && upass.length() <= AppDef::MAX_PASS_SIZE &&
        email.length() > 0 && email.length() <= AppDef::MAX_EMAIL_SIZE)
    {
        QSqlQuery query;
        bool res = false;

        if (img.length() > 0)
        {
            QImage src(img.replace("file:///", ""));
            QImage resized = src.scaled(USER_IMAGE_WIDTH, USER_IMAGE_HEIGHT, Qt::KeepAspectRatio);
            QByteArray ba;
            QBuffer buf(&ba);
            resized.save(&buf, "png");
            base64Img = ba.toBase64();
            buf.close();
        }

        query.prepare("INSERT INTO USER_TABLE (MAN_ID, UNAME, UPASS, SELECTED, STATUS, PHONE, EMAIL, AVATAR_IMG, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:man_id, :uname, :upass, :selected, :status, :phone, :email, :avatar_img, :date_create, :date_edit)");

        query.bindValue(":man_id", randId());
        query.bindValue(":uname", uname);
        query.bindValue(":upass", upass);
        query.bindValue(":selected", true);
        query.bindValue(":status", UStatus_Enabled);
        query.bindValue(":phone", phone);
        query.bindValue(":email", email);
        query.bindValue(":avatar_img", QString(base64Img));
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

bool DBManager::editUser(QString uname, QString upass, QString phone, QString email, QString img)
{
    Q_UNUSED(phone);

    QString base64ImgString = "";
    QSqlQuery query;
    bool res = false;

    if (uname.length() > 0 && uname.length() <= AppDef::MAX_USERNAME_SIZE &&
        upass.length() > 0 && upass.length() <= AppDef::MAX_PASS_SIZE &&
        email.length() > 0 && email.length() <= AppDef::MAX_EMAIL_SIZE)
    {
        if (img.length() > 0)
        {
            if (img.contains(".jpg") == true || img.contains(".png") == true)
            {
                QImage src(img);
                QImage resized = src.scaled(USER_IMAGE_WIDTH, USER_IMAGE_HEIGHT, Qt::KeepAspectRatio);
                QByteArray ba;
                QBuffer buf(&ba);
                resized.save(&buf, "png");
                base64ImgString = QString(ba.toBase64());
                buf.close();
            }
            else
                base64ImgString = img;
        }

        query.prepare("UPDATE USER_TABLE SET "
                      "UNAME = '" + uname + "', "
                      "UPASS = '" + upass + "', "
                      "EMAIL = '" + email + "', "
                      "AVATAR_IMG = '" + base64ImgString + "', "
                      "DATE_EDIT = '" + QString::number(QDateTime::currentSecsSinceEpoch()) + "' "
                      "WHERE MAN_ID = '" + curSelectedObjs.user->man_id + "'");

        res = query.exec();

        if (res == false)
            qDebug() << "Edit user error: " << query.lastError();

        return res;
    }
    else
        return false;
}

bool DBManager::saveUserLocationIfRequired(QString country, QString city, double lat, double longt)
{
    bool res = false;
    QSqlQuery query("SELECT COUNTRY FROM USER_TABLE WHERE STATUS != -1");

    res = query.exec();

    if (query.next())
    {
        if (query.value(0).toString().size() == 0)
        {
            qDebug() << "Save new coor";

            query.prepare("UPDATE USER_TABLE SET "
                          "COUNTRY = '" + country + "', "
                          "CITY = '" + city + "', "
                          "COOR_LAT = " + QString::number(lat) + ", "
                          "COOR_LONG = '" + QString::number(longt) + "' "
                          "WHERE MAN_ID = '" + curSelectedObjs.user->man_id + "'");

            res = query.exec();

            qDebug() << query.lastQuery();
        }
    }
    else
        qDebug() << "saveUserLocation user error: " << query.lastError();

    return res;
}

bool DBManager::deleteUser()
{
    QSqlQuery query;
    bool res = false;

    query.prepare("UPDATE USER_TABLE SET "
                  "STATUS = -1, "
                  "DATE_EDIT = '" + QString::number(QDateTime::currentSecsSinceEpoch()) + "' "
                  "WHERE MAN_ID = '" + curSelectedObjs.user->man_id + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Delete user error: " << query.lastError();

    query.prepare("UPDATE TANKS_TABLE SET "
                  "STATUS = -1, "
                  "DATE_EDIT = '" + QString::number(QDateTime::currentSecsSinceEpoch()) + "' "
                  "WHERE MAN_ID = '" + curSelectedObjs.user->man_id + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Delete user error: " << query.lastError();

    return res;
}

bool DBManager::createTank(QString name, QString desc, QString manId, int type, int l, int w, int h, QString imgFile)
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

        query.prepare("INSERT INTO TANKS_TABLE (TANK_ID, MAN_ID, TYPE, IMG, NAME, DESC, STATUS, L, W, H, DATE_CREATE, DATE_EDIT) "
                      "VALUES (:tank_id, :man_id, :type, :img, :name, :desc, :status, :l, :w, :h, :date_create, :date_edit)");

        query.bindValue(":tank_id", tankId);
        query.bindValue(":man_id", manId);
        query.bindValue(":type", type);
        query.bindValue(":name", name);
        query.bindValue(":desc", desc);
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

    return res;
}

bool DBManager::editTank(QString name, QString desc, int type, int l, int w, int h, QString img)
{
    QString base64ImgString = "";
    QSqlQuery query;
    bool res = false;

    if (name.length() > 0 && name.length() <= AppDef::MAX_USERNAME_SIZE)
    {
        if (img.length() > 0)
        {
            if (img.contains(".jpg") == true || img.contains(".png") == true)
            {
                QImage src(img);
                QImage resized = src.scaled(USER_IMAGE_WIDTH, USER_IMAGE_HEIGHT, Qt::KeepAspectRatio);
                QByteArray ba;
                QBuffer buf(&ba);
                resized.save(&buf, "png");
                base64ImgString = QString(ba.toBase64());
                buf.close();
            }
            else
                base64ImgString = img;
        }

        query.prepare("UPDATE TANKS_TABLE SET "
                      "TYPE = " + QString::number(type) + ", "
                      "NAME = '" + name + "', "
                      "DESC = '" + desc + "', "
                      "L = " + QString::number(l) + ", "
                      "W = " + QString::number(w) + ", "
                      "H = " + QString::number(h) + ", "
                      "IMG = '" + base64ImgString + "', "
                      "DATE_EDIT = '" + QString::number(QDateTime::currentSecsSinceEpoch()) + "' "
                      "WHERE TANK_ID = '" + currentTankSelected()->tankId() + "'");

        res = query.exec();

        if (res == false)
            qDebug() << "Edit tank error: " << query.lastError();

        return res;
    }
    else
        return false;
}

bool DBManager::deleteTank(QString tankId)
{
    QSqlQuery query;
    bool res = false;

    query.prepare("UPDATE TANKS_TABLE SET "
                  "STATUS = -1, "
                  "DATE_EDIT = '" + QString::number(QDateTime::currentSecsSinceEpoch()) + "' "
                  "WHERE TANK_ID = '" + tankId + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Delete tank error: " << query.lastError();

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
                if (res == false)
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

    qDebug() << "addParamRecord smpId = " << smpId;

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

    isParamDataChanged = true;

    return res;
}

bool DBManager::editParamRecord(int smpId, int paramId, double value)
{
    QSqlQuery query;
    bool res = false;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    qDebug() << "editParamRecord";

    query.prepare("UPDATE HISTORY_VALUE_TABLE SET "
                  "VALUE = " + QString::number(value) + ", "
                  "TIMESTAMP = " + QString::number(QDateTime::currentSecsSinceEpoch()) + " "
                  "WHERE smp_id = " + QString::number(smpId) + " AND "
                  "PARAM_ID = " + QString::number(paramId) + " AND "
                  "TANK_ID = '" + tank->tankId() + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Edit record error: " << query.lastError();

    return res;
}

bool DBManager::addNoteRecord(int smpId, QString note, QString imageLink)
{
    QStringList imgLinksList;
    QString fileName;
    QString dbFiles;
    QSqlQuery query;
    bool res = false;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    imgLinksList = imageLink.split(';');

    for (int i = 0; i < imgLinksList.size(); i++)
    {
        fileName = getImgDbFolder() + createDbImgFileName(i) + "." + QFileInfo(imgLinksList.at(i)).completeSuffix();
        QFile::copy(imgLinksList.at(i), fileName);

        if (i != 0)
            dbFiles += ";";

        dbFiles += fileName;
    }

    query.prepare("INSERT INTO HISTORY_NOTES_TABLE (SMP_ID, TANK_ID, TEXT, IMAGEDATA, IMAGELINK, TIMESTAMP) "
                  "VALUES (:smp_id, :tank_id, :text, :imagedata, :imagelink, :tm)");

    query.bindValue(":smp_id", smpId);
    query.bindValue(":tank_id", tank->tankId());
    query.bindValue(":text", note);
    query.bindValue(":imagedata", "");
    query.bindValue(":imagelink", dbFiles);
    query.bindValue(":tm", QDateTime::currentSecsSinceEpoch());

    res = query.exec();

    if (res == false)
        qDebug() << "Add Note record error: " << query.lastError();

    isParamDataChanged = true;

    return res;
}

bool DBManager::editNoteRecord(int smpId, QString note, QString imageLink)
{
    QSqlQuery query;
    bool res = false;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    query.prepare("SELECT * FROM HISTORY_NOTES_TABLE "
                  "WHERE SMP_ID = " + QString::number(smpId));

    res = query.exec();

    if (query.first() != 0)
    {
        query.prepare("UPDATE HISTORY_NOTES_TABLE SET "
                      "TEXT = '" + note + "', "
                      "IMAGEDATA = '', "
                      "IMAGELINK = '" + imageLink + "', "
                      "TIMESTAMP = " + QString::number(QDateTime::currentSecsSinceEpoch()) + " "
                      "WHERE SMP_ID = " + QString::number(smpId) + " AND "
                      "TANK_ID = '" + tank->tankId() + "'");

        res = query.exec();

        qDebug() << query.lastQuery();

        if (res == false)
            qDebug() << "Edit Note record error: " << query.lastError();
    }
    else
        res = addNoteRecord(smpId, note, imageLink);

    return res;
}

bool DBManager::addActionRecord(QString tankId, QString name, QString desc, int periodType, int period, int tm)
{
    QSqlQuery query;
    bool res = false;

    query.prepare("INSERT INTO ACTIONS_TABLE (TANK_ID, TYPE, NAME, DESC, PERIOD, EN, STARTDATE) "
                  "VALUES (:tank_id, :type, :name, :desc, :period, :en, :tm)");

    query.bindValue(":tank_id", tankId);
    query.bindValue(":type", periodType);
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

bool DBManager::editActionRecord(int id, QString tankId, QString name, QString desc, int periodType, int period, int tm)
{
    QSqlQuery query;
    bool res = false;

    query.prepare("UPDATE ACTIONS_TABLE SET "
                  "TYPE = " + QString::number(periodType) + ", "
                  "NAME = '" + name + "', "
                  "DESC = '" + desc + "', "
                  "PERIOD = " + QString::number(period) + ", "
                  "EN = 1, "
                  "STARTDATE = " + QString::number(tm) + " "
                  "WHERE id = " + QString::number(id) + " AND "
                  "TANK_ID = '" + tankId + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Edit Action record error: " << query.lastError();

    return res;
}

bool DBManager::deleteActionRecord(int id, QString tankId)
{
    QSqlQuery query;
    bool res = false;

    query.prepare("DELETE FROM ACTIONS_TABLE "
                  "WHERE ID = " + QString::number(id) + " AND "
                  "TANK_ID = '" + tankId + "'");

    res = query.exec();

    if (res == false)
        qDebug() << "Delete Action record error: " << query.lastError();

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
    const int randomStringLength = RAND_ID_LENGTH;
    QString randomString;

    for(int i = 0; i < randomStringLength; ++i)
    {
        int index = qrand() * QDateTime::currentDateTime().time().msec();

        index = index % possibleCharacters.length();
        QChar nextChar = possibleCharacters.at(index);
        randomString.append(nextChar);
    }

    return randomString;
}

bool DBManager::initDB()
{
    QSqlQuery query;
    bool res = false;

    res = query.exec("CREATE TABLE IF NOT EXISTS USER_TABLE"
                "(MAN_ID varchar(16), "
                "UNAME varchar(64), "
                "UPASS varchar(128), "
                "SELECTED integer, "
                "STATUS integer, "
                "PHONE varchar(16), "
                "EMAIL varchar(64), "
                "COUNTRY varchar(32), "
                "CITY varchar(32), "
                "COOR_LAT REAL, "
                "COOR_LONG REAL, "
                "AVATAR_IMG blob, "
                "DATE_CREATE integer, "
                "DATE_EDIT integer )");

    if (res == false)
        qDebug() << query.lastError();

    query.prepare("SELECT COUNTRY FROM USER_TABLE");
    query.exec();

    if (query.next() == false)
    {
        query.exec("ALTER TABLE USER_TABLE ADD COUNTRY VARCHAR(32)");
        query.exec("ALTER TABLE USER_TABLE ADD CITY VARCHAR(32)");
        query.exec("ALTER TABLE USER_TABLE ADD COOR_LAT REAL");
        query.exec("ALTER TABLE USER_TABLE ADD COOR_LONG REAL");
    }


    res = query.exec("CREATE TABLE IF NOT EXISTS TANKS_TABLE "
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

    if (res == false)
        qDebug() << query.lastError();

    res = query.exec("CREATE TABLE IF NOT EXISTS HISTORY_VALUE_TABLE "
                "(ID integer PRIMARY KEY AUTOINCREMENT, "
                "SMP_ID integer, "
                "TANK_ID varchar(16), "
                "PARAM_ID integer, "
                "VALUE float, "
                "TIMESTAMP integer)");

    if (res == false)
        qDebug() << query.lastError();

    res = query.exec("CREATE TABLE IF NOT EXISTS HISTORY_NOTES_TABLE "
                "(SMP_ID integer, "
                "TANK_ID varchar(16), "
                "TEXT text, "
                "IMAGEDATA blob, "
                "IMAGELINK varchar(64),"
                "TIMESTAMP integer)");

    if (res == false)
        qDebug() << query.lastError();

    /* Limits count must match DbManager::AquariumType */
    res = query.exec("CREATE TABLE IF NOT EXISTS DICT_TABLE "
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

    if (res == false)
        qDebug() << query.lastError();

    res = query.exec("SELECT COUNT(*) FROM DICT_TABLE");

    query.first();

    if (query.value(0).toInt() == 0)
    {
        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (1, 'TEMP', 'Temperature', '°C', 22.2, 25.6, 24.4, 28.3, 24.4, 28.3, 24.4, 28.3, 22.2, 27.8, 24.4, 30, 24.4, 30.0, 24.4, 30.0)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (2, 'SAL', 'Salinity', 'ppt', 26.6, 33.2, 30.6, 35, 33.0, 35.0, 34.0, 35.0, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (3, 'CA', 'Calcium', 'ppm', 350, 450, 380, 450, 380, 450, 380, 450, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (4, 'PH', 'pH', 'ppm', 8.1, 8.4, 8.1, 8.4, 8.1, 8.4, 8.1, 8.4, 7.5, 8.5, 6.0, 7.5, 6.5, 7.5, 6.5, 7.5)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (5, 'KH', 'kH', 'ppm', 8.0, 12.0, 8.0, 12.0, 8.0, 12.0, 8.0, 12.0, 10, 18, 3, 8, 4, 8, 4, 8)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (6, 'GH', 'gH', 'dKh', -1, -1, -1, -1, -1, -1, -1, -1, 12, 20, 3, 8, 4, 12, 4, 12)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (7, 'PO4', 'Phosphates', 'ppm', 0, 0.2, 0, 0.2, 0, 0.05, 0, 0.05, 0, 1, 0, 1, 0, 1, 0, 1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (8, 'NO2', 'Nitrite', 'ppb', 0, 100, 0, 100, 0, 100, 0, 100, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (9, 'NO3', 'Nitrate', 'ppm', 0, 30, 0, 10, 0, 1, 0, 1, 0, 50, 0, 30, 0, 50, 0, 50)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (10, 'NH3', 'Ammonia', 'ppm', 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05, 0, 0.05)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (11, 'CO2', 'Carbon', 'ppm, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 4, 30, 4, 30')");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (12, 'MG', 'Magnesium', 'ppm', 1150, 1350, 1250, 1350, 1250, 1350, 1250, 1350, 10, -1, 10, -1, 10, -1, 10, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (13, 'SI', 'Silicates', 'ppm', 0, 3, 0.06, 2, 0.06, 2, 0.06, 2, 0, 2, 0, 2, 0, 2, 0, 2)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (14, 'K', 'Potassium', 'ppm', 380, 400, 380, 400, 380, 400, 380, 400, 5, 10, 5, 1, 5, 20, 5, 20)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (15, 'I', 'Iodine', 'ppm', 0.04, 0.1, 0.06, 0.1, 0.06, 0.1, 0.06, 0.1, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (16, 'SR', 'Strontium', 'ppm', 4, 10, 8, 14, 8, 14, 8, 14, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (17, 'FE', 'Ferrum', 'ppm', 0.1, 0.3, 0.1, 0.3, 0.1, 0.3, 0.1, 0.3, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (18, 'B', 'Boron', 'ppm', 0, 10, 0, 10, 0, 10, 0, 10, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (19, 'MO', 'Molybdenum', 'ppm', 0.03, 0.12, 0.03, 0.12, 0.03, 0.12, 0.03, 0.12, -1, -1, -1, -1, -1, -1, -1, -1)");

        res = query.exec("INSERT INTO DICT_TABLE "
                   "(PARAM_ID, SHORT_NAME, FULL_NAME, UNIT_NAME, MIN_1, MAX_1, MIN_2, MAX_2, MIN_3, MAX_3, MIN_4, MAX_4, MIN_5, MAX_5, MIN_6, MAX_6, MIN_7, MAX_7, MIN_8, MAX_8)"
                   "VALUES (20, 'ORP', 'ORP', 'mV', 250, 400, 250, 400, 250, 200, 250, 400, -1, -1, -1, -1, -1, -1, -1, -1)");
    }

    if (res == false)
        qDebug() << query.lastError();

    res = query.exec("CREATE TABLE IF NOT EXISTS PERSONAL_PARAM_TABLE "
                "(PARAM_ID integer, "
                "TANK_ID varchar(16), "
                "ENABLED integer)");

    if (res == false)
        qDebug() << query.lastError();


    res = query.exec("CREATE TABLE IF NOT EXISTS ACTIONS_TABLE "
               "(ID integer PRIMARY KEY AUTOINCREMENT,"
               "TANK_ID varchar(16),"
               "TYPE integer,"
               "NAME text,"
               "DESC text,"
               "PERIOD integer,"
               "EN integer,"
               "STARTDATE integer)");

    if (res == false)
        qDebug() << query.lastError();

    return true;
}

QString DBManager::getAquariumTypeString(AquariumType type)
{
    if (type < EndOfList)
        return QObject::tr(aquariumTypeNames[type].toLocal8Bit());
    else
        return QString("");
}


bool DBManager::less(QObject *v1, QObject *v2)
{
    PointObj *a1 = (PointObj*) v1;
    PointObj *a2 = (PointObj*) v2;

    return a1->tm() > a2->tm();
}

QString DBManager::createDbImgFileName(int i)
{
    QString fileName;
    QString num;
    TankObj *tank = (TankObj*) curSelectedObjs.listOfUserTanks.at(curSelectedObjs.tankIdx);

    fileName = tank->tankId();
    fileName += "_" + QDateTime::currentDateTime().toString("yyyyMMdd_hhmm");
    fileName += "_" + num.asprintf("%02u", i);

    return fileName;
}

QString DBManager::createDbImgAccountFileName()
{
    QString fileName = "";

    fileName = curSelectedObjs.user->man_id.left(4);
    fileName += "_" + QDateTime::currentDateTime().toString("yyyyMMdd_hhmm");

    return fileName;
}
