#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "c++/appmanager.h"
#include "c++/AppDefs.h"

#ifdef Q_OS_ANDROID
#include <QAndroidService>
#include "c++/androidnotification.h"
#include "c++/backmanager.h"
#endif

/*
static void test()
{
    int i = 0;
    int n = 0;
    bool background = true;

    DBManager *dbMan = new DBManager(true);

    dbMan->openDB();

    if (dbMan->getCurrentUser() == true)
    {
        if (dbMan->currentSelectedObjs()->user != nullptr)
        {
            if (dbMan->getUserTanksList() == true)
            {
                for (i = 0; i < dbMan->currentSelectedObjs()->listOfUserTanks.size(); i++)
                {
                    QString tankId = ((TankObj*)(dbMan->currentSelectedObjs()->listOfUserTanks.at(i)))->tankId();
                    quint64 now = QDateTime::currentDateTime().toSecsSinceEpoch();

                    dbMan->getActionCalendar(tankId, background);

                    qDebug() << "size = " << QString::number(dbMan->currentActionList()->getData()->size());

                    for (n = 0; n < dbMan->currentActionList()->getData()->size(); n++)
                    {
                        ActionObj *act = (ActionObj*)(dbMan->currentActionList()->getData()->at(n));

                        if (act != 0)
                        {
                            if (act->startDT() >= (now - 30) && act->startDT() < (now + 30) )
                            {
                                qDebug() << "Action found:";
                                qDebug() << "Hello, " << dbMan->currentSelectedObjs()->user->uname;
                                qDebug() << "Some activity is planned for your " << ((TankObj*)(dbMan->currentSelectedObjs()->listOfUserTanks.at(i)))->name() << " aquarium";
                                qDebug() << act->name();
                                qDebug() << act->desc();
                            }
                        }
                    }
                }
            }
        }
    }

    dbMan->closeDB();

    qDebug() << "Closed";

    delete dbMan;
}
*/

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QStringList args = QCoreApplication::arguments();

    if ((args.count() > 1) == false)
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

        //test();

        AppManager *appMan = new AppManager(&engine);

        engine.load(url);

        return app.exec();
    }
    else
    {
        return app.exec();
    }
}
