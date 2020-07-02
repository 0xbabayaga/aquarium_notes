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

    //app.setOrganizationName("AquariumNotes");
    //app.setOrganizationDomain("org.tikava");
    //app.setApplicationName("AquariumNotes");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    DBManager *dbMan = new DBManager(&engine);

    engine.load(url);


    return app.exec();
}
