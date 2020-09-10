#include "backmanager.h"
#include <QtSql>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QDateTime>
#include <QSqlError>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QDebug>
#include "androidnotification.h"
#include "dbmanager.h"
#include <jni.h>

static void debugOut(QString message);

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL
Java_org_tikava_AquariumNotes_Background_callbackOnTimer(JNIEnv *env, jobject obj, jint cnt)
{
    int i = 0;
    int n = 0;

    DBManager *dbMan = new DBManager(true);

    dbMan->openDB();

    if (dbMan->getCurrentUser() == true)
    {
        //debugOut("Current user = " + dbMan->currentSelectedObjs()->user->uname);

        if (dbMan->currentSelectedObjs()->user != nullptr)
        {
            if (dbMan->getUserTanksList() == true)
            {
                //for (i = 0; i < dbMan->currentSelectedObjs()->listOfUserTanks.size(); i++)
                {
                    QString tankId = ((TankObj*)(dbMan->currentSelectedObjs()->listOfUserTanks.at(i)))->tankId();
                    quint64 now = QDateTime::currentDateTime().toSecsSinceEpoch();

                    dbMan->getActionCalendar(tankId);


                    debugOut("size = " + QString::number(dbMan->currentActionList()->getData()->size()));

                    for (n = 0; n < dbMan->currentActionList()->getData()->size(); n++)
                    {
                        ActionObj *act = (ActionObj*)(dbMan->currentActionList()->getData()->at(n));

                        if (act != 0)
                        {
                            if (act->startDT() >= now && (act->startDT() + 60) < now)
                            {
                                debugOut("size = " + tankId);
                            }
                        }
                    }
                }
            }
        }
    }
    else
        debugOut("Read user failed");



    dbMan->closeDB();

    delete dbMan;
}

#ifdef __cplusplus
}
#endif

static void debugOut(QString message)
{
    AndroidNotification *notify = new AndroidNotification();
    notify->setNotification(message);
    notify->updateAndroidNotification();
}

