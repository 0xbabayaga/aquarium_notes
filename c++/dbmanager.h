#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QDir>
#include <QQmlApplicationEngine>
#include "dbobjects.h"
#include "imagegallery.h"
#include "actionlist.h"

#define RAND_ID_LENGTH  16

#define DIAGRAMM_DRAW_GAP_TOP       0.30  //Means +20% of full scale
#define DIAGRAMM_DRAW_GAP_BOTTOM    0.30  //Means +20% of full scale

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
    bool    addActionRecord(QString tankId, QString name, QString desc, int type, int period, int tm);
    bool    editPersonalParamState(QString tankId, int paramId, bool en);

    /* Read basics */
    //bool    getParamsList();
    bool    getParamsList(QString tankId, AquariumType type);
    bool    getHistoryParams();
    int     getLastSmpId();
    bool    getLatestParams();
    bool    getActionCalendar();

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
    /* Gui diagram drawing */
    void    clearDiagrams();
    void    addDiagram(int num, int paramId, int xMin, int xMax, float yMin, float yMax, QVariantMap points);
    void    drawDiagrams();

signals:

public slots:
    void    onGuiUserCreate(QString uname, QString upass, QString email);
    void    onGuiTankCreate(QString name, int type, int l, int w, int h, QString imgFile);
    void    onGuiAddRecord(int smpId, int paramId, double value);
    void    onGuiAddRecordNote(int smpId, QString notes, QString imageLink);
    void    onGuiAddActionRecord(QString name, QString desc, int type, int period, int tm);
    void    onGuiTankSelected(int tankIdx);
    void    onGuiPersonalParamStateChanged(int paramId, bool en);
    void    onGuiRefreshData();

public:
    const QString   dbFolder = "db";
    const QString   dbFile = "db.db";

private:
    ActionList      *actionList;
    QString         dbFileLink;
    QSqlDatabase    db;
    ImageGallery    *imageGallery;

    /* Store params enumeration */
    QList<QObject*> paramsGuiList;
    QMap<int, bool> mapPersonal;

    QList<QObject*> aquariumTypeList;
    QList<QObject*> pointList;

    /* Currently selected objects */
    UTObj           curSelectedObjs;

private:
    QQmlApplicationEngine   *qmlEngine = nullptr;
};

#endif // DBMANAGER_H
