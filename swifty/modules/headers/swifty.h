#pragma once
#include "clickablelabel.h"
#include "kineticscrollarea.h"
#include <QHBoxLayout>
#include <QList>
#include <QWidget>

#ifdef Q_OS_LINUX
#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#endif

/*
displaying clicklabel widgets inside kineticscrollarea, and selection and apply
while scrolling
*/
class Swifty : public QWidget {
  Q_OBJECT
public:
  explicit Swifty(QWidget *parent = nullptr);

protected:
  void showEvent(QShowEvent *event) override;
  void keyPressEvent(QKeyEvent *event) override;

private:
  KineticScrollArea *scrollArea;  // scrollable area
  QWidget *containerWidget;       // inner container for label
  QHBoxLayout *hLayout;           // horizontal layout system
  QList<ClickableLabel *> labels; // list of wallpaper labels
  void loadWallpapers();
  void cleanupCache();
  QString swiftyCachePath() const;
private slots:
  void applyWallpaper(const QString &path); //[declaration]applying the
                                            //wallpaper based on the stuff
};
