#include "cloudmanager.h"

CloudManager::CloudManager(QObject *parent) : QObject(parent)
{
    man = new QNetworkAccessManager();

    connect(man, &QNetworkAccessManager::finished, this, &CloudManager::onReplyReceived);

    man->get(QNetworkRequest(QUrl("https://tikava.by/reg.php")));
}

CloudManager::~CloudManager()
{
    if (man != 0)
        delete man;
}

void CloudManager::onReplyReceived(QNetworkReply *reply)
{
    qDebug() << "REPLY: " << reply->readAll();
}
