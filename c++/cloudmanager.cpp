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

    connect(man, SIGNAL(finished(QNetworkReply*)), this, SLOT(onReplyReceived(QNetworkReply*)));
    connect(tmt, &QTimer::timeout, this, &CloudManager::onTimeout);
}

CloudManager::~CloudManager()
{
    if (man != 0)
        delete man;
}

void CloudManager::request_getAppUpdates()
{
    //man->get(QNetworkRequest(QUrl(CLOUD_SERVICE_VER_URL)));
    //tmt->start();
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
                         "\"uname\": \"" + user->uname + "\","
                         "\"email\": \"" + user->email + "\","
                         "\"upass\": \"" + user->upass + "\","
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

    qDebug() << "REQUEST: " << jsonString;

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
    QByteArray rsp;

    tmt->stop();

    //qDebug() << "REPLY RECEIVED";

    if (reply->error() == QNetworkReply::NetworkError::NoError)
    {
        rsp = reply->readAll();

        QJsonParseError error;
        QJsonDocument jsonDoc = QJsonDocument::fromJson(QString(rsp).toUtf8(), &error);
        QJsonObject obj = jsonDoc.object();

        if (error.error != QJsonParseError::NoError)
        {
            qDebug() << "";
            qDebug() << rsp;
            qDebug().noquote() << "JSON ERROR = " << error.errorString() << "on char" << error.offset;
        }

        if (obj["method"].isNull() == false)
        {
            if (obj["method"].toString() == "register")
            {
                if (obj["manid"].isNull() == false &&
                    obj["result"].isNull() == false &&
                    obj["key"].isNull() == false &&
                    obj["errortext"].isNull() == false)
                {
                    if (obj["result"].toInt() == CloudManager::ReponseError::NoError)
                    {
                        if (obj["manid"].toString() == manId &&
                            isKeyValid(obj["key"].toString()) == true)
                        {
                            emit response_registerApp(obj["result"].toInt(), obj["errortext"].toString(), manId, obj["key"].toString());
                        }
                        else
                            emit response_registerApp(CloudManager::ReponseError::Error_VerificationFailed, "", "", "");
                    }
                    else
                        emit response_registerApp(obj["result"].toInt(), obj["errortext"].toString(), "", "");
                }
                else
                    emit response_registerApp(CloudManager::ReponseError::Error_ProtocolError, "", "", "");
            }
            else if (obj["method"].toString() == "version")
            {
                if (obj["version"].isNull() == false &&
                    obj["releasedate"].isNull() == false)
                {
                    emit response_appUpdates(obj["version"].toInt(), obj["releasedate"].toInt());
                }
            }
            else
                emit response_registerApp(CloudManager::ReponseError::Error_ProtocolError, "", "", "");
        }
        else
            emit response_registerApp(CloudManager::ReponseError::Error_ProtocolError, "", "", "");
    }
    else
    {
        qDebug() << "REPLY ERROR = " << reply->errorString();
        emit response_registerApp(CloudManager::ReponseError::Error_CommunicationError, "", "", "");
    }


    //reply->deleteLater();
}

void CloudManager::onTimeout()
{
    tmt->stop();
    emit response_error((int)CloudManager::ReponseError::Error_Timeout, "");
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

    return (tmp == key);
}
