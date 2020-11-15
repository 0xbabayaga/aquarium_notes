#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QStandardPaths>
#include "dbobjects.h"
#include "actionlist.h"
#include "AppDefs.h"

#define DIAGRAMM_DRAW_GAP_TOP       0.50  //Means +50% of full scale
#define DIAGRAMM_DRAW_GAP_BOTTOM    0.50  //Means +50% of full scale

#define USER_IMAGE_WIDTH            256
#define USER_IMAGE_HEIGHT           256

/* Import/Export */
bool    exportToFile(QString name);
bool    importFromFile(QString name);

class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(bool isReadOnly, QObject *parent = nullptr);
    ~DBManager();

    friend class AppManager;

    typedef struct
    {
        UserObj         *user = nullptr;
        QList<QObject*> listOfUserTanks;
        int             tankIdx = 0;
        int             lastSmpId = 0;
        int             curSmpId = 0;
        QList<QObject*> listOfCurrValues;
    }   UTObj;

public:
    static QString getAquariumTypeString(AquariumType type);

public:
    bool    openDB();
    bool    closeDB();

public:
    /* Database management */
    bool    initDB();
    bool    createUser(QString uname, QString upass, QString phone, QString email, QString img, AppDef::AppUserStatus status);
    bool    editUser(QString uname, QString upass, QString phone, QString email, QString img);
    bool    setAppKey(QString key);
    QString getAppKey();
    bool    saveUserLocationIfRequired(QString country, QString city, double lat, double longt);
    bool    deleteUser();
    bool    createTank(QString name, QString desc, QString manId, int type, int l, int w, int h, QString imgFile);
    bool    editTank(QString tankId, QString name, QString desc, int type, int l, int w, int h, QString img);
    bool    deleteTank(QString tankId);
    bool    createTankDefaultParamSet(QString tankId, AquariumType type);
    bool    addParamRecord(int smpId, int paramId, double value);
    bool    editParamRecord(int smpId, int paramId, double value);
    bool    addNoteRecord(int smpId, QString note, QString imageLink);
    bool    editNoteRecord(int smpId, QString note, QString imageLink);
    bool    addActionRecord(QString tankId, QString name, QString desc, int periodType, int period, int tm);
    bool    editActionRecord(int id, QString tankId, QString name, QString desc, int periodType, int period, int tm);
    bool    deleteActionRecord(int id, QString tankId);
    bool    editPersonalParamState(QString tankId, int paramId, bool en);

    /* Read basics */
    bool    getParamsList(QString tankId, AquariumType type);
    int     getLastSmpId();
    bool    getLatestParams();
    bool    getActionCalendar(QString tankId, bool backGround);
    bool    getCurrentUser();
    bool    getUserTanksList();
    bool    getTankStoryList(int id);
    bool    getParamIdList(QList<int> *idList);
    bool    getCurrentObjs();

    static QString generateKey(quint64 tm, unsigned int crc);
    static QString getAppFolder()       {   return appPath;     }
    static QString getDbFolder()        {   return dbFolder;    }
    static QString getImgFolder()       {   return imgFolder;   }
    static QString getImgFolderPath()   {   return appPath + "/" + imgFolder + "/";   }
    static QString getDbFile()          {   return dbFile;      }
    static QString getDbFilePath()      {   return dbFileLink;  }

    static bool    less(QObject *v1, QObject *v2);

    /* Utitlity methods */
    QString randId();
    TankObj *currentTankSelected();
    UTObj   *currentSelectedObjs()  {   return &curSelectedObjs;    }
    ActionList* currentActionList() {   return actionList;          }
    QString createFullImagesLink(QString link);

    bool isParamEnabled(char paramId);

    QString createDbImgFileName(int i);
    QString createDbImgAccountFileName();

public:
    static const QString   dbFolder;
    static const QString   imgFolder;
    static const QString   dbFile;
    static const QString   appFolder;

private:
    static QString         appPath;
    static QString         dbFileLink;

    QSqlDatabase    db;

    /* Store params enumeration */
    QList<QObject*> paramsGuiList;
    QMap<int, bool> mapPersonal;
    QList<QObject*> aquariumTypeList;
    QList<QObject*> pointList;
    QList<QObject*> datesList;
    QList<int>      smpIdList;
    QList<TankStoryObj*> tankStoryList;

    /* Currently selected objects */
    UTObj           curSelectedObjs;
    bool            isParamDataChanged;

    ActionList      *actionList = nullptr;

    bool            readOnly = false;
};

#endif // DBMANAGER_H
