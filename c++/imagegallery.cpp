#include "imagegallery.h"
#include <QDir>
#include <QFileInfo>
#include <QDirIterator>
#include <QStandardPaths>
#include <QDebug>

#ifndef Q_OS_ANDROID
const static QStringList folderToSearch = { QStandardPaths::standardLocations(QStandardPaths::PicturesLocation) };
#else
const static QStringList folderToSearch = { "/storage/emulated/0/DCIM", "/storage/sdcard/DCIM" };
#endif


ImageGallery::ImageGallery()
{
    int count = 0;
    ImgObj *img = nullptr;

    galleryList.clear();


    for (int i = 0; i < folderToSearch.size(); i++)
    {
        QDirIterator it(folderToSearch.at(i), QStringList() << "*.jpg", QDir::Files, QDirIterator::NoIteratorFlags);

        qDebug() << "Looking in :" << folderToSearch.at(i);

        img = new ImgObj("");
        galleryList.append(img);

        while (it.hasNext())
        {
            img = new ImgObj(it.next());
            galleryList.append(img);

            qDebug() << img->fileLink();

            count++;

            if (count > 2)
                break;
        }
    }
}

ImageGallery::~ImageGallery()
{

}
