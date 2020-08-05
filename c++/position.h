#ifndef POSITION_H
#define POSITION_H

#include <QNetworkAccessManager>

class Position : public QObject
{
    Q_OBJECT

public:
    Position();
    ~Position();

public:
    QString  userRegion()       {   return region;  }
    QString  userCountry()      {   return country; }
    QString  userCity()         {   return city;    }

signals:
    void positionDetected();

private slots:
    void onRequestCompleted(QNetworkReply *reply);

private:
    QNetworkAccessManager *man = nullptr;
    QString region = "";
    QString city = "";
    QString country = "";
};

#endif // POSITION_H
