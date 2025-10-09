#pragma once
#include <QWidget>
#include <QHBoxLayout>
#include <QList>
#include "clickablelabel.h"
#include "kineticscrollarea.h"

class Swifty : public QWidget {
    Q_OBJECT
public:
    explicit Swifty(QWidget *parent = nullptr);
protected:
    void showEvent(QShowEvent *event) override;
private:
    KineticScrollArea *scrollArea;
    QWidget *containerWidget;
    QHBoxLayout *hLayout;
    QList<ClickableLabel *> labels;
    void loadWallpapers();
    void cleanupCache();
    QString swiftyCachePath() const;
private slots:
    void applyWallpaper(const QString &path);
};
