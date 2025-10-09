#pragma once
#include <QLabel>
#include <QMouseEvent>

class ClickableLabel : public QLabel {
  Q_OBJECT
public:
  explicit ClickableLabel(const QString &path, QWidget *parent = nullptr);
signals:
  void clicked(const QString &path);

protected:
  void mousePressEvent(QMouseEvent *event) override;

private:
  QString imagePath;
};
