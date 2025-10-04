#include "swifty.h"
#include <QStandardPaths>
#include <QGuiApplication>
#include <QDir>
#include <QFileInfo>
#include <QCryptographicHash>
#include <QImage>
#include <QPixmap>
#include <QProcess>
#include <QScreen>

Swifty::Swifty(QWidget *parent) : QWidget(parent) {
    setFixedSize(1575, 200);
    setStyleSheet("background-color: black; border-radius: 8px;");
    setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint | Qt::Tool);

    scrollArea = new KineticScrollArea(this);
    scrollArea->setGeometry(rect());
    scrollArea->setStyleSheet("background: black; border: none;");

    containerWidget = new QWidget();
    containerWidget->setStyleSheet("background: black;");
    hLayout = new QHBoxLayout(containerWidget);
    hLayout->setSpacing(8);
    hLayout->setContentsMargins(5, 1, 5, 1);

    scrollArea->setWidget(containerWidget);

    cleanupCache();
    loadWallpapers();
    scrollArea->setLabels(labels);
}

void Swifty::showEvent(QShowEvent *) {
    if (QScreen *screen = QGuiApplication::primaryScreen()) {
        QRect geom = screen->geometry();
        move((geom.width() - width()) / 2,
             geom.height() - height() - 5);
    }
}

QString Swifty::swiftyCachePath() const {
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/swifty");
    dir.mkpath(".");
    return dir.absolutePath();
}

void Swifty::cleanupCache() {
    QDir cacheDir(swiftyCachePath());
    QStringList cacheFiles = cacheDir.entryList({"*.jpg"}, QDir::Files);

    QDir picturesDir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
    QStringList filters = {"*.jpg","*.jpeg","*.png","*.gif"};
    QFileInfoList files = picturesDir.entryInfoList(filters, QDir::Files);

    QSet<QString> validHashes;
    for (const QFileInfo &file : files)
        validHashes.insert(QString(QCryptographicHash::hash(file.absoluteFilePath().toUtf8(), QCryptographicHash::Sha1).toHex()));

    for (const QString &thumbFile : cacheFiles) {
        QString hashName = QFileInfo(thumbFile).completeBaseName();
        if (!validHashes.contains(hashName))
            QFile::remove(cacheDir.filePath(thumbFile));
    }
}

void Swifty::loadWallpapers() {
    QDir picturesDir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
    QStringList filters = {"*.jpg","*.jpeg","*.png","*.gif"};
    QFileInfoList files = picturesDir.entryInfoList(filters, QDir::Files);

    QString cachePath = swiftyCachePath();

    for (const QFileInfo &file : files) {
        QString path = file.absoluteFilePath();
        QByteArray hash = QCryptographicHash::hash(path.toUtf8(), QCryptographicHash::Sha1).toHex();
        QString thumbPath = cachePath + "/" + hash + ".jpg";

        QPixmap thumbnail;
        if (!QFile::exists(thumbPath)) {
            QImage img(path);
            if (img.isNull()) continue;
            int h = 180;
            int w = img.width() * h / img.height();
            img = img.scaled(w, h, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            img.save(thumbPath);
            thumbnail = QPixmap::fromImage(img);
        } else {
            thumbnail.load(thumbPath);
        }

        if (thumbnail.isNull()) continue;

        ClickableLabel *label = new ClickableLabel(path);
        label->setPixmap(thumbnail);
        label->setFixedSize(thumbnail.size());
        connect(label, &ClickableLabel::clicked, this, &Swifty::applyWallpaper);

        hLayout->addWidget(label);
        labels.append(label);
    }
}

void Swifty::applyWallpaper(const QString &path) {
    QString wallpaperName = QFileInfo(path).completeBaseName();

    QProcess::startDetached("notify-send", {wallpaperName + " Applied!"});
    QProcess::startDetached("swww", {"img", path, "--transition-type", "wipe", "--transition-duration", "1", "--transition-fps", "60"});

    QString hyprlockDir = "/home/safal726/.cache/hyprlock-safal";
    QDir dir(hyprlockDir);
    if (!dir.exists()) dir.mkpath(".");

    QString finalPath = hyprlockDir + "/bg.jpg";

    QImage img(path);
    if (!img.isNull()) img.save(finalPath, "JPG");
}
