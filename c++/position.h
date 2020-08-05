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
    double   coorLat()          {   return c_lat;   }
    double   coorLong()         {   return c_long;  }

    void    get();

signals:
    void positionDetected();

private slots:
    void onRequestCompleted(QNetworkReply *reply);

private:
    QNetworkAccessManager *man = nullptr;
    QString region = "";
    QString city = "";
    QString country = "";
    double c_lat = 0;
    double c_long = 0;
};

#endif // POSITION_H
