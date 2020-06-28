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

void ActionList::setViewPeriod(eActionListView viewType)
{
    currView = (eActionListView) (viewType % (ActionView_ThisMonth + 1));
}

bool ActionList::setData(QSqlQuery *query)
{
    bool res = false;
    int viewStartDate = 0;
    int viewEndDate = 0;
    int repeatPeriod = 0;
    int period = 0;
    int startDate = 0;

    QDateTime tmNow = QDateTime::currentDateTime();
    ActionObj *obj = nullptr;

    list.clear();

    viewStartDate = tmNow.toSecsSinceEpoch();
    viewEndDate = viewStartDate;

    switch(currView)
    {
        case ActionView_ThisWeek:   viewEndDate += 86400 * 7; break;
        case ActionView_ThisMonth:  viewEndDate += 86400 * 30; break;
        case ActionView_Today:
        default:                    viewEndDate += 86400;     break;
    }

    while (query->next())
    {
        repeatPeriod = query->value(query->record().indexOf("TYPE")).toInt();
        period = query->value(query->record().indexOf("PERIOD")).toInt();
        startDate = query->value(query->record().indexOf("STARTDATE")).toInt();

        qDebug() << "Valid dates" << viewStartDate << viewEndDate;

        switch ((eActionRepeat) repeatPeriod)
        {
            case ActionRepeat_None:         repeatPeriod = 0;           break;
            case ActionRepeat_EveryWeek:    repeatPeriod = 86400 * 7 * period;   break;
            case ActionRepeat_EveryMonth:   repeatPeriod = 86400 * 30 * period;  break;
            case ActionRepeat_EveryDay:
            default:                        repeatPeriod = 86400 * period;       break;
        }

        if (repeatPeriod > 0)
        {
            while (startDate < viewEndDate)
            {
                if (startDate > viewStartDate && startDate <= viewEndDate)
                {
                    obj = new ActionObj(query->value(query->record().indexOf("ID")).toInt(),
                                        query->value(query->record().indexOf("TYPE")).toInt(),
                                        query->value(query->record().indexOf("PERIOD")).toInt(),
                                        startDate,
                                        query->value(query->record().indexOf("EN")).toBool(),
                                        query->value(query->record().indexOf("NAME")).toString(),
                                        query->value(query->record().indexOf("DESC")).toString());

                    list.append(obj);

                    qDebug() << "Added : " << obj->actId() << obj->name() << obj->type() << obj->startDT() << tmNow.toSecsSinceEpoch();
                }

                startDate += repeatPeriod;
            }
        }
        else
        {
            if (startDate > viewStartDate && startDate <= viewEndDate)
            {
                obj = new ActionObj(query->value(query->record().indexOf("ID")).toInt(),
                                    query->value(query->record().indexOf("TYPE")).toInt(),
                                    query->value(query->record().indexOf("PERIOD")).toInt(),
                                    startDate,
                                    query->value(query->record().indexOf("EN")).toBool(),
                                    query->value(query->record().indexOf("NAME")).toString(),
                                    query->value(query->record().indexOf("DESC")).toString());

                list.append(obj);

                qDebug() << "Added : " << obj->actId() << obj->name() << obj->type() << obj->startDT() << tmNow.toSecsSinceEpoch();
            }
        }
    }

    qSort(list.begin(), list.end(), less);

    res = true;

    return res;
}

bool ActionList::less(QObject *v1, QObject *v2)
{
    ActionObj *a1 = (ActionObj*) v1;
    ActionObj *a2 = (ActionObj*) v2;

    return a1->startDT() < a2->startDT();
}
