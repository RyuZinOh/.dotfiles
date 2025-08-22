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
    setWindowFlags(Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
    scrollArea = new KineticScrollArea(this);
    scrollArea->setGeometry(0, 0, width(), height());
    scrollArea->setStyleSheet("background: black; border: none;");
    containerWidget = new QWidget();
    containerWidget->setStyleSheet("background: black;");
    hLayout = new QHBoxLayout(containerWidget);
    hLayout->setSpacing(8);
    hLayout->setContentsMargins(5, 1, 5, 1);
    scrollArea->setWidget(containerWidget);
    loadWallpapers();
    scrollArea->setLabels(labels);
}

void Swifty::showEvent(QShowEvent *) {
    QScreen *screen = QGuiApplication::primaryScreen();
    if (!screen) return;
    move((screen->geometry().width() - width()) / 2,
         screen->geometry().height() - height() - 5);
}

void Swifty::loadWallpapers() {
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
    QStringList filters = {"*.jpg","*.jpeg","*.png","*.gif"};
    QFileInfoList files = dir.entryInfoList(filters, QDir::Files);
    QDir cacheDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    cacheDir.mkpath("swifty");
    QString cachePath = cacheDir.filePath("swifty");

    for (const QFileInfo &file : files) {
        QString imagePath = file.absoluteFilePath();
        QString wallpaperName = file.completeBaseName();
        QByteArray hash = QCryptographicHash::hash(imagePath.toUtf8(), QCryptographicHash::Sha1).toHex();
        QString thumbPath = cachePath + "/" + hash + ".jpg";
        QPixmap thumbnail;
        if (QFile::exists(thumbPath))
            thumbnail.load(thumbPath);
        else {
            QImage img(imagePath);
            if (img.isNull()) continue;
            int h=180,w=img.width()*h/img.height();
            QImage thumb = img.scaled(w,h,Qt::KeepAspectRatio,Qt::SmoothTransformation);
            thumb.save(thumbPath);
            thumbnail = QPixmap::fromImage(thumb);
        }
        if (thumbnail.isNull()) continue;
        ClickableLabel *label = new ClickableLabel(imagePath);
        label->setPixmap(thumbnail);
        label->setFixedSize(thumbnail.size());
        connect(label,&ClickableLabel::clicked,this,&Swifty::applyWallpaper);
        hLayout->addWidget(label);
        labels.append(label);
    }
}

void Swifty::applyWallpaper(const QString &path) {
    QString wallpaperName = QFileInfo(path).completeBaseName();
    QString notifyCmd = QString("hyprctl notify -1 3000 \"rgb(003366)\" \"fontsize:20 %1 Applied!\"").arg(wallpaperName);
    QProcess::execute("sh", {"-c", notifyCmd});
    QProcess::execute("swww", {"img", path, "--transition-type","wipe","--transition-duration","1","--transition-fps","60"});
}
