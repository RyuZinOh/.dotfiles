#pragma once
#include <QWidget>
#include <QHBoxLayout>
#include <QList>
#include "../clickablelabel/clickablelabel.h"
#include "../kineticscrollarea/kineticscrollarea.h"

class Swifty : public QWidget {
    Q_OBJECT
public:
    Swifty(QWidget *parent = nullptr);
protected:
    void showEvent(QShowEvent *) override;
private:
    KineticScrollArea *scrollArea;
    QWidget *containerWidget;
    QHBoxLayout *hLayout;
    QList<ClickableLabel *> labels;
    void loadWallpapers();
private slots:
    void applyWallpaper(const QString &path);
};
