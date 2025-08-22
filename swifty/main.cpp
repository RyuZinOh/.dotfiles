#include <QApplication>
#include "modules/swifty/swifty.h"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    Swifty w;
    w.show();
    return app.exec();
}
