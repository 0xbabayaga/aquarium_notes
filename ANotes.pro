QT += qml
QT += quick
QT += sql
QT += core
QT += multimedia
android: QT += androidextras

CONFIG += c++11

version_p.commands = ..\Anotes\version_inc.bat
version_p.depends = FORCE
QMAKE_EXTRA_TARGETS += version_p
PRE_TARGETDEPS += version_p

TARGET = AquariumNotes
TEMPLATE = app

SOURCES += \
        c++/actionlist.cpp \
        c++/appmanager.cpp \
        c++/cloudmanager.cpp \
        c++/dbmanager.cpp \
        c++/position.cpp \
        main.cpp

android {
SOURCES += \
        c++/androidnotification.cpp \
        c++/backmanager.cpp
}

DEFINES += FULL_FEATURES_ENABLED

RESOURCES += qml.qrc

# Default rules for deployment.
#qnx: target.path = /tmp/$${TARGET}/bin
#else: unix:!android: target.path = /opt/$${TARGET}/bin
#!isEmpty(target.path): INSTALLS += target

CONFIG += mobility
MOBILITY =

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/src/org/tikava/AquariumNotes/AquariumNotes.java \
    android/src/org/tikava/AquariumNotes/AquariumNotesNotification.java \
    android/src/org/tikava/AquariumNotes/Background.java
    qml/qmldir \

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

HEADERS += \
    c++/AppDefs.h \
    c++/actionlist.h \
    c++/appmanager.h \
    c++/cloudmanager.h \
    c++/dbmanager.h \
    c++/dbobjects.h \
    c++/galleryobjects.h \
    c++/position.h \
    c++/version.h

android {
HEADERS += \
    c++/androidnotification.h \
    c++/backmanager.h \

ANDROID_EXTRA_LIBS = \
    $$PWD/../../../Dev/android_openssl-master/Qt-5.12.4_5.13.0/arm/libcrypto.so \
    $$PWD/../../../Dev/android_openssl-master/Qt-5.12.4_5.13.0/arm/libssl.so
    #$$PWD/../../../Dev/android_openssl-master/latest/arm/libcrypto_1_1.so \
    #$$PWD/../../../Dev/android_openssl-master/latest/arm/libssl_1_1.so
}

TRANSLATIONS += \
    resources/langs/lang_en.ts \
    resources/langs/lang_ru.ts \
    resources/langs/lang_be.ts

ANDROID_ABIS = armeabi-v7a


HEADERS += \
    c++/AppDefs.h \
    c++/actionlist.h \
    c++/appmanager.h \
    c++/cloudmanager.h \
    c++/dbmanager.h \
    c++/dbobjects.h \
    c++/galleryobjects.h \
    c++/position.h \
    c++/version.h

android {
HEADERS += \
    c++/androidnotification.h \
    c++/backmanager.h \

ANDROID_EXTRA_LIBS = \
    $$PWD/../../../Dev/android_openssl-master/Qt-5.12.4_5.13.0/arm/libcrypto.so \
    $$PWD/../../../Dev/android_openssl-master/Qt-5.12.4_5.13.0/arm/libssl.so
    #$$PWD/../../../Dev/android_openssl-master/latest/arm/libcrypto_1_1.so \
    #$$PWD/../../../Dev/android_openssl-master/latest/arm/libssl_1_1.so
}

TRANSLATIONS += \
    resources/langs/lang_en.ts \
    resources/langs/lang_ru.ts \
    resources/langs/lang_be.ts
