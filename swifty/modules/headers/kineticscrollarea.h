#pragma once
#include "clickablelabel.h"
#include <QElapsedTimer>
#include <QList>
#include <QPoint>
#include <QScrollArea>
#include <QScrollBar>
#include <QTimer>
#include <cmath>

/*
momentum based moment kineticsrollarea class
*/
class KineticScrollArea : public QScrollArea {
  Q_OBJECT

  // public interface
public:
  explicit KineticScrollArea(QWidget *parent = nullptr); // scroll area
  void
  setLabels(const QList<ClickableLabel *> &labels); // list of widget to manage

protected:
  void mousePressEvent(QMouseEvent *event) override;   // drag initial
  void mouseMoveEvent(QMouseEvent *event) override;    // drag/movements
  void mouseReleaseEvent(QMouseEvent *event) override; // release and initial
private slots:
  void handleMomentum();     // repeately calling this
  void updateLabelScaling(); // scalling

private:
  QPoint lastPos;                 // last mouse position
  QElapsedTimer lastTime;         // timesbetween mouse event for velocity
  QTimer *momentumTimer{nullptr}; // timer for moment
  QTimer *scalingTimer{nullptr};  // timer for updation
  double velocity{0.0};           // velocity of scroll
  QList<ClickableLabel *> labels; // labels list
};
