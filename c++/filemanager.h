#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QObject>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QDateTime>
#include <QDebug>
#include <QList>
#include "dbobjects.h"

class FileManager : public QObject
{
    Q_OBJECT

public:
    FileManager(QString dir);
    ~FileManager();

    QList<QObject*> getFileList() { return fileList; }
    bool scanDirectory(QString fileExt);

protected:
    QString         workingDirectory;
    QList<QObject*> fileList;
};

#endif // FILEMANAGER_H
