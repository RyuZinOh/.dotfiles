QT += core gui widgets

CONFIG += c++17 thread console
CONFIG -= app_bundle

TARGET = swifty
TEMPLATE = app

INCLUDEPATH += modules

SOURCES += main.cpp \
           modules/clickablelabel/clickablelabel.cpp \
           modules/kineticscrollarea/kineticscrollarea.cpp \
           modules/swifty/swifty.cpp

HEADERS += modules/clickablelabel/clickablelabel.h \
           modules/kineticscrollarea/kineticscrollarea.h \
           modules/swifty/swifty.h
