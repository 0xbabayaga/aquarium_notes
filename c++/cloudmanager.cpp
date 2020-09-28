#include "AppDefs.h"
#include "cloudmanager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonParseError>
#include <QCryptographicHash>

CloudManager::CloudManager(QString id, QObject *parent) : QObject(parent)
{
    manId = id;

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
    QString md5;
    QString md5Base;

    md5Base = user->man_id;
    md5Base = md5Base.remove(0, user->man_id.length() - AppDef::MAN_ID_CUT_MD5);
    md5Base += QString::number(user->date_create);
    md5 = QString(QCryptographicHash::hash(md5Base.toLocal8Bit(),QCryptographicHash::Md5).toHex());

    QString jsonString = "{"
                         "\"method\": \"register\","
                         "\"user\": \"" + user->uname + "\","
                         "\"email\": \"" + user->email + "\","
                         "\"pass\": \"" + user->upass + "\","
                         "\"manid\": \"" + user->man_id + "\","
                         "\"phone\": \"" + user->phone + "\","
                         "\"country\": \"" + user->country + "\","
                         "\"city\": \"" + user->city + "\","
                         "\"coor_lat\": " + QString::number(user->coor_lat) + ","
                         "\"coor_long\": " + QString::number(user->coor_long) + ","
                         "\"date_create\": " + QString::number(user->date_create) + ","
                         "\"date_edit\": " + QString::number(user->date_edit) + ","
                         "\"key\": \"" + md5 + "\""
                         "}";

    QByteArray json = jsonString.toLocal8Bit();
    QByteArray postDataSize = QByteArray::number(json.size());
    QNetworkRequest request(cloudUrl);

    qDebug() << "REQUEST: " << json;

    request.setRawHeader("User-Agent", APP_ORG);
    request.setRawHeader("X-Custom-User-Agent", APP_NAME);
    request.setRawHeader("Content-Type", "application/json");
    request.setRawHeader("Content-Length", postDataSize);

    man->post(request, json);
    tmt->start();
}

void CloudManager::onReplyReceived(QNetworkReply *reply)
{
    QString md5 = "";

    tmt->stop();

    if (reply->error() == QNetworkReply::NetworkError::NoError)
    {
        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(reply->readAll(), &error);

        if (error.error != QJsonParseError::NoError)
            qDebug() << "JSON ERROR = " << error.errorString() << "on char" << error.offset;

        QJsonObject::const_iterator objMethod = jsonDoc.object().find("method");

        if (objMethod->isUndefined() == false)
        {
            if (objMethod.value().toString() == "register")
            {
                QJsonObject::const_iterator objManId = jsonDoc.object().find("manId");
                QJsonObject::const_iterator objResult = jsonDoc.object().find("result");
                QJsonObject::const_iterator objKey = jsonDoc.object().find("key");

                if (objResult->isUndefined() == false &&
                    objManId->isUndefined() == false &&
                    objKey->isUndefined() == false)
                {
                    if (objResult.value().toInt() == CloudManager::ReponseError::NoError &&
                        objManId.value().toString() == manId &&
                        isKeyValid(objKey.value().toString()) == true)
                    {
                        emit response_registerApp(objResult.value().toInt(), manId, objKey.value().toString());
                    }
                }
                else
                    emit response_error((int)CloudManager::ReponseError::Error_VerificationFailed);
            }
            else
                emit response_error((int)CloudManager::ReponseError::Error_VerificationFailed);
        }
        else
            emit response_error((int)CloudManager::ReponseError::Error_VerificationFailed);
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

bool CloudManager::isKeyValid(QString key)
{
    QString tmp = "";
    int i = 0;
    QString id = manId;

    while (tmp.length() < AppDef::APP_KEY_LENGTH)
    {
        tmp += QString(QCryptographicHash::hash(id.toLocal8Bit(), QCryptographicHash::Md5).toHex());
        id += QString::number(i);
        i += AppDef::APP_KEY_SEED;
    }

    qDebug() << "CALC = " << tmp;

    return (tmp == key);
}
