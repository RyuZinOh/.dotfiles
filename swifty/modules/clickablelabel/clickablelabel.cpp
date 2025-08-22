#include "clickablelabel.h"

ClickableLabel::ClickableLabel(const QString &path, QWidget *parent)
    : QLabel(parent), imagePath(path) {
    setCursor(Qt::PointingHandCursor);
    setAlignment(Qt::AlignCenter);
}

void ClickableLabel::mousePressEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton)
        emit clicked(imagePath);
}
