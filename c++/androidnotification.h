#ifndef ANDROIDNOTIFICATION_H
#define ANDROIDNOTIFICATION_H

#include <QObject>

class AndroidNotification : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString notification READ notification WRITE setNotification NOTIFY notificationChanged)
public:
    explicit AndroidNotification(QObject *parent = 0);

    void setNotification(const QString &notification);
    QString notification() const;

signals:
    void notificationChanged();

public slots:
    void updateAndroidNotification();

private:
    QString m_notification;
};

#endif // ANDROIDNOTIFICATION_H
