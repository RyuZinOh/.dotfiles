#pragma once
#include "clickablelabel.h"
#include <QElapsedTimer>
#include <QList>
#include <QPoint>
#include <QScrollArea>
#include <QScrollBar>
#include <QTimer>
#include <cmath>

class KineticScrollArea : public QScrollArea {
  Q_OBJECT
public:
  explicit KineticScrollArea(QWidget *parent = nullptr);
  void setLabels(const QList<ClickableLabel *> &labels);

protected:
  void mousePressEvent(QMouseEvent *event) override;
  void mouseMoveEvent(QMouseEvent *event) override;
  void mouseReleaseEvent(QMouseEvent *event) override;
private slots:
  void handleMomentum();
  void updateLabelScaling();

private:
  QPoint lastPos;
  QElapsedTimer lastTime;
  QTimer *momentumTimer{nullptr};
  QTimer *scalingTimer{nullptr};
  double velocity{0.0};
  QList<ClickableLabel *> labels;
};
