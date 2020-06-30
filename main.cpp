#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCameraInfo>
#include <QCamera>
#include "c++/dbmanager.h"
#include "c++/AppDefs.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //qmlRegisterType<PermissionManager>("ANotes.PermissionManager", 1, 0, "PermissionManager");

    AppDef::declareQML();

    app.setOrganizationName("ANotes");
    app.setOrganizationDomain("org.anotes.com");
    app.setApplicationName("AquariumNotes");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);


    const QList<QCameraInfo> cameras = QCameraInfo::availableCameras();
    for (const QCameraInfo &cameraInfo : cameras)
    {
        qDebug() << cameraInfo.deviceName();
    }

    DBManager *dbMan = new DBManager(&engine);


    return app.exec();
}
