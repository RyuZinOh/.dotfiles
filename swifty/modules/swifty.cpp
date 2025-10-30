#include "headers/swifty.h"
#include "headers/kineticscrollarea.h"
#include <QCryptographicHash>
#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QImage>
#include <QPixmap>
#include <QProcess>
#include <QScreen>
#include <QStandardPaths>
#include <cmath>

ClickableLabel::ClickableLabel(const QString &path, QWidget *parent)
    : QLabel(parent), imagePath(path) {
  setCursor(Qt::PointingHandCursor);
  setAlignment(Qt::AlignCenter);
}
void Swifty::keyPressEvent(QKeyEvent *event) {
  if (event->key() == Qt::Key_Escape) {
    close();
  }
  QWidget::keyPressEvent(event);
}
void ClickableLabel::mousePressEvent(QMouseEvent *event) {
  if (event->button() == Qt::LeftButton)
    emit clicked(imagePath);
  QLabel::mousePressEvent(event);
}

KineticScrollArea::KineticScrollArea(QWidget *parent)
    : QScrollArea(parent), momentumTimer(new QTimer(this)),
      scalingTimer(new QTimer(this)) {

  // scroll area
  setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
  setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
  setWidgetResizable(true);

  // moment timer
  momentumTimer->setInterval(16);
  connect(momentumTimer, &QTimer::timeout, this,
          &KineticScrollArea::handleMomentum);
  // scaling timer
  scalingTimer->setInterval(16);
  connect(scalingTimer, &QTimer::timeout, this,
          &KineticScrollArea::updateLabelScaling);
  scalingTimer->start();
}

void KineticScrollArea::setLabels(const QList<ClickableLabel *> &newLabels) {
  labels = newLabels;
}

// mouse events
// start of drag
void KineticScrollArea::mousePressEvent(QMouseEvent *event) {
  momentumTimer->stop();
  velocity = 0;
  lastPos = event->pos();
  lastTime.restart();
  QScrollArea::mousePressEvent(event);
}

// drag handler
void KineticScrollArea::mouseMoveEvent(QMouseEvent *event) {
  int deltaX = lastPos.x() - event->pos().x();
  horizontalScrollBar()->setValue(horizontalScrollBar()->value() +
                                  deltaX); // this moves scrolling
  qint64 elapsed = lastTime.elapsed();
  if (elapsed > 0) {
    double instantVelocity = deltaX * 1000.0 / elapsed; // instantenous velocity
    velocity = velocity * 0.5 + instantVelocity * 0.5;  // smootheness addition
  }
  lastPos = event->pos();
  lastTime.restart(); // restart timer for next movement
  QScrollArea::mouseMoveEvent(event);
}

// end of drag
void KineticScrollArea::mouseReleaseEvent(QMouseEvent *event) {
  if (std::abs(velocity) > 0.01)
    momentumTimer->start();
  QScrollArea::mouseReleaseEvent(event);
}

// momentum scrollin
void KineticScrollArea::handleMomentum() {
  velocity *= 0.92;                // friction to slow down
  if (std::abs(velocity) < 0.05) { // stop at lowest
    momentumTimer->stop();
    velocity = 0;
    return;
  }
  double newValue = horizontalScrollBar()->value() + velocity * 0.016;
  horizontalScrollBar()->setValue(qRound(newValue)); // update bar
}

//[sexy -> labelling effect]
void KineticScrollArea::updateLabelScaling() {
  if (labels.isEmpty())
    return;
  double centerX = viewport()->width() / 2 +
                   horizontalScrollBar()->value(); // viewport center
  for (auto label : labels) {
    double labelCenter = label->x() + label->width() / 2;
    double distance = std::abs(labelCenter - centerX);
    double t = std::min(distance / 400.0, 1.0);
    double scaleTarget =
        1.0 - 0.5 * std::pow(t, 1.8); // decreasing with distance
    QPixmap pix = label->pixmap(Qt::ReturnByValue);
    if (pix.isNull())
      continue;
    double currentScale = label->width() / double(pix.width());
    double newScale =
        currentScale + (scaleTarget - currentScale) * 0.25; // smoothness
    label->setFixedSize(pix.size() * newScale);             // apply new scale
  }
}

// constructor
Swifty::Swifty(QWidget *parent) : QWidget(parent) {
  setFixedSize(1575, 200); // fixed size is configed here //
  setStyleSheet("background-color:black;");
  setWindowFlags(Qt::FramelessWindowHint);

  scrollArea = new KineticScrollArea(this);
  scrollArea->setGeometry(rect());
  scrollArea->setStyleSheet("background:black;border:none;");
  containerWidget = new QWidget();
  containerWidget->setStyleSheet("background:black;");
  hLayout = new QHBoxLayout(containerWidget);
  hLayout->setSpacing(8);
  hLayout->setContentsMargins(5, 1, 5, 1);
  scrollArea->setWidget(containerWidget);
  // clean up old cache thumbnails
  cleanupCache();
  loadWallpapers();
  // give access to the list of lablels for momentum
  scrollArea->setLabels(labels);
}

