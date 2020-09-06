#include "jnimanager.h"
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QDebug>

JNIManager *JNIManager::_instance = nullptr;

static void callFromJava(JNIEnv *env, jobject /*thiz*/, jstring value)
{
    //emit JNIManager::instance()->messageFromJava(env->GetStringUTFChars(value, nullptr));

    qDebug() << "CALL FROM JAVA" << value;
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
