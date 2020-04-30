#ifndef DBOBJECTS_H
#define DBOBJECTS_H
#include <QObject>
#include <QString>
#include <QSql>
#include <QSqlDatabase>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QVariant>

class UserObj
{
public:
    UserObj()   {}
    UserObj(QSqlQuery *query)
    {
        if (query != nullptr)
        {
            man_id = query->value(query->record().indexOf("MAN_ID")).toString();
            uname = query->value(query->record().indexOf("UNAME")).toString();
            email = query->value(query->record().indexOf("EMAIL")).toString();
            phone = query->value(query->record().indexOf("PHONE")).toString();
            avatar_img = query->value(query->record().indexOf("AVATAR_IMG")).toString();
            status = query->value(query->record().indexOf("STATUS")).toInt();
            selected = query->value(query->record().indexOf("SELECTED")).toInt();
            date_create = query->value(query->record().indexOf("DATE_CREATE")).toInt();
            date_edit = query->value(query->record().indexOf("DATE_EDIT")).toInt();
        }
    }

    ~UserObj() {}

    QString     man_id = "";
    QString     uname = "";
    QString     email = "";
    QString     phone = "";
    QString     avatar_img = "";
    int         status = 0;
    int         selected = 0;
    int         date_create = 0;
    int         date_edit = 0;
};

class TankObj : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString tankId READ tankId WRITE setTankId NOTIFY tankIdChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString desc READ desc WRITE setDesc NOTIFY descChanged)
    Q_PROPERTY(float volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int type READ type WRITE setType NOTIFY typeChanged)

public:
    TankObj(QSqlQuery *query)
    {
        if (query != nullptr)
        {
            _tank_id = query->value(query->record().indexOf("TANK_ID")).toString();
            _man_id = query->value(query->record().indexOf("MAN_ID")).toString();
            _type = query->value(query->record().indexOf("TYPE")).toInt();
            _name = query->value(query->record().indexOf("NAME")).toString();
            _desc = query->value(query->record().indexOf("DESC")).toString();
            _img = query->value(query->record().indexOf("IMG")).toString();
            _status = query->value(query->record().indexOf("STATUS")).toInt();
            _l = query->value(query->record().indexOf("L")).toFloat();
            _w = query->value(query->record().indexOf("W")).toFloat();
            _h = query->value(query->record().indexOf("H")).toFloat();
            _date_create = query->value(query->record().indexOf("DATE_CREATE")).toInt();
            _date_edit = query->value(query->record().indexOf("DATE_EDIT")).toInt();
        }
    }

public:
    float   tankVolume()    {   return (_l * _w * _h) / 1000; }

public:
    QString tankId()                {   return _tank_id;        }
    QString name()                  {   return _name;           }
    QString desc()                  {   return _desc;           }
    float volume()                  {   return tankVolume();    }
    int type()                      {   return _type;           }

    void setTankId(QString tankId)  {   _tank_id = tankId;      }
    void setName(QString name)      {   _name = name;           }
    void setDesc(QString desc)      {   _desc = desc;           }
    void setVolume(float vol)       {   _l = _w;                }
    void setType(int type)          {   _type = type;           }

signals:
    void tankIdChanged();
    void nameChanged();
    void descChanged();
    void volumeChanged();
    void typeChanged();

protected:
    QString     _tank_id;
    QString     _man_id;
    int         _type;
    QString     _name;
    QString     _desc;
    QString     _img;
    int         _status;
    float       _l;
    float       _w;
    float       _h;
    int         _date_create;
    int         _date_edit;
};

#endif // DBOBJECTS_H
