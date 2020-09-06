#ifndef JNIMANAGER_H
#define JNIMANAGER_H
#include <QObject>

#include <QObject>

class JNIManager : public QObject
{
    Q_OBJECT

public:
    explicit    JNIManager(QObject *parent = nullptr);
    static      JNIManager *instance() { return _instance; }

signals:
    void messageFromJava(const QString &message);

public slots:

private:
    static JNIManager *_instance;
};


#endif // JNIMANAGER_H
