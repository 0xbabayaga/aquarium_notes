#include "imagegallery.h"
#include <QDir>
#include <QFileInfo>
#include <QDirIterator>
#include <QStandardPaths>
#include <QDebug>

#ifdef Q_OS_WIN
const static QStringList folderToSearch = { QStandardPaths::standardLocations(QStandardPaths::PicturesLocation) };
#else
const static QStringList folderToSearch = { "/storage/emulated/0/DCIM", "/storage/sdcard/DCIM" };
#endif


ImageGallery::ImageGallery()
{
    int count = 0;
    QFile *tmp = nullptr;

    galleryList.clear();

    tmp = new QFile("/storage/emulated/0/DCIM/1.jpg");

    if (tmp->open(QIODevice::OpenModeFlag::ReadOnly) == true)
    {
        qDebug() << "Opened ";
        tmp->close();
    }
    else
        qDebug() << "Cannot open " << tmp->fileName() << " error= " << tmp->errorString();


    for (int i = 0; i < folderToSearch.size(); i++)
    {
        qDebug() << folderToSearch.at(i) << " exist = " << QDir(folderToSearch.at(i)).exists();

        QDirIterator it(folderToSearch.at(i), QStringList() << "*.jpg", QDir::Files, QDirIterator::Subdirectories);

        qDebug() << "Looking in :" << folderToSearch.at(i);

        while (it.hasNext())
        {
            ImgObj *img = new ImgObj(it.next());
            galleryList.append(img);

            qDebug() << img->fileLink();

            count++;

            if (count > 2)
                break;
        }

        qDebug() << "Count = " << count;
    }
}

ImageGallery::~ImageGallery()
{

}
