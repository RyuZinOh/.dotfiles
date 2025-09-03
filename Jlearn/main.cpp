#include <QApplication>
#include <QDir>
#include <QWidget>
#include <QGridLayout>
#include <QLabel>
#include <QFile>
#include <QStringList>
#include <QFont>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QPushButton>
#include <QStackedWidget>
#include <QScrollArea>
#include <QScreen>
#include <QGuiApplication>
#include <QGraphicsBlurEffect>

struct Character {
    QString kanji;
    QString meaning;
};

QList<Character> loadCharacters(const QString &filename) {
    QList<Character> list;
    QFile file(filename);
    if (!file.exists()) return list;
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        while (!file.atEnd()) {
            QString line = file.readLine().trimmed();
            if (!line.isEmpty()) {
                QStringList parts = line.split('=');
                Character c;
                c.kanji = parts[0];
                c.meaning = parts.size() > 1 ? parts[1] : "";
                list.append(c);
            }
        }
        file.close();
    }
    return list;
}

class ModernTabBar : public QWidget {
    Q_OBJECT
public:
    ModernTabBar(QWidget *parent=nullptr) : QWidget(parent) {
        QHBoxLayout *layout = new QHBoxLayout(this);
        layout->setSpacing(0);
        layout->setContentsMargins(20,10,20,10);
        QStringList tabNames = {"Hiragana","Katakana","Kanji"};
        for(const QString &name : tabNames){
            QPushButton *btn=new QPushButton(name);
            btn->setCheckable(true);
            btn->setCursor(Qt::PointingHandCursor);
            btn->setStyleSheet(
                "QPushButton { background: transparent; color: #aaaaaa; border: none; padding: 12px 20px; font-weight: 600; font-size: 14px; }"
                "QPushButton:checked { color: #ffffff; }"
            );
            connect(btn,&QPushButton::clicked,this,[this,btn](){ 
                for(auto b:m_tabs)b->setChecked(false);
                btn->setChecked(true);
                emit tabChanged(m_tabs.key(btn));
            });
            m_tabs[name]=btn;
            layout->addWidget(btn);
        }
        layout->addStretch();
        m_tabs["Hiragana"]->setChecked(true);
    }
signals:
    void tabChanged(const QString &tabName);
private:
    QMap<QString,QPushButton*> m_tabs;
};

class BlurredBackground : public QWidget {
public:
    BlurredBackground(QWidget* parent=nullptr) : QWidget(parent) {
        setStyleSheet("background-color: rgba(0,0,0,180);"); // removed border-radius
        QGraphicsBlurEffect* blur = new QGraphicsBlurEffect(this);
        blur->setBlurRadius(15);
        setGraphicsEffect(blur);
    }
protected:
    void resizeEvent(QResizeEvent *event) override {
        QWidget::resizeEvent(event);
        setGeometry(0,0,parentWidget()->width(), parentWidget()->height());
    }
};

int main(int argc,char *argv[]){
    QApplication app(argc,argv);

    QString cacheDir = QDir::homePath() + "/.cache/Jlearn";
    QMap<QString,QList<Character>> characters;
    characters["Hiragana"] = loadCharacters(cacheDir + "/hiragana.txt");
    characters["Katakana"] = loadCharacters(cacheDir + "/katakana.txt");
    characters["Kanji"] = loadCharacters(cacheDir + "/kanji.txt");

    QWidget window;
    window.setWindowFlags(Qt::Window | Qt::FramelessWindowHint);
    window.setAttribute(Qt::WA_TranslucentBackground);

    BlurredBackground* background = new BlurredBackground(&window);
    background->lower();

    QVBoxLayout *mainLayout=new QVBoxLayout(&window);
    mainLayout->setContentsMargins(20,20,20,20);
    mainLayout->setSpacing(10);

    ModernTabBar *tabBar=new ModernTabBar;
    mainLayout->addWidget(tabBar);

    QStackedWidget *stackedWidget=new QStackedWidget;

    int columns=5;
    QFont kanjiFont("Noto Sans CJK JP",38,QFont::Bold);
    QFont meaningFont("Arial",11,QFont::Normal);

    for (const QString &tabName : {QString("Hiragana"), QString("Katakana"), QString("Kanji")}) {
        QWidget *gridWidget = new QWidget;
        gridWidget->setStyleSheet("background-color: rgba(0,0,0,0);");
        QGridLayout *grid = new QGridLayout(gridWidget);
        grid->setSpacing(16);
        grid->setContentsMargins(0,0,0,0);

        const auto &list = characters[tabName];
        for (int i = 0; i < list.size(); ++i) {
            QWidget *cell = new QWidget;
            QVBoxLayout *vbox = new QVBoxLayout(cell);
            vbox->setContentsMargins(0,0,0,0);
            vbox->setSpacing(4);

            QLabel *kanjiLabel = new QLabel(list[i].kanji);
            kanjiLabel->setFont(kanjiFont);
            kanjiLabel->setAlignment(Qt::AlignCenter);
            kanjiLabel->setStyleSheet("color:#ffffff;");

            QLabel *meaningLabel = new QLabel(list[i].meaning);
            meaningLabel->setFont(meaningFont);
            meaningLabel->setAlignment(Qt::AlignCenter);
            meaningLabel->setStyleSheet("color:#bbbbbb;");

            vbox->addWidget(kanjiLabel);
            vbox->addWidget(meaningLabel);

            grid->addWidget(cell, i / columns, i % columns, Qt::AlignCenter);
        }

        QScrollArea *scrollArea = new QScrollArea;
        scrollArea->setWidgetResizable(true);
        scrollArea->setWidget(gridWidget);
        scrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
        scrollArea->setStyleSheet("QScrollArea { border: none; background-color: rgba(0,0,0,0); }");

        stackedWidget->addWidget(scrollArea);
    }

    mainLayout->addWidget(stackedWidget);

    QObject::connect(tabBar,&ModernTabBar::tabChanged,[&](const QString &tabName){
        if(tabName=="Hiragana") stackedWidget->setCurrentIndex(0);
        else if(tabName=="Katakana") stackedWidget->setCurrentIndex(1);
        else if(tabName=="Kanji") stackedWidget->setCurrentIndex(2);
    });

    window.resize(900,700);
    QScreen *screen=QGuiApplication::primaryScreen();
    QRect screenGeometry=screen->geometry();
    window.move((screenGeometry.width()-window.width())/2,(screenGeometry.height()-window.height())/2);

    window.show();
    return app.exec();
}

#include "main.moc"



