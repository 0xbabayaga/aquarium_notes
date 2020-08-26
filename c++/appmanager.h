#ifndef APPMANAGER_H
#define APPMANAGER_H

#include <QObject>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QStandardPaths>
#include <QSettings>
#include <QTranslator>
#include "dbmanager.h"
#include "dbobjects.h"
#include "actionlist.h"
#include "position.h"

class AppManager : public DBManager
{
    Q_OBJECT
public:
    explicit AppManager(QQmlApplicationEngine *engine, QObject *parent = nullptr);
    ~AppManager();

private:
    void    init();

    bool    getCurrentObjs();
    bool    getHistoryParams();

    void    getParamsListGui();
    void    getLatestParamsGui();
    void    getActionCalendarGui();

    void    createTankTypesList();
    void    createLangList();
    bool    loadTranslations(int id);

private:
    /* Gui methods */
    bool    setQmlParam(QString objName, QString name, QVariant value);
    void    setInitialDialogStage(int stage, QString name);
    void    setLastSmpId(int id);
    void    setGalleryImageSelected(QString imgUrl);
    void    setAndroidFlag(bool flag);
    void    setCurrentUser(QString uname, QString email, QString imgLink, int dt);

    /* Gui diagram drawing */
    void    clearDiagrams();
    void    addDiagram(int num, int paramId, int xMin, int xMax, float yMin, float yMax, QVariantMap points);
    void    drawDiagrams();

    /* App settings */
    void    readAppSett();
    void    setSettAfterQMLReady();

public slots:
    void    onQmlEngineLoaded(QObject *object, const QUrl &url);
    void    onGuiUserCreate(QString uname, QString upass, QString email, QString img);
    void    onGuiUserEdit(QString uname, QString upass, QString email, QString img);
    void    onGuiUserDelete();
    void    onGuiTankCreate(QString name, QString desc, int type, int l, int w, int h, QString imgFile);
    void    onGuiTankEdit(QString tankId, QString name, QString desc, int type, int l, int w, int h, QString imgFile);
    void    onGuiTankDelete(QString tankId);
    void    onGuiAddRecord(int smpId, int paramId, double value);
    void    onGuiEditRecord(int smpId, int paramId, double value);
    void    onGuiAddRecordNote(int smpId, QString notes, QString imageLink);
    void    onGuiEditRecordNote(int smpId, QString note, QString imageLink);
    void    onGuiAddActionRecord(QString name, QString desc, int periodType, int period, int tm);
    void    onGuiEditActionRecord(int id, QString name, QString desc, int periodType, int period, int tm);
    void    onGuiDeleteActionRecord(int id);
    void    onGuiActionViewPeriodChanged(int period);
    void    onGuiTankSelected(int tankIdx);
    void    onGuiPersonalParamStateChanged(int paramId, bool en);
    void    onGuiRefreshData();
    void    onGuiCurrentSmpIdChanged(int smpId);
    void    onGuiOpenGallery();
    void    onGuiLanguageChanged(int id);
    void    onGuiDimensionUnitsChanged(int id);
    void    onGuiVolumeUnitsChanged(int id);
    void    onGuiDateFormatChanged(int id);
    void    onGuiTankStoryLoad(int index);

    void    onPositionDetected();

private:
    QSettings appSett;
    QTranslator translator;
    QQmlApplicationEngine   *qmlEngine = nullptr;

    QList<QObject*> langsList;

    Position *position = nullptr;
};

#endif // APPMANAGER_H
