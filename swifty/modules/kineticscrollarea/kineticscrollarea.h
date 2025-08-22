#pragma once
#include <QScrollArea>
#include <QTimer>
#include <QElapsedTimer>
#include <QPoint>
#include "../clickablelabel/clickablelabel.h"

class KineticScrollArea : public QScrollArea {
    Q_OBJECT
public:
    explicit KineticScrollArea(QWidget *parent = nullptr);
    void setLabels(const QList<ClickableLabel *> &l);
protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
private slots:
    void onMomentum();
    void updateScaling();
private:
    QPoint lastPos;
    QElapsedTimer lastTime;
    QTimer *momentumTimer;
    QTimer *updateTimer;
    double velocity = 0;
    QList<ClickableLabel *> labels;
};
