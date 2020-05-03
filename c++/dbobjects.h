#ifndef DBOBJECTS_H
#define DBOBJECTS_H
#include <QObject>
#include <QString>
#include <QSql>
#include <QSqlDatabase>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QVariant>

class LastDataParamRecObj : public QObject
{
    Q_OBJECT

    Q_PROPERTY(char paramId READ paramId WRITE setParamId NOTIFY paramIdChanged)
    Q_PROPERTY(int smpIdNow READ smpIdNow WRITE setSmpIdNow NOTIFY smpIdNowChanged)
    Q_PROPERTY(int smpIdPrev READ smpIdPrev WRITE setSmpIdPrev NOTIFY smpIdPrevChanged)
    Q_PROPERTY(float valueNow READ valueNow WRITE setValueNow NOTIFY valueNowChanged)
    Q_PROPERTY(float valuePrev READ valuePrev WRITE setValuePrev NOTIFY valuePrevChanged)

public:
    LastDataParamRecObj(char paramId, int idNow, int idPrev, float now, float prev)
    {
        _paramId = paramId;
        _smpIdNow = idNow;
        _smpIdPrev = idPrev;
        _valueNow = now;
        _valuePrev = prev;
    }

    char paramId()                      {   return _paramId;        }
    int smpIdNow()                      {   return _smpIdNow;       }
    int smpIdPrev()                     {   return _smpIdPrev;      }
    float valueNow()                    {   return _valueNow;       }
    float valuePrev()                   {   return _valuePrev;      }

    void setParamId(char paramId)       {   _paramId = paramId;     }
    void setSmpIdNow(int smpIdNow)      {   _smpIdNow = smpIdNow;   }
    void setSmpIdPrev(int smpIdPrev)    {   _smpIdPrev = smpIdPrev; }
    void setValueNow(float valueNow)    {   _valueNow = valueNow;   }
    void setValuePrev(float valuePrev)  {   _valuePrev = valuePrev; }

signals:
    void paramIdChanged();
    void smpIdNowChanged();
    void smpIdPrevChanged();
    void valueNowChanged();
    void valuePrevChanged();

protected:
    char    _paramId;
    int     _smpIdNow;
    int     _smpIdPrev;
    float   _valueNow;
    float   _valuePrev;
};

class ParamObj : public QObject
{
    Q_OBJECT

    Q_PROPERTY(char paramId READ paramId WRITE setParamId NOTIFY paramIdChanged)
    Q_PROPERTY(QString shortName READ shortName WRITE setShortName NOTIFY shortNameChanged)
    Q_PROPERTY(QString fullName READ fullName WRITE setFullName NOTIFY fullNameChanged)
    Q_PROPERTY(QString unitName READ unitName WRITE setUnitName NOTIFY unitNameChanged)
    Q_PROPERTY(float value READ value WRITE setValue NOTIFY valueChanged)

public:
    ParamObj(QSqlQuery *query)
    {
        if (query != nullptr)
        {
            _paramId = (char) query->value(query->record().indexOf("PARAM_ID")).toInt();
            _shortName = query->value(query->record().indexOf("SHORT_NAME")).toString();
            _fullName = query->value(query->record().indexOf("FULL_NAME")).toString();
            _unitName = query->value(query->record().indexOf("UNIT_NAME")).toString();
            _value = -1;
        }
    }

    char paramId()                  {   return _paramId;        }
    QString shortName()             {   return _shortName;      }
    QString fullName()              {   return _fullName;       }
    QString unitName()              {   return _unitName;       }
    float value()                   {   return _value;          }

    void setParamId(char paramId)   {   _paramId = paramId;     }
    void setShortName(QString name) {   _shortName = name;      }
    void setFullName(QString name)  {   _fullName = name;       }
    void setUnitName(QString name)  {   _unitName = name;       }
    void setValue(float value)      {   _value = value;         }

signals:
    void paramIdChanged();
    void shortNameChanged();
    void fullNameChanged();
    void unitNameChanged();
    void valueChanged();

protected:
    char    _paramId;
    QString _shortName;
    QString _fullName;
    QString _unitName;
    float   _value;
};

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
