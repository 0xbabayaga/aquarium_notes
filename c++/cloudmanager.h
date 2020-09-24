#ifndef CLOUDMANAGER_H
#define CLOUDMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "dbobjects.h"



class CloudManager : public QObject
{
    Q_OBJECT
public:
    explicit CloudManager(QObject *parent = nullptr);
    ~CloudManager();

    void request_registerApp(UserObj *user);

signals:
    void response_registerApp(bool status, UserObj *user, QString key);

public slots:
    void onReplyReceived(QNetworkReply *reply);

protected:
    QNetworkAccessManager *man = nullptr;
    QUrl                  cloudUrl;
};

#endif // CLOUDMANAGER_H
