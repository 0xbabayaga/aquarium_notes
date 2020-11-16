#include <QObject>
#include <QCryptographicHash>
#include <QDateTime>
#include <QThread>
#include <QDebug>
#include "dbmanager.h"

QString generateKey(quint64 tm, unsigned int crc)
{
    QString tmp = QString::number(crc, 16) + QString::number(tm);

    return QString(QCryptographicHash::hash(tmp.toLocal8Bit(), QCryptographicHash::Md5).toHex());
}

bool exportToFile(QString name)
{
    ArchiveTable *table = nullptr;
    QFile exportFile(name);
    QFile tmpFile;
    unsigned int cnt = 0;
    unsigned int read = 0;
    unsigned int offset = 0;
    unsigned int tmpSize = 0;
    unsigned int i = 0;
    char *tmpBuf = nullptr;
    unsigned int crc = 0;
    QString key = "";
    bool res = false;
    QString imgFolder = DBManager::getAppFolder() + "/" + DBManager::getImgFolder();

    table = new ArchiveTable();
    memset(table, 0, sizeof (ArchiveTable));

    tmpBuf = (char*) malloc(MAX_EXPORT_FILE_READBUF_SIZE);

    if (table != nullptr && tmpBuf != nullptr)
    {
        if (exportFile.open(QIODevice::WriteOnly) == true)
        {
            QDir expImgDir(imgFolder);
            QStringList imgList = expImgDir.entryList(QStringList() << "*.jpg" << "*.JPG" << "*.jpeg" << "*.JPEG", QDir::Files);

            exportFile.seek(sizeof(ArchiveTable));
            offset = sizeof(ArchiveTable);

            tmpSize = 0;
            table->dbFile.offset = offset;
            tmpFile.setFileName(DBManager::getDbFilePath());

            if (tmpFile.open(QIODevice::ReadOnly) == true)
            {
                do
                {
                    read = tmpFile.read(tmpBuf, MAX_EXPORT_FILE_READBUF_SIZE);

                    if (read > 0)
                    {
                        exportFile.write(tmpBuf, read);
                        tmpSize += read;

                        for (i = 0; i < read; i++)
                            crc += tmpBuf[i];
                    }
                }
                while (read != 0);

                tmpFile.close();

                qDebug() << "CRC = " << QString::number(crc, 16);

                table->dbFile.size = tmpSize;
                strcpy(table->dbFile.name, DBManager::getDbFile().toLocal8Bit());
                offset += tmpSize;

                foreach(QString imgFileName, imgList)
                {
                    tmpFile.setFileName(imgFolder + "/" + imgFileName);
                    table->imgFiles[cnt].offset = offset;
                    tmpSize = 0;

                    qDebug() << "Image found " << imgFolder + "/" + imgFileName;

                    QThread::msleep(20);

                    if (tmpFile.open(QIODevice::ReadOnly) == true)
                    {
                        do
                        {
                            read = tmpFile.read(tmpBuf, MAX_EXPORT_FILE_READBUF_SIZE);

                            if (read > 0)
                            {
                                exportFile.write(tmpBuf, read);
                                tmpSize += read;

                                for (i = 0; i < read; i++)
                                    crc += tmpBuf[i];
                            }
                        }
                        while (read != 0);

                        tmpFile.close();
                    }

                    qDebug() << "CRC = " << QString::number(crc, 16) << "tmpSize = " << tmpSize;

                    table->imgFiles[cnt].size = tmpSize;
                    strcpy(table->imgFiles[cnt].name, imgFileName.toLocal8Bit());
                    offset += tmpSize;
                    cnt++;
                }

                table->timestamp = QDateTime::currentSecsSinceEpoch();
                key = generateKey(table->timestamp, crc);
                strcpy(table->md5, key.toLocal8Bit());

                qDebug() << "TM = " << QString::number(table->timestamp, 16);
                qDebug() << "FINAL CRC = " << QString::number(crc, 16) << " key = " << key;

                exportFile.seek(0);
                exportFile.write((char*)table, sizeof(ArchiveTable));

                res = true;
            }

            exportFile.close();
        }

        free(tmpBuf);
        delete table;
    }

    return res;
}

