#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "c++/dbmanager.h"
#include "c++/AppDefs.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

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

    DBManager *dbMan = new DBManager(&engine);


    return app.exec();
}
