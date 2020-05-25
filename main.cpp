#include <QApplication>
#include <QQuickView>
#include <QQmlApplicationEngine>
#include "c++/dbmanager.h"
#include "c++/AppDefs.h"
#include <QDebug>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQuickView viewer;

    AppDef::declareQML();

    app.setOrganizationName("ANotes");
    app.setOrganizationDomain("org.anotes.com");
    app.setApplicationName("AquariumNotes");



#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                          QString::fromLatin1("qml")));
    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);

    viewer.setSource(url);
    //viewer.setResizeMode(QQuickView::SizeRootObjectToView);

    DBManager *dbMan = new DBManager(&viewer);

    viewer.show();

    return app.exec();
}
