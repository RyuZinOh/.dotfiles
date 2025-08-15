#include <QApplication>
#include <QCryptographicHash>
#include <QWidget>
#include <QScrollArea>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QImage>
#include <QProcess>
#include <QLabel>
#include <QHBoxLayout>
#include <QMouseEvent>
#include <QScreen>

class ClickableLabel : public QLabel {
    Q_OBJECT
public:
    explicit ClickableLabel(const QString &path, QWidget *parent = nullptr) : QLabel(parent), imagePath(path) {
        setCursor(Qt::PointingHandCursor);
        setStyleSheet("ClickableLabel { border: 2px solid transparent; border-radius: 4px; }"
                      "ClickableLabel:hover { border: 2px solid rgba(255,255,255,0.7); }");
    }
signals:
    void clicked(const QString &path);
protected:
    void mousePressEvent(QMouseEvent *event) override {
        if (event->button() == Qt::LeftButton)
            emit clicked(imagePath);
    }
private:
    QString imagePath;
};

class Swifty : public QWidget {
    Q_OBJECT
public:
    Swifty(QWidget *parent = nullptr) : QWidget(parent) {
        setFixedSize(1890, 200);
        setStyleSheet("background-color: rgba(0, 0, 0, 0.85); border-radius: 8px;");
        setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
        setAttribute(Qt::WA_TranslucentBackground);
        
        scrollArea = new QScrollArea(this);
        scrollArea->setGeometry(0, 0, width(), height());
        scrollArea->setWidgetResizable(true);
        scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        scrollArea->setStyleSheet("background: transparent; border: none;");
        
        containerWidget = new QWidget();
        containerWidget->setStyleSheet("background: transparent;");
        hLayout = new QHBoxLayout(containerWidget);
        hLayout->setSpacing(8);
        hLayout->setContentsMargins(5, 1, 5, 1);
        scrollArea->setWidget(containerWidget);

        loadWallpapers();
    }

protected:
    void showEvent(QShowEvent *) override {
        QScreen *screen = QGuiApplication::primaryScreen();
        if (!screen) return;
        move((screen->geometry().width() - width()) / 2,
             screen->geometry().height() - height() - 5);
    }

private:
    QScrollArea *scrollArea;
    QWidget *containerWidget;
    QHBoxLayout *hLayout;

    void loadWallpapers() {
        QDir dir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
        QStringList filters = {"*.jpg", "*.jpeg", "*.png", "*.gif"};
        QFileInfoList files = dir.entryInfoList(filters, QDir::Files);

        QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/swifty";
        QDir().mkpath(cachePath);

        for (const QFileInfo &file : files) {
            QString imagePath = file.absoluteFilePath();
            QByteArray hash = QCryptographicHash::hash(imagePath.toUtf8(), QCryptographicHash::Sha1).toHex();
            QString thumbPath = cachePath + "/" + hash + ".jpg";

            QPixmap thumbnail;
            if (QFile::exists(thumbPath)) {
                thumbnail.load(thumbPath);
            } else {
                QImage img(imagePath);
                if (img.isNull()) continue;
                int h = 180;
                int w = img.width() * h / img.height();
                QImage thumb = img.scaled(w, h, Qt::KeepAspectRatio, Qt::SmoothTransformation);
                thumb.save(thumbPath);
                thumbnail = QPixmap::fromImage(thumb);
            }

            if (thumbnail.isNull()) continue;

            ClickableLabel *label = new ClickableLabel(imagePath);
            label->setPixmap(thumbnail);
            label->setFixedSize(thumbnail.size());
            connect(label, &ClickableLabel::clicked, this, &Swifty::applyWallpaper);
            hLayout->addWidget(label);
        }
    }

private slots:
    void applyWallpaper(const QString &path) {
        QProcess::execute("swww", {"img", path, "--transition-type", "wipe", "--transition-duration", "1", "--transition-fps", "60"});
    }
};

#include "main.moc"

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    Swifty w;
    w.show();
    return app.exec();
}
