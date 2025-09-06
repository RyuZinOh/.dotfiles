#include <QDebug>
#include <QApplication>
#include <QWidget>
#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QSvgWidget>
#include <QMouseEvent>
#include <QProcess>
#include <QDir>
#include <QTimer>
#include <QGraphicsOpacityEffect>
#include <QCursor>
#include <QLabel>
#include <QPainter>

class BlurWindow : public QWidget {
public:
    BlurWindow(QWidget *parent = nullptr) : QWidget(parent) {
        setAttribute(Qt::WA_TranslucentBackground);
        setWindowFlags(Qt::FramelessWindowHint);
    }

protected:
    void paintEvent(QPaintEvent *event) override {
        QPainter painter(this);
        painter.setRenderHint(QPainter::Antialiasing);
        
        painter.fillRect(rect(), QColor(0, 0, 0, 180));
        
        QWidget::paintEvent(event);
    }
};

class ClickableSvg : public QSvgWidget {
    Q_OBJECT
public:
    explicit ClickableSvg(const QString &file, QLabel *label, QWidget *parent=nullptr) 
        : QSvgWidget(file, parent), m_label(label) {
        setFixedSize(120, 120);
        if(!QFile::exists(file))
            qWarning() << "SVG not found:" << file;
        setCursor(Qt::PointingHandCursor);
        
        if (m_label) {
            m_label->hide();
            m_label->setStyleSheet("color: white; font-size: 16px; font-weight: 500; background: transparent;");
        }
    }

signals:
    void clicked();

protected:
    void mousePressEvent(QMouseEvent *event) override {
        if(event->button() == Qt::LeftButton) {
            QGraphicsOpacityEffect *effect = new QGraphicsOpacityEffect;
            effect->setOpacity(0.5);
            setGraphicsEffect(effect);
            
            QTimer::singleShot(100, this, [this]() {
                setGraphicsEffect(nullptr);
                emit clicked();
            });
        }
    }

    void enterEvent(QEvent *event) override {
        if (m_label) {
            m_label->show();
        }
        QWidget::enterEvent(event);
    }

    void leaveEvent(QEvent *event) override {
        if (m_label) {
            m_label->hide();
        }
        QWidget::leaveEvent(event);
    }

private:
    QLabel *m_label;
};

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    BlurWindow window;
    window.setWindowTitle("Power Menu");
    window.setFixedSize(600, 250);

    QHBoxLayout *mainLayout = new QHBoxLayout(&window);
    mainLayout->setSpacing(80);
    mainLayout->setContentsMargins(100, 30, 100, 30);

    QString iconPath = QDir::homePath() + "/.cache/powerski/icons/";
    QString shutdownSvg = iconPath + "shutdown.svg";
    QString restartSvg  = iconPath + "restart.svg";

    QLabel *shutdownLabel = new QLabel("Shutdown");
    shutdownLabel->setStyleSheet("color: white; font-size: 16px; font-weight: 500; background: transparent;");
    shutdownLabel->setAlignment(Qt::AlignCenter);
    
    QLabel *restartLabel = new QLabel("Restart");
    restartLabel->setStyleSheet("color: white; font-size: 16px; font-weight: 500; background: transparent;");
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

    QObject::connect(shutdownIcon, &ClickableSvg::clicked, [&](){
        QProcess::startDetached("systemctl", {"poweroff"});
    });

    QObject::connect(restartIcon, &ClickableSvg::clicked, [&](){
        QProcess::startDetached("systemctl", {"reboot"});
    });

    window.show();
    return app.exec();
}

#include "main.moc"
