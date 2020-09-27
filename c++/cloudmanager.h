#ifndef CLOUDMANAGER_H
#define CLOUDMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>
#include "dbobjects.h"

#define CLOUDMAN_RESPONSE_TMT   5000
#define CLOUD_SERVICE_URL       "https://as.tikava.by/reg.php"

class CloudManager : public QObject
{
    Q_OBJECT
public:
    explicit CloudManager(QObject *parent = nullptr);
    ~CloudManager();

    enum ReponseError
    {
        NoError = 0,
        Error_Timeout = 1,
        Error_Network = 2,
        Error_Undefined = 3
    };

public:
    void request_registerApp(UserObj *user);

signals:
    void response_registerApp(int error, QString manId, QString key);
    void response_error(int error);

private slots:
    void onReplyReceived(QNetworkReply *reply);
    void onTimeout();


protected:
    QNetworkAccessManager *man = nullptr;
    QUrl                  cloudUrl;
    QTimer                *tmt;
};

#endif // CLOUDMANAGER_H
