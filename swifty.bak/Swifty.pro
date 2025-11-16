QT += core gui widgets

CONFIG += c++20 thread console
CONFIG -= app_bundle

TARGET = swifty
TEMPLATE = app

INCLUDEPATH += modules modules/headers

SOURCES += main.cpp \
           modules/swifty.cpp

HEADERS += modules/headers/clickablelabel.h \
           modules/headers/kineticscrollarea.h \
           modules/headers/swifty.h


# support layer-shell-qt
unix:!mac {
    LIBS += -lLayerShellQtInterface
    INCLUDEPATH += /usr/include/LayerShellQt
    DEFINES += HAVE_LAYERSHELL
}
