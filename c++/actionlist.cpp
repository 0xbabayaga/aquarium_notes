#include "actionlist.h"
#include <QDateTime>
#include <QDebug>

ActionList::ActionList()
{
    list.clear();
    currView = ActionView_ThisWeek;
}

ActionList::~ActionList()
{
    list.clear();
}

bool ActionList::setData(QSqlQuery *query, eActionListView viewType)
{
    bool res = false;
    int startDate = 0;
    int repeatPeriod = 0;
    int viewPeriod = 0;
    QDateTime tmNow = QDateTime::currentDateTime();
    ActionObj *obj = nullptr;

    list.clear();

    switch(viewType)
    {
        case ActionView_ThisWeek:   viewPeriod = 86400 * 7; break;
        case ActionView_ThisMonth:  viewPeriod = 86400 * 30; break;
        case ActionView_Today:
        default:                    viewPeriod = 86400;     break;
    }

    while (query->next())
    {
        repeatPeriod = query->value(query->record().indexOf("PERIOD")).toInt();
        startDate = query->value(query->record().indexOf("STARTDATE")).toInt();

        qDebug() << "Valid dates" << startDate << startDate + viewPeriod;



        if (startDate > tmNow.toSecsSinceEpoch() &&
            startDate <= tmNow.toSecsSinceEpoch() + viewPeriod )
        {
            obj = new ActionObj(query->value(query->record().indexOf("ID")).toInt(),
                                query->value(query->record().indexOf("TYPE")).toInt(),
                                query->value(query->record().indexOf("PERIOD")).toInt(),
                                query->value(query->record().indexOf("STARTDATE")).toInt(),
                                query->value(query->record().indexOf("EN")).toBool(),
                                query->value(query->record().indexOf("NAME")).toString(),
                                query->value(query->record().indexOf("DESC")).toString());

            list.append(obj);

            qDebug() << "Added : " << obj->actId() << obj->name() << obj->startDT() << tmNow.toSecsSinceEpoch();
        }
    }

    res = true;

    return res;
}
