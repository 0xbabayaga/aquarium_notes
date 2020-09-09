#include "backgroundservice.h"
#include "androidnotification.h"

BackgroundService::BackgroundService(QObject *parent) : QObject(parent)
{
    tmr = new QTimer();
    tmr->stop();
    tmr->setInterval(5000);
    tmr->setSingleShot(false);

    connect(tmr, SIGNAL(timeout()), this, SLOT(onTimeout()));

    tmr->start();
}

BackgroundService::~BackgroundService()
{
    if (tmr != nullptr)
        delete tmr;
}

void BackgroundService::onTimeout()
{
    AndroidNotification *notify = new AndroidNotification();
    notify->setNotification("Bacground service #" + QString::number(cnt++));
    notify->updateAndroidNotification();
}
