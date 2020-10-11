#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSslSocket>
#include <QLocale>
#include <QDebug>

#include "c++/appmanager.h"
#include "c++/AppDefs.h"
#include "c++/version.h"

#ifdef Q_OS_ANDROID
#include <QAndroidService>
#include "c++/androidnotification.h"
#include "c++/backmanager.h"
#endif

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QStringList args = QCoreApplication::arguments();

    qDebug() << "App version = " << APP_VERSION;
    qDebug() << "Device supports OpenSSL: " << QSslSocket::supportsSsl();
    qDebug() << "Locale = " << QLocale::system().name().section(' ', 0, 0);

    if ((args.count() > 1) == false)
    {
        qDebug() << "APP STARTED";

        AppDef::declareQML();

        app.setOrganizationName(APP_ORG);
        app.setOrganizationDomain(APP_DOMAIN);
        app.setApplicationName(APP_NAME);

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
        return app.exec();
    }
}
