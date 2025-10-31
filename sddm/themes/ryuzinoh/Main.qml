import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "Components"

Pane {
    id: root
    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: 0
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: true
    palette.window: "#000000"
    palette.highlight: "#ffffff"
    palette.highlightedText: "#000000"
    palette.buttonText: "#ffffff"
    font.family: config.Font || "Sans Serif"
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80) || 13
    focus: true

    Image {
        id: backgroundImage
        anchors.fill: parent
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        fillMode: Image.PreserveAspectCrop
        source: config.Background || config.background
        asynchronous: true
        cache: true
        mipmap: true
        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: true
        }
    }

    Rectangle {
        id: tintLayer
        anchors.fill: parent
        z: 1
        color: "#000000"
        opacity: 0
    }

    Quotes {
        id: quotesComponent
        anchors {
            top: parent.top
            left: parent.left
            margins: 40
            topMargin: 60
        }
        width: 200
        z: 4
        quote: config.Quote || "Never Backdown, Never What?"
        textColor: "#ffffff"
        fontSize: config.QuoteFontSize || 16
    }

    DateTime {
        id: dateTimeComponent
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 200
        }
        z: 4
        textColor: "#ffffff"
        dateFontSize: config.DateFontSize || 80
        timeFontSize: config.TimeFontSize || 169
    }

    SessionButton {
        id: sessionSelect
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        anchors.topMargin: 60
        z: 4
        model: sessionModel
        currentIndex: model.lastIndex
    }

    Rectangle {
        id: pfpContainer
        width: 80
        height: 80
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: form.top
        anchors.bottomMargin: -51
        z: 3
        radius: width / 2
        color: "#ffffff"
        antialiasing: true

        Image {
            id: userPfp
            width: 76
            height: 76
            anchors.centerIn: parent
            source: config.UserProfilePicture
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: mask
            }
            
            Item {
                id: mask
                width: userPfp.width
                height: userPfp.height
                layer.enabled: true
                visible: false
                
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "white"
                }
            }
        }
    }

    LoginForm {
        id: form
        width: Math.min(parent.width * 0.25, 500)
        height: Math.min(parent.height * 0.3, 150)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        z: 3
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.forceActiveFocus()
    }
}
