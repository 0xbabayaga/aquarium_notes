#include <QGuiApplication>
#include <QQmlApplicationEngine>
#ifdef Q_OS_ANDROID
#include <QAndroidService>
#endif
#include <QDebug>
#include "c++/appmanager.h"
#include "c++/AppDefs.h"
#include "c++/androidnotification.h"
#include "c++/backgroundservice.h"
#include "c++/jnimanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QStringList args = QCoreApplication::arguments();
    bool isStartService = false;

    qDebug() << "ARGIUS = " << QCoreApplication::arguments().count();
    qDebug() << "ARG1 = " << QCoreApplication::arguments();

    for (int i = 0; i < args.count(); i++)
    {
        if (args.at(i) == "-service")
        {
            isStartService = true;
            break;
        }
    }

    isStartService = (args.count() > 1);

    if (isStartService == false)
    {
        qDebug() << "APP STARTED";

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
    else
    {
        qDebug() << "SERVICE STARTED";

        //BackgroundService *back = new BackgroundService();

        JNIManager *jni = new JNIManager();

        return app.exec();
    }
}
