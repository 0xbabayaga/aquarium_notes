#include "AppDefs.h"
#include "cloudmanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>

CloudManager::CloudManager(QObject *parent) : QObject(parent)
{
    man = new QNetworkAccessManager();
    tmt = new QTimer();
    tmt->stop();
    tmt->setSingleShot(true);
    tmt->setInterval(CLOUDMAN_RESPONSE_TMT);

    cloudUrl = QUrl(CLOUD_SERVICE_URL);

    connect(man, &QNetworkAccessManager::finished, this, &CloudManager::onReplyReceived);
    connect(tmt, &QTimer::timeout, this, &CloudManager::onTimeout);
}

CloudManager::~CloudManager()
{
    if (man != 0)
        delete man;
}

void CloudManager::request_registerApp(UserObj *user)
{
    QString jsonString = "{"
                         "\"method\": \"register\","
                         "\"user\": \"" + user->uname + "\","
                         "\"email\": \"" + user->email + "\","
                         "\"pass\": \"" + user->upass + "\","
                         "\"phone\": \"" + user->phone + "\","
                         "\"country\": \"" + user->country + "\","
                         "\"city\": \"" + user->city + "\","
                         "\"coor_lat\": " + QString::number(user->coor_lat) + ","
                         "\"coor_long\": " + QString::number(user->coor_long) + ","
                         "\"date_create\": " + QString::number(user->date_create) + ","
                         "\"date_edit\": " + QString::number(user->date_edit) + ","
                         "\"key\": \"" + user->man_id.remove(AppDef::MAN_ID_LENGTH/2, AppDef::MAN_ID_LENGTH/2) + "\""
                         "}";

    QByteArray json = jsonString.toLocal8Bit();
    QByteArray postDataSize = QByteArray::number(json.size());
    QNetworkRequest request(cloudUrl);

    //qDebug() << "JSON:" << json;

    request.setRawHeader("User-Agent", APP_ORG);
    request.setRawHeader("X-Custom-User-Agent", APP_NAME);
    request.setRawHeader("Content-Type", "application/json");
    request.setRawHeader("Content-Length", postDataSize);

    man->post(request, json);
    tmt->start();
}

void CloudManager::onReplyReceived(QNetworkReply *reply)
{
    tmt->stop();

    qDebug() << "RESP:" << reply->readAll();

    if (reply->error() == QNetworkReply::NetworkError::NoError)
    {
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll(), &error);
        QJsonObject::const_iterator objMethod = jsonDoc.object().find("method");
        QJsonObject::const_iterator objManId = jsonDoc.object().find("manId");
        QJsonObject::const_iterator objResult = jsonDoc.object().find("result");
        QJsonObject::const_iterator objKey = jsonDoc.object().find("key");

        if (objMethod->isUndefined() == false &&
            objResult->isUndefined() == false &&
            objManId->isUndefined() == false &&
            objKey->isUndefined() == false)
        {
            qDebug() << "PARCED:" << objMethod.value().toString();
            qDebug() << "PARCED:" << objResult.value().toInt();
            qDebug() << "PARCED:" << objKey.value().toString();
            qDebug() << "PARCED:" << objManId.value().toString();
        }
        else
            emit response_error((int)CloudManager::ReponseError::Error_Network);


        if (objMethod->toString() == "register")
            emit response_registerApp(objResult.value().toInt(), objManId.value().toString(), objKey.value().toString());
    }
    else
        emit response_error((int)CloudManager::ReponseError::Error_Network);


    reply->deleteLater();
}

void CloudManager::onTimeout()
{
    tmt->stop();
    emit response_error((int)CloudManager::ReponseError::Error_Timeout);
}
