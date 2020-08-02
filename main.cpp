#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>
#include "c++/appmanager.h"
#include "c++/AppDefs.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    AppDef::declareQML();

    app.setOrganizationName("AquariumNotes");
    app.setOrganizationDomain("org.tikava");
    app.setApplicationName("AquariumNotes");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    AppManager *appMan = new AppManager(&engine);

    engine.load(url);


    return app.exec();
}
