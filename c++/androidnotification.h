#ifndef ANDROIDNOTIFICATION_H
#define ANDROIDNOTIFICATION_H

#include <QObject>

class AndroidNotification : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    Q_PROPERTY(QString details READ details WRITE setDetails NOTIFY detailsChanged)
public:
    explicit AndroidNotification(QObject *parent = 0);

    void setTitle(const QString &title);
    void setMessage(const QString &message);
    void setDetails(const QString &mdetails);

    QString title() const;
    QString message() const;
    QString details() const;

signals:
    void titleChanged();
    void messageChanged();
    void detailsChanged();

public slots:
    void updateAndroidNotification();

private:
    QString _title;
    QString _message;
    QString _details;
};

#endif // ANDROIDNOTIFICATION_H