bool importFromFile(QString name)
{
    ArchiveTable *table = nullptr;
    QFile importFile(name);
    QFile tmpFile;
    unsigned int cnt = 0;
    unsigned int read = 0;
    unsigned int tmpSize = 0;
    unsigned int sz = 0;
    unsigned int i = 0;
    char *tmpBuf = nullptr;
    unsigned int crc = 0;
    QString key = "";
    bool res = false;
    QDir rm;
    QString imgWorkDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + DBManager::getImgFolder();
    QString dbWorkDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + DBManager::getDbFolder();
    QString imgTmpDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/_" + DBManager::getImgFolder();
    QString dbTmpDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/_" + DBManager::getDbFolder();
    QString imgBackupDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + DBManager::getImgFolder() + "_backup";
    QString dbBackupDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + DBManager::getDbFolder() + "_backup";

    rm.setPath(imgBackupDir);
    qDebug() << "Remove " << imgBackupDir << "res = " << rm.removeRecursively();

    rm.setPath(dbBackupDir);
    qDebug() << "Remove " << dbBackupDir << "res = " << rm.removeRecursively();

    rm.setPath(imgTmpDir);
    qDebug() << "Remove " << imgTmpDir << "res = " << rm.removeRecursively();
    QDir().mkdir(imgTmpDir);

    rm.setPath(dbTmpDir);
    qDebug() << "Remove " << dbTmpDir << "res = " << rm.removeRecursively();
    QDir().mkdir(dbTmpDir);

    table = new ArchiveTable();
    memset(table, 0, sizeof (ArchiveTable));

    tmpBuf = (char*) malloc(MAX_EXPORT_FILE_READBUF_SIZE);

    if (table != nullptr && tmpBuf != nullptr)
    {
        if (importFile.open(QIODevice::ReadOnly) == true)
        {
            if (importFile.read((char*)table, sizeof(ArchiveTable)) == sizeof(ArchiveTable))
            {
                tmpFile.setFileName(dbTmpDir + "/" + table->dbFile.name);
                importFile.seek(table->dbFile.offset);
                sz = table->dbFile.size;

                qDebug() << "sz = " << sz;

                if (sz > MAX_DB_FILESIZE)
                {
                    qDebug() << "Import: DB's size is oversized " << sz;
                }
                else
                {
                    if (tmpFile.open(QIODevice::WriteOnly) == true)
                    {
                        do
                        {
                            if (sz > MAX_EXPORT_FILE_READBUF_SIZE)
                                read = importFile.read(tmpBuf, MAX_EXPORT_FILE_READBUF_SIZE);
                            else
                                read = importFile.read(tmpBuf, sz);

                            if (read > 0)
                            {
                                sz -= read;
                                tmpFile.write(tmpBuf, read);
                                tmpSize += read;

                                for (i = 0; i < read; i++)
                                    crc += tmpBuf[i];
                            }
                        }
                        while (sz != 0 && read > 0);

                        tmpFile.close();
                    }
                }

                qDebug() << "CRC = " << QString::number(crc, 16) << "tmpSize = " << tmpSize;

                if (tmpSize == table->dbFile.size)
                {
                    while(table->imgFiles[cnt].size != 0)
                    {
                        tmpSize = 0;
                        tmpFile.setFileName(imgTmpDir + "/" + table->imgFiles[cnt].name);
                        importFile.seek(table->imgFiles[cnt].offset);
                        sz = table->imgFiles[cnt].size;

                        if (sz > MAX_IMG_FILESIZE)
                        {
                            qDebug() << "Import: image's size is oversized " << sz;
                            break;
                        }

                        qDebug() << "Import IMG: " << table->imgFiles[cnt].name << table->imgFiles[cnt].size << "bytes";

                        if (tmpFile.open(QIODevice::WriteOnly) == true)
                        {
                            do
                            {
                                if (sz > MAX_EXPORT_FILE_READBUF_SIZE)
                                    read = importFile.read(tmpBuf, MAX_EXPORT_FILE_READBUF_SIZE);
                                else
                                    read = importFile.read(tmpBuf, sz);

                                if (read > 0)
                                {
                                    sz -= read;
                                    tmpFile.write(tmpBuf, read);
                                    tmpSize += read;

                                    for (i = 0; i < read; i++)
                                        crc += tmpBuf[i];
                                }
                            }
                            while (sz != 0 && read > 0);

                            tmpFile.close();

                            qDebug() << "CRC = " << QString::number(crc, 16) << "tmpSize = " << tmpSize;

                            if (tmpSize != table->imgFiles[cnt].size)
                            {
                                qDebug() << "Import: Wrong IMG size";
                                res = false;
                                break;
                            }
                            else
                                res = true;
                        }
                        else
                        {
                            qDebug() << "Import: Cannot open file to save";
                            res = false;
                            break;
                        }

                        cnt++;
                    }

                    key = generateKey(table->timestamp, crc);

                    qDebug() << "TM = " << QString::number(table->timestamp, 16);
                    qDebug() << "CRC = " << QString::number(crc, 16) << " key = " << key;

                    //if (strcmp(table->md5, key.toLocal8Bit()) != 0)
//                    {
//                        qDebug() << "Wrong md5 summ";
//                        res = false;
//                    }
                }
                else
                    qDebug() << "Import: Wrong DB size";
            }
            else
                qDebug() << "Import: Wrong header";

            importFile.close();
        }

        delete tmpBuf;
        delete table;
    }

    if (res == true)
    {
        QDir().rename(dbWorkDir, dbBackupDir);
        QDir().rename(imgWorkDir, imgBackupDir);
        QDir().rename(dbTmpDir, dbWorkDir);
        QDir().rename(imgTmpDir, imgWorkDir);

        qDebug() << "Import: DONE!";
    }
    else
    {
        QDir().rmdir(dbTmpDir);
        QDir().rmdir(imgTmpDir);

        qDebug() << "Import: FAILED!";
    }

    return res;
}
