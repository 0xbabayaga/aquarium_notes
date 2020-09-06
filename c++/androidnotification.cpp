#include "androidnotification.h"
#include <QtAndroid>

AndroidNotification::AndroidNotification(QObject *parent) : QObject(parent)
{
    //connect(this, SIGNAL(notificationChanged()), this, SLOT(updateAndroidNotification()));
}

void AndroidNotification::setNotification(const QString &notification)
{
    if (m_notification == notification)
        return;

    m_notification = notification;
}

QString AndroidNotification::notification() const
{
    return m_notification;
}

void AndroidNotification::updateAndroidNotification()
{
    QAndroidJniObject javaNotification = QAndroidJniObject::fromString(m_notification);
    QAndroidJniObject::callStaticMethod<void>(
        "org/tikava/AquariumNotes/AquariumNotesNotification",
        "notify",
        "(Landroid/content/Context;Ljava/lang/String;)V",
        QtAndroid::androidContext().object(),
        javaNotification.object<jstring>());
}
