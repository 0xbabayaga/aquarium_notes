#ifndef CLOUDMANAGER_H
#define CLOUDMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class CloudManager : public QObject
{
    Q_OBJECT
public:
    explicit CloudManager(QObject *parent = nullptr);
    ~CloudManager();

signals:

public slots:
    void onReplyReceived(QNetworkReply *reply);

protected:
    QNetworkAccessManager *man = nullptr;
};

#endif // CLOUDMANAGER_H
