#include "position.h"
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

const QString tmp = "{\
                    \"ip\":\"82.209.218.136\",\
                    \"type\":\"ipv4\",\
                    \"continent_code\":\"EU\",\
                    \"continent_name\":\"Europe\",\
                    \"country_code\":\"BY\",\
                    \"country_name\":\"Belarus\",\
                    \"region_code\":\"HM\",\
                    \"region_name\":\"Minsk City\",\
                    \"city\":\"Minsk\",\
                    \"zip\":\"200400\",\
                    \"latitude\":53.900001525878906,\
                    \"longitude\":27.566699981689453,\
                    \"location\":{\
                      \"geoname_id\":625144,\
                      \"capital\":\"Minsk\",\
                      \"languages\":[\
                        {\
                          \"code\":\"be\",\
                          \"name\":\"Belarusian\",\
                          \"native\":\"\u0411\u0435\u043b\u0430\u0440\u0443\u0441\u043a\u0430\u044f\"\
                        },\
                        {\
                          \"code\":\"ru\",\
                          \"name\":\"Russian\",\
                          \"native\":\"\u0420\u0443\u0441\u0441\u043a\u0438\u0439\"\
                        }\
                      ],\
                      \"country_flag\":\"http:\/\/assets.ipstack.com\/flags\/by.svg\",\
                      \"country_flag_emoji_unicode\":\"U+1F1E7 U+1F1FE\",\
                      \"calling_code\":\"375\",\
                      \"is_eu\":false\
                    }\
                  }";

Position::Position() : QObject()
{
    man = new QNetworkAccessManager(this);

    connect(man, SIGNAL(finished(QNetworkReply*)), this, SLOT(onRequestCompleted(QNetworkReply*)));

    man->get(QNetworkRequest(QUrl("http://api.ipstack.com/82.209.218.136?access_key=7a3d6bf8f1566937d361f358c11b3367")));
}

Position::~Position()
{
    disconnect(man, SIGNAL(finished(QNetworkReply*)), this, SLOT(onRequestCompleted(QNetworkReply*)));

    if (man != nullptr)
        delete man;
}

void Position::onRequestCompleted(QNetworkReply *reply)
{
    QJsonDocument jdoc;
    QJsonObject json;
    QJsonParseError jsonError;
    QString jsonResponse;
    int start = -1;
    int end = -1;

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

    emit positionDetected();
}
