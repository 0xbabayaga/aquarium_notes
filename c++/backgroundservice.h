#ifndef BACKGROUNDSERVICE_H
#define BACKGROUNDSERVICE_H

#include <QObject>
#include <QTimer>

class BackgroundService : public QObject
{
    Q_OBJECT

public:
    explicit BackgroundService(QObject *parent = nullptr);
    ~BackgroundService();

private slots:
    void onTimeout();

private:
    QTimer *tmr = nullptr;
    int     cnt = 0;
};

#endif // BACKGROUNDSERVICE_H