/* call it when widget shown [main man]
-  position and all determination for layershell the goat haha [was tring to
integrate in the previous stuffs]
*/
void Swifty::showEvent(QShowEvent *event) {
  static bool layerShellInitialized = false; // only one tie
  if (!layerShellInitialized) {
    auto window = windowHandle();
    if (window) {
      auto layerWindow = LayerShellQt::Window::get(window);
      if (layerWindow) {
        layerWindow->setLayer(LayerShellQt::Window::LayerTop);
        layerWindow->setAnchors(
            LayerShellQt::Window::AnchorBottom); // BOTTOM => U CAN MAKE IT TOP
                                                 // FOR AESTHETIC, BUT ME AM A
                                                 // BOTTOM FEEDER
        layerWindow->setExclusiveZone(-1);       // never overlapping
        layerWindow->setKeyboardInteractivity(
            LayerShellQt::Window::KeyboardInteractivityOnDemand); // this for
                                                                  // esc

        layerWindow->setMargins(
            {0, 0, 0, 50});           // positions on the screen [T,R,B,L]
        layerShellInitialized = true; // marking
      }
    }
  }

  QWidget::showEvent(event);
}

// caching
QString Swifty::swiftyCachePath() const {
  QDir dir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
           ""); // this is of on .config/[location]
  dir.mkpath(".");
  return dir.absolutePath();
}

// clean up system that is no longer corresponding to the current Pictures
void Swifty::cleanupCache() {
  QDir cacheDir(swiftyCachePath());
  QStringList cacheFiles = cacheDir.entryList({"*.jpg"}, QDir::Files);
  QDir picturesDir(
      QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
  QStringList filters = {"*.jpg", "*.jpeg", "*.png", "*.gif"};
  QFileInfoList files = picturesDir.entryInfoList(filters, QDir::Files);
  QSet<QString> validHashes;
  for (const QFileInfo &file : files)
    validHashes.insert(
        QString(QCryptographicHash::hash(file.absoluteFilePath().toUtf8(),
                                         QCryptographicHash::Sha1)
                    .toHex()));
  for (const QString &thumbFile : cacheFiles) {
    QString hashName = QFileInfo(thumbFile).completeBaseName();
    if (!validHashes.contains(hashName))
      QFile::remove(cacheDir.filePath(thumbFile));
  }
}

/*
loading wallpaper
- ssh hash for each file
- scaling it to 180h corresponding
- save thumbs in caches
- cickable widget connecting to the label to apply
*/
void Swifty::loadWallpapers() {
  QDir picturesDir(
      QStandardPaths::writableLocation(QStandardPaths::PicturesLocation));
  QStringList filters = {"*.jpg", "*.jpeg", "*.png", "*.gif"};
  QFileInfoList files = picturesDir.entryInfoList(filters, QDir::Files);
  QString cachePath = swiftyCachePath();
  for (const QFileInfo &file : files) {
    QString path = file.absoluteFilePath();
    QByteArray hash =
        QCryptographicHash::hash(path.toUtf8(), QCryptographicHash::Sha1)
            .toHex();
    QString thumbPath = cachePath + "/" + hash + ".jpg";
    QPixmap thumbnail;
    if (!QFile::exists(thumbPath)) {
      QImage img(path);
      if (img.isNull())
        continue;
      int h = 180; // 180px
      int w = img.width() * h / img.height();
      img = img.scaled(w, h, Qt::KeepAspectRatio, Qt::SmoothTransformation);
      img.save(thumbPath);
      thumbnail = QPixmap::fromImage(img);
    } else
      thumbnail.load(thumbPath);
    if (thumbnail.isNull())
      continue;
    ClickableLabel *label = new ClickableLabel(path);
    label->setPixmap(thumbnail);
    label->setFixedSize(thumbnail.size());
    connect(label, &ClickableLabel::clicked, this, &Swifty::applyWallpaper);
    hLayout->addWidget(label);
    labels.append(label);
  }
}

/*
applying wallpaper
- takes path as we have declared  earlier
[seperate process]
- gets wallname and sends libnotify for mako
- applies wallski according to the parameter
- integrates with the hyprlock [always the bg.jpg when overwriting]
*/
void Swifty::applyWallpaper(const QString &path) {
  QString wallpaperName = QFileInfo(path).completeBaseName();
  QProcess::startDetached("notify-send", {wallpaperName + " Applied!"});
  QProcess::startDetached("wallski", {"--set", path, "--transition", "ripple"});
  QString hyprlockDir = "/home/safal726/.cache/hyprlock-safal";
  QDir dir(hyprlockDir);
  if (!dir.exists())
    dir.mkpath(".");
  QString finalPath = hyprlockDir + "/bg.jpg";
  QImage img(path);
  if (!img.isNull())
    img.save(finalPath, "JPG");
}
