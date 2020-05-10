#ifndef IMAGEGALLERY_H
#define IMAGEGALLERY_H
#include <QObject>
#include <QList>
#include "galleryobjects.h"

class ImageGallery : public QObject
{
    Q_OBJECT
public:
    ImageGallery();
    ~ImageGallery();

    QList<QObject*> getGalleryObjList() {   return galleryList;    }

private:
    QList<QObject*> galleryList;
};

#endif // IMAGEGALLERY_H
