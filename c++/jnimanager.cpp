#include "jnimanager.h"
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QDebug>
#include "androidnotification.h"
#include <jni.h>

JNIManager *JNIManager::_instance = nullptr;


#include <jni.h>

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL
  Java_org_tikava_AquariumNotes_ActionTaskBackground_callFromJava(JNIEnv *env,
                                                    jobject obj,
                                                    jstring str)
{
    AndroidNotification *notify = new AndroidNotification();
    notify->setNotification("Servcie app" + QString(env->GetStringUTFChars(str, 0)));
    notify->updateAndroidNotification();
}

#ifdef __cplusplus
}
#endif

static void callFromJava(JNIEnv *env, jobject /*thiz*/, jstring value)
{
    //emit JNIManager::instance()->messageFromJava(env->GetStringUTFChars(value, nullptr));

    qDebug() << "CALL FROM JAVA" << value;

    AndroidNotification *notify = new AndroidNotification();
    notify->setNotification("Servcie app");
    notify->updateAndroidNotification();

}

JNIManager::JNIManager(QObject *parent) : QObject(parent)
{
    _instance = this;

    JNINativeMethod methods[] {{"callFromJava", "(Ljava/lang/String;)V", reinterpret_cast<void *>(callFromJava)}};
    QAndroidJniObject javaClass("org/tikava/AquariumNotes/ActionTaskBackground");

    QAndroidJniEnvironment env;
    jclass objectClass = env->GetObjectClass(javaClass.object<jobject>());
    env->RegisterNatives(objectClass,
                         methods,
                         sizeof(methods) / sizeof(methods[0]));
    env->DeleteLocalRef(objectClass);
}
