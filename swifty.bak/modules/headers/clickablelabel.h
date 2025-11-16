#pragma once
#include <QLabel>
#include <QMouseEvent>

/*
clicklabel class for emitting a signal when clicked
*/
class ClickableLabel : public QLabel {
  Q_OBJECT

  // constructor -> making it accessible outside the class
public:
  explicit ClickableLabel(
      const QString &path,
      QWidget *parent = nullptr); // creates a instance [storing]

  // signaling
signals:
  void clicked(const QString &path);

protected:
  void mousePressEvent(QMouseEvent *event) override; // emitter

private:
  QString imagePath; // storing the file path
};
