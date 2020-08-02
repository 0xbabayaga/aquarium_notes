QT += qml
QT += quick
QT += sql
QT += core
QT += multimedia
android: QT += androidextras

CONFIG += c++11

TARGET = AquariumNotes
TEMPLATE = app

SOURCES += \
        c++/actionlist.cpp \
        c++/appmanager.cpp \
        c++/dbmanager.cpp \
        main.cpp

RESOURCES += qml.qrc

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

CONFIG += mobility
MOBILITY =

DISTFILES += \
    android/AndroidManifest.xml \
#    android/build.gradle \
#    android/gradle/wrapper/gradle-wrapper.jar \
#    android/gradle/wrapper/gradle-wrapper.properties \
#    android/gradlew \
#    android/gradlew.bat \
#    android/res/values/libs.xml \
    android/src/org/tikava/AquariumNotes/AquariumNotes.java
    qml/qmldir \

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

HEADERS += \
    c++/AppDefs.h \
    c++/actionlist.h \
    c++/appmanager.h \
    c++/dbmanager.h \
    c++/dbobjects.h \
    c++/galleryobjects.h

#contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
#    ANDROID_PACKAGE_SOURCE_DIR = \
#        $$PWD/android
#}

TRANSLATIONS += \
    resources/langs/lang_en.ts \
    resources/langs/lang_ru.ts \
    resources/langs/lang_be.ts
