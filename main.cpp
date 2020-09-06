#include <QGuiApplication>
#include <QQmlApplicationEngine>
#ifdef Q_OS_ANDROID
#include <QAndroidService>
#endif
#include <QDebug>
#include "c++/appmanager.h"
#include "c++/AppDefs.h"
#include "c++/androidnotification.h"
//#include "c++/jnimanager.h"

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


        //JNIManager *jni = new JNIManager();
        AppManager *appMan = new AppManager(&engine);

        engine.load(url);

        AndroidNotification *notify = new AndroidNotification();
        notify->setNotification("Application");
        notify->updateAndroidNotification();


        return app.exec();
    }
    else
    {
        qDebug() << "SERVICE STARTED";
        QAndroidService app(argc, argv);


        AndroidNotification *notify = new AndroidNotification();
        notify->setNotification("Lala bla");
        notify->updateAndroidNotification();


        return app.exec();
    }
}
