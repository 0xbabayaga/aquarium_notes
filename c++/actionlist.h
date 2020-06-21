#ifndef ACTIONLIST_H
#define ACTIONLIST_H

#include <QObject>
#include <QSqlQuery>
#include "dbobjects.h"

typedef enum
{
    ActionRepeat_None = 0,
    ActionRepeat_EveryDay = 1,
    ActionRepeat_EveryWeek = 2,
    ActionRepeat_EveryMonth = 3
}   eActionRepeat;

typedef enum
{
    ActionView_None = 0,
    ActionView_Today = 1,
    ActionView_ThisWeek = 2,
    ActionView_ThisMonth = 3
}   eActionListView;

class ActionList : public QObject
{
public:
    ActionList();
    ~ActionList();

public:
    void setViewPeriod(eActionListView viewType);
    bool setData(QSqlQuery *query);
    QList<QObject*> *getData()   {   return &list;   }

private:
    static bool less(QObject *v1, QObject *v2);

private:
    eActionListView currView;
    QList<QObject*>  list;
};

#endif // ACTIONLIST_H
