#include "AppDefs.h"
#include "cloudmanager.h"

CloudManager::CloudManager(QObject *parent) : QObject(parent)
{
    man = new QNetworkAccessManager();

    cloudUrl = QUrl("https://as.tikava.by/reg.php");

    connect(man, &QNetworkAccessManager::finished, this, &CloudManager::onReplyReceived);
}

CloudManager::~CloudManager()
{
    if (man != 0)
        delete man;
}

void CloudManager::request_registerApp(UserObj *user)
{
    QByteArray json = "{"
                      "\"method\": \"register\","
                      "\"user\": \"username@domain.com\","
                      "\"password\": \"mypass\""
                      "}";
    QByteArray postDataSize = QByteArray::number(json.size());
    QNetworkRequest request(cloudUrl);

    request.setRawHeader("User-Agent", APP_ORG);
    request.setRawHeader("X-Custom-User-Agent", APP_NAME);
    request.setRawHeader("Content-Type", "application/json");
    request.setRawHeader("Content-Length", postDataSize);

    man->post(request, json);
}

void CloudManager::onReplyReceived(QNetworkReply *reply)
{
    qDebug() << "REPLY: " << reply->readAll();
}
