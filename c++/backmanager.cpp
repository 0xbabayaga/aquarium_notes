#include "backmanager.h"
#include <QtSql>
#include <QSqlDatabase>
#include <QSqlQuery>
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
    //AndroidNotification *notify = new AndroidNotification();
    //notify->setNotification("Service " + QString::number(cnt));
    //notify->updateAndroidNotification();

    DBManager *dbMan = new DBManager(true);

    dbMan->openDB();
    //if (dbMan->openDB() == false)
     //   debugOut("Cannot open DB");
    //else
    //   debugOut("DB opened Succesfully");

    if (dbMan->getCurrentUser() == true)
    {
        debugOut("Current user = " + dbMan->currentSelectedObjs()->user->uname);
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

