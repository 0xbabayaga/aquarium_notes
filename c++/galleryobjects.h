#ifndef GALLERYOBJECTS_H
#define GALLERYOBJECTS_H
#include <QObject>

class ImgObj : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString fileLink READ fileLink WRITE setFileLink NOTIFY fileLinkChanged)

public:
    ImgObj(QString link)
    {
        _fileLink = link;
    }

public:
    QString fileLink()              {   return _fileLink;       }

    void setFileLink(QString link)  {   _fileLink = link;       }

signals:
    void fileLinkChanged();

protected:
    QString _fileLink;
};


#endif // GALLERYOBJECTS_H
