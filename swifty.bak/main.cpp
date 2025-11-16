#include "modules/headers/swifty.h"
#include <QApplication>

int main(int argc, char *argv[]) {
  QApplication app(argc, argv);
  Swifty w;
  w.show();
  return app.exec();
}
