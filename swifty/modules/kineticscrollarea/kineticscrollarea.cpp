#include "kineticscrollarea.h"
#include <QScrollBar>
#include <QtMath>

KineticScrollArea::KineticScrollArea(QWidget *parent)
    : QScrollArea(parent),
      momentumTimer(new QTimer(this)),
      scalingTimer(new QTimer(this))
{
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setWidgetResizable(true);

    momentumTimer->setInterval(16);
    connect(momentumTimer, &QTimer::timeout, this, &KineticScrollArea::handleMomentum);

    scalingTimer->setInterval(16);
    connect(scalingTimer, &QTimer::timeout, this, &KineticScrollArea::updateLabelScaling);
    scalingTimer->start();
}

void KineticScrollArea::setLabels(const QList<ClickableLabel *> &newLabels) {
    labels = newLabels;
}

void KineticScrollArea::mousePressEvent(QMouseEvent *event) {
    momentumTimer->stop();
    velocity = 0;
    lastPos = event->pos();
    lastTime.restart();
    QScrollArea::mousePressEvent(event);
}

void KineticScrollArea::mouseMoveEvent(QMouseEvent *event) {
    int deltaX = lastPos.x() - event->pos().x();
    horizontalScrollBar()->setValue(horizontalScrollBar()->value() + deltaX);

    qint64 elapsed = lastTime.elapsed();
    if (elapsed > 0) {
        double instantVelocity = deltaX * 1000.0 / elapsed;
        velocity = velocity * 0.6 + instantVelocity * 0.4;
    }

    lastPos = event->pos();
    lastTime.restart();
    QScrollArea::mouseMoveEvent(event);
}

void KineticScrollArea::mouseReleaseEvent(QMouseEvent *event) {
    if (!qFuzzyIsNull(velocity)) {
        momentumTimer->start();
    }
    QScrollArea::mouseReleaseEvent(event);
}

void KineticScrollArea::handleMomentum() {
    velocity *= 0.90;
    if (qAbs(velocity) < 0.05) {
        momentumTimer->stop();
        return;
    }

    double newValue = horizontalScrollBar()->value() + velocity * 0.016;
    horizontalScrollBar()->setValue(qRound(newValue));
}

void KineticScrollArea::updateLabelScaling() {
    if (labels.isEmpty()) return;

    int viewportCenterX = viewport()->width() / 2 + horizontalScrollBar()->value();

    for (auto label : labels) {
        int labelCenterX = label->x() + label->width() / 2;
        double distance = qAbs(labelCenterX - viewportCenterX);
        double t = qMin(distance / 400.0, 1.0);
        double targetScale = 1.0 - 0.3 * qPow(t, 2); 

        QPixmap pixmap = label->pixmap(Qt::ReturnByValue);
        double currentScale = label->width() / double(pixmap.width());
        double newScale = currentScale + (targetScale - currentScale) * 0.2;

        label->setFixedSize(pixmap.size() * newScale);
    }
}
