#include <QApplication>
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
        setFixedSize(1890, 250);
        setStyleSheet("background-color: black;");
        scrollArea = new QScrollArea(this);
        scrollArea->setGeometry(0, 0, width(), height());
        scrollArea->setWidgetResizable(true);
        scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        containerWidget = new QWidget();
        hLayout = new QHBoxLayout(containerWidget);
        hLayout->setSpacing(10);
        scrollArea->setWidget(containerWidget);

        loadWallpapers();
    }

protected:
    void showEvent(QShowEvent *) override {
        QScreen *screen = QGuiApplication::primaryScreen();
        if (!screen) return;
        move((screen->geometry().width() - width()) / 2,
             screen->geometry().height() - height() - 20);
    }

private:
    QScrollArea *scrollArea;
    QWidget *containerWidget;
    QHBoxLayout *hLayout;

    void loadWallpapers() {
        QDir dir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
        QStringList filters = {"*.jpg", "*.jpeg", "*.png", "*.gif"};
        QFileInfoList files = dir.entryInfoList(filters, QDir::Files);

        for (const QFileInfo &file : files) {
            QImage img(file.absoluteFilePath());
            if (img.isNull()) continue;

            int h = 200;
            int w = img.width() * h / img.height();

            ClickableLabel *label = new ClickableLabel(file.absoluteFilePath());
            label->setPixmap(QPixmap::fromImage(img.scaled(w, h, Qt::KeepAspectRatio, Qt::SmoothTransformation)));
            label->setFixedSize(w, h);
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
