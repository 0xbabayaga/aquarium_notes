#include "position.h"
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

Position::Position() : QObject()
{
    man = new QNetworkAccessManager(this);

    connect(man, SIGNAL(finished(QNetworkReply*)), this, SLOT(onRequestCompleted(QNetworkReply*)));
}

Position::~Position()
{
    disconnect(man, SIGNAL(finished(QNetworkReply*)), this, SLOT(onRequestCompleted(QNetworkReply*)));

    if (man != nullptr)
        delete man;
}

void Position::get()
{
    man->get(QNetworkRequest(QUrl("http://api.ipstack.com/82.209.218.136?access_key=7a3d6bf8f1566937d361f358c11b3367")));
}

void Position::onRequestCompleted(QNetworkReply *reply)
{
    QJsonDocument jdoc;
    QJsonObject json;
    QJsonParseError jsonError;
    QString jsonResponse;
    int start = -1;
    int end = -1;

    if (reply->error() == QNetworkReply::NetworkError::NoError)
    {
        jsonResponse = QString(reply->readAll());

        start = jsonResponse.indexOf(QString("country_flag_emoji"), 0);
        end = jsonResponse.indexOf(QString("calling_code"), 0);

        if (start != -1 && end != -1 && end > start)
            jsonResponse.remove(start, end - start);

        jdoc = QJsonDocument::fromJson(jsonResponse.toUtf8(), &jsonError);

        if (jsonError.error != QJsonParseError::NoError)
            qDebug() << "ERROR " << jsonError.errorString();

        json = jdoc.object();

        region = json["continent_name"].toString();
        country = json["country_name"].toString();
        city = json["city"].toString();
        c_lat = json["latitude"].toDouble();
        c_long = json["longitude"].toDouble();

        emit positionDetected();
    }
}
