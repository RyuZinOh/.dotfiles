#include <QApplication>
#include <QDir>
#include <QEnterEvent>
#include <QGraphicsOpacityEffect>
#include <QHBoxLayout>
#include <QLabel>
#include <QMouseEvent>
#include <QPainter>
#include <QProcess>
#include <QSvgRenderer>
#include <QTimer>
#include <QVBoxLayout>
#include <QWidget>

class BlurWindow : public QWidget {
public:
  BlurWindow(QWidget *parent = nullptr) : QWidget(parent) {
    setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint |
                   Qt::Tool);
    setStyleSheet("background-color: black;");
    setFixedSize(600, 250);
  }

protected:
  void paintEvent(QPaintEvent *event) override {
    QPainter p(this);
    p.fillRect(rect(), QColor(0, 0, 0));
    QWidget::paintEvent(event);
  }
};

class ClickableSvg : public QLabel {
  Q_OBJECT
public:
  explicit ClickableSvg(const QString &file, QLabel *label,
                        QWidget *parent = nullptr)
      : QLabel(parent), m_label(label), renderer(new QSvgRenderer(file, this)) {
    setFixedSize(120, 120);
    setCursor(Qt::PointingHandCursor);
    if (m_label)
      m_label->hide();
  }
signals:
  void clicked();

protected:
  void paintEvent(QPaintEvent *) override {
    QPainter painter(this);
    renderer->render(&painter, rect());
  }
  void mousePressEvent(QMouseEvent *event) override {
    if (event->button() == Qt::LeftButton) {
      auto *effect = new QGraphicsOpacityEffect;
      effect->setOpacity(0.5);
      setGraphicsEffect(effect);
      QTimer::singleShot(100, this, [this] {
        setGraphicsEffect(nullptr);
        emit clicked();
      });
    }
  }
  void enterEvent(QEnterEvent *) override {
    if (m_label)
      m_label->show();
  }
  void leaveEvent(QEvent *) override {
    if (m_label)
      m_label->hide();
  }

private:
  QLabel *m_label;
  QSvgRenderer *renderer;
};

int main(int argc, char *argv[]) {
  QApplication app(argc, argv);

  BlurWindow window;
  window.setWindowTitle("Power Menu");

  QHBoxLayout *mainLayout = new QHBoxLayout(&window);
  mainLayout->setSpacing(80);
  mainLayout->setContentsMargins(100, 30, 100, 30);

  QString iconPath = QDir::homePath() + "/.cache/powerski/icons/";
  QString shutdownSvg = iconPath + "shutdown.svg";
  QString restartSvg = iconPath + "restart.svg";

  QLabel *shutdownLabel = new QLabel("Shutdown");
  shutdownLabel->setStyleSheet(
      "color: white; font-size: 16px; font-weight: 500;");
  shutdownLabel->setAlignment(Qt::AlignCenter);

  QLabel *restartLabel = new QLabel("Restart");
  restartLabel->setStyleSheet(
      "color: white; font-size: 16px; font-weight: 500;");
  restartLabel->setAlignment(Qt::AlignCenter);

  QVBoxLayout *shutdownLayout = new QVBoxLayout();
  shutdownLayout->setAlignment(Qt::AlignCenter);
  shutdownLayout->setSpacing(10);

  QVBoxLayout *restartLayout = new QVBoxLayout();
  restartLayout->setAlignment(Qt::AlignCenter);
  restartLayout->setSpacing(10);

  ClickableSvg *shutdownIcon = new ClickableSvg(shutdownSvg, shutdownLabel);
  ClickableSvg *restartIcon = new ClickableSvg(restartSvg, restartLabel);

  shutdownLayout->addWidget(shutdownIcon, 0, Qt::AlignCenter);
  shutdownLayout->addWidget(shutdownLabel, 0, Qt::AlignCenter);
  restartLayout->addWidget(restartIcon, 0, Qt::AlignCenter);
  restartLayout->addWidget(restartLabel, 0, Qt::AlignCenter);

  mainLayout->addLayout(shutdownLayout);
  mainLayout->addLayout(restartLayout);

  QObject::connect(shutdownIcon, &ClickableSvg::clicked,
                   [] { QProcess::startDetached("systemctl", {"poweroff"}); });
  QObject::connect(restartIcon, &ClickableSvg::clicked,
                   [] { QProcess::startDetached("systemctl", {"reboot"}); });

  window.show();
  return app.exec();
}

#include "main.moc"
