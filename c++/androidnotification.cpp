#include "androidnotification.h"
#include <QtAndroid>

AndroidNotification::AndroidNotification(QObject *parent) : QObject(parent)
{
}

void AndroidNotification::setTitle(const QString &title)
{
    _title = title;
}

void AndroidNotification::setMessage(const QString &message)
{
    _message = message;
}

void AndroidNotification::setDetails(const QString &details)
{
    _details = details;
}

QString AndroidNotification::title() const
{
    return _title;
}

QString AndroidNotification::message() const
{
    return _message;
}

QString AndroidNotification::details() const
{
    return _details;
}

void AndroidNotification::updateAndroidNotification()
{
    QAndroidJniObject javaTitle = QAndroidJniObject::fromString(_title);
    QAndroidJniObject javaMessage = QAndroidJniObject::fromString(_message);
    QAndroidJniObject javaDetails = QAndroidJniObject::fromString(_details);

    QAndroidJniObject::callStaticMethod<void>(
        "org/tikava/AquariumNotes/AquariumNotesNotification",
        "notify",
        "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)V",
        QtAndroid::androidContext().object(),
        javaTitle.object<jstring>(),
        javaMessage.object<jstring>());
}
