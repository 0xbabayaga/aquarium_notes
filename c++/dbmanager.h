#ifndef DBMANAGER_H
#define DBMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QDir>
#include <QQmlApplicationEngine>
#include "dbobjects.h"

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

private:
    /* Database management */
    bool    initDB();
    bool    createUser(QString uname, QString upass, QString phone, QString email);
    bool    createTank(QString name, QString manId, int type, int l, int w, int h);
    bool    addParamRecord(int smpId, int paramId, double value);

    /* Read basics */
    bool    getParamsList();
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
    void    setCurrentValuesModel();

signals:

public slots:
    void    onGuiUserCreate(QString uname, QString upass, QString email);
    void    onGuiTankCreate(QString name, int type, int l, int w, int h);
    void    onGuiAddRecord(int smpId, int paramId, double value);
    void    onGuiTankSelected(int tankIdx);

public:
    const QString   dbFolder = "db";
    const QString   dbFile = "db.db";

private:
    QString         dbFileLink;
    QSqlDatabase    db;

    /* Store params enumeration */
    QList<QObject*> paramsGuiList;

    /* Currently selected objects */
    UTObj           curSelectedObjs;

private:
    QQmlApplicationEngine   *qmlEngine = nullptr;
};

#endif // DBMANAGER_H
