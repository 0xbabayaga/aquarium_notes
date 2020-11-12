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
#include "cloudmanager.h"

class AppManager : public DBManager
{
    Q_OBJECT
public:
    explicit AppManager(QQmlApplicationEngine *engine, QObject *parent = nullptr);
    ~AppManager();

private:
    void    init();

    bool    getCurrentObjs(bool isFullUpdate);
    bool    getHistoryParams();

    void    getParamsListGui();
    void    getLatestParamsGui();
    void    getActionCalendarGui();

    void    createTankTypesList();
    void    createLangList();
    bool    loadTranslations(int id);
    void    checkAppRegistered();

private:
    /* Gui methods */
    bool    setQmlParam(QString objName, QString name, QVariant value);
    void    setInitialDialogStage(int stage, QString name);
    void    setLastSmpId(int id);
    void    setGalleryImageSelected(QString imgUrl);
    void    setAndroidFlag(bool flag);
    void    setCurrentUser(QString uname, QString email, QString imgLink, int dt);
    void    setExportingState(QString message);
    void    resetStoryView();

    /* Gui diagram drawing */
    void    clearDiagrams();
    void    addDiagram(int num, int paramId, int xMin, int xMax, float yMin, float yMax, QVariantMap points);
    void    drawDiagrams(int selectedPoint);
    void    showAppUpdateNotification(int version, int releasedate);

    /* App settings */
    void    readAppSett();
    void    setSettAfterQMLReady();

    /* App utility */
    QString generateExportFileName();

public slots:
    /* GUI handlers */
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
    void    onGuiFullRefreshData();
    void    onGuiCurrentSmpIdChanged(int smpId);
    void    onGuiOpenGallery();
    void    onGuiLanguageChanged(int id);
    void    onGuiDimensionUnitsChanged(int id);
    void    onGuiVolumeUnitsChanged(int id);
    void    onGuiDateFormatChanged(int id);
    void    onGuiTankStoryLoad(int index);
    void    onGuiRegisterApp();
    void    onGuiExportData(QString fileName);
    void    onGuiImportData(QString fileName);

    /* Postioning handlers */
    void    onPositionDetected();

    /* Cloud communication handlers */
    void    onCloudResponse_Register(int error, QString errorText, QString manId, QString key);
    void    onCloudResponse_AppUpdates(int version, int date);
    void    onCloudResponse_Error(int error, QString errorText);

private:
    QSettings appSett;
    QTranslator translator;
    QQmlApplicationEngine   *qmlEngine = nullptr;

    CloudManager *cloudMan = nullptr;

    QList<QObject*> langsList;

    Position *position = nullptr;
};

#endif // APPMANAGER_H
