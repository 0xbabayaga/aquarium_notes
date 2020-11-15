#include "filemanager.h"

FileManager::FileManager(QString dir)
{
    workingDirectory = dir;
}

FileManager::~FileManager()
{

}

bool FileManager::scanDirectory(QString fileExt)
{
    QDir scanDir(workingDirectory);
    QStringList imgList = scanDir.entryList(QStringList() << fileExt << fileExt.toUpper(), QDir::Files);

    fileList.clear();

    qDebug() << "Working dir " << workingDirectory;

    for (int i = 0; i < imgList.size(); i++)
    {
        FileObj *obj = new FileObj(imgList.at(i), workingDirectory + "/" + imgList.at(i), 0, 0);

        qDebug() << "added " << imgList.at(i);

        fileList.append(obj);
    }

    return true;
}
