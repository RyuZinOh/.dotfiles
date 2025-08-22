#include "kineticscrollarea.h"
#include <QScrollBar>
#include <QtMath>

KineticScrollArea::KineticScrollArea(QWidget *parent) : QScrollArea(parent) {
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setWidgetResizable(true);
    momentumTimer = new QTimer(this);
    momentumTimer->setInterval(16);
    connect(momentumTimer, &QTimer::timeout, this, &KineticScrollArea::onMomentum);
    updateTimer = new QTimer(this);
    updateTimer->setInterval(16);
    connect(updateTimer, &QTimer::timeout, this, &KineticScrollArea::updateScaling);
    updateTimer->start();
}

void KineticScrollArea::setLabels(const QList<ClickableLabel *> &l) { labels = l; }

void KineticScrollArea::mousePressEvent(QMouseEvent *event) {
    momentumTimer->stop();
    velocity = 0;
    lastPos = event->pos();
    lastTime.restart();
    QScrollArea::mousePressEvent(event);
}

void KineticScrollArea::mouseMoveEvent(QMouseEvent *event) {
    int dx = lastPos.x() - event->pos().x();
    horizontalScrollBar()->setValue(horizontalScrollBar()->value() + dx);
    qint64 dt = lastTime.elapsed();
    if (dt > 0)
        velocity = dx * 1000.0 / dt;
    lastPos = event->pos();
    lastTime.restart();
    QScrollArea::mouseMoveEvent(event);
}

void KineticScrollArea::mouseReleaseEvent(QMouseEvent *event) {
    if (qAbs(velocity) > 0)
        momentumTimer->start();
    QScrollArea::mouseReleaseEvent(event);
}

void KineticScrollArea::onMomentum() {
    velocity *= 0.92;
    if (qAbs(velocity) < 0.1) {
        momentumTimer->stop();
        return;
    }
    qreal val = horizontalScrollBar()->value();
    val += velocity * 0.016;
    horizontalScrollBar()->setValue(qRound(val));
}

void KineticScrollArea::updateScaling() {
    if (labels.isEmpty()) return;
    int centerX = viewport()->width()/2 + horizontalScrollBar()->value();
    for (auto label : labels) {
        int labelCenter = label->x() + label->width()/2;
        double dist = qAbs(labelCenter - centerX);
        double targetScale = 1.0 - qMin(dist/400.0, 0.3);
        QPixmap pm = label->pixmap(Qt::ReturnByValue);
        double currentScale = label->width() / double(pm.width());
        double scale = currentScale + (targetScale - currentScale) * 0.2;
        label->setFixedSize(pm.size() * scale);
    }
}
