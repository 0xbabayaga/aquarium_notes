#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QDir>
#include <QQmlApplicationEngine>
#include "dbobjects.h"
#include "imagegallery.h"

#define RAND_ID_LENGTH  16

typedef enum
{
    UStatus_Disabled = 0,
    UStatus_Enabled = 1,
    UStatus_Blocked = 2
}   eUStatus;

class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QQmlApplicationEngine *engine, QObject *parent = nullptr);
    ~DBManager();

    typedef struct
    {
        UserObj         *user = nullptr;
        QList<QObject*> listOfUserTanks;
        int             tankIdx = 0;
        int             lastSmpId = 0;

        QList<QObject*> listOfCurrValues;
    }   UTObj;

public:
    static QString getAquariumTypeString(AquariumType type);

private:
    /* Database management */
    bool    initDB();
    bool    createUser(QString uname, QString upass, QString phone, QString email);
    bool    createTank(QString name, QString manId, int type, int l, int w, int h, QString imgFile);
    bool    createTankDefaultParamSet(QString tankId, AquariumType type);
    bool    addParamRecord(int smpId, int paramId, double value);
    bool    addNoteRecord(int smpId, QString note, QString imageLink);
    bool    editPersonalParamState(QString tankId, int paramId, bool en);

    /* Read basics */
    //bool    getParamsList();
    bool    getParamsList(QString tankId, AquariumType type);
    bool    getHistoryParams(QString tankId);
    int     getLastSmpId();
    bool    getLatestParams();

    bool    getCurrentUser();
    bool    getUserTanksList();

    /* Preparation for GUI start */
    bool    getCurrentObjs();

    /* Utitlity methods */
    QString randId();
    TankObj *currentTankSelected();

private:
    /* Gui methods */
    void    setInitialDialogStage(int stage, QString name);
    void    setLastSmpId(int id);

signals:

public slots:
    void    onGuiUserCreate(QString uname, QString upass, QString email);
    void    onGuiTankCreate(QString name, int type, int l, int w, int h, QString imgFile);
    void    onGuiAddRecord(int smpId, int paramId, double value);
    void    onGuiAddRecordNote(int smpId, QString notes, QString imageLink);
    void    onGuiTankSelected(int tankIdx);
    void    onGuiPersonalParamStateChanged(int paramId, bool en);

public:
    const QString   dbFolder = "db";
    const QString   dbFile = "db.db";

private:
    QString         dbFileLink;
    QSqlDatabase    db;
    ImageGallery    *imageGallery;

    /* Store params enumeration */
    QList<QObject*> paramsGuiList;
    QMap<int, bool> mapPersonal;

    QList<QObject*> aquariumTypeList;

    /* Currently selected objects */
    UTObj           curSelectedObjs;

private:
    QQmlApplicationEngine   *qmlEngine = nullptr;
};

#endif // DBMANAGER_H
