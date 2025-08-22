import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import "Components"

Pane {
    id: root
    height: config.ScreenHeight || Screen.height
    width: config.ScreenWidth || Screen.width
    padding: config.ScreenPadding || 0
    LayoutMirroring.enabled: config.RightToLeftLayout == "true" ? true : Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
    palette.window: config.BackgroundColor
    palette.highlight: config.HighlightBackgroundColor
    palette.highlightedText: config.HighlightTextColor
    palette.buttonText: config.HoverSystemButtonsIconsColor
    font.family: config.Font
    font.pointSize: config.FontSize !== "" ? config.FontSize : parseInt(height / 80) || 13
    focus: true

    Image {
        id: backgroundImage
        anchors.fill: parent
        horizontalAlignment: config.BackgroundHorizontalAlignment == "left" ? Image.AlignLeft : 
                           config.BackgroundHorizontalAlignment == "right" ? Image.AlignRight : 
                           Image.AlignHCenter
        verticalAlignment: config.BackgroundVerticalAlignment == "top" ? Image.AlignTop :
                         config.BackgroundVerticalAlignment == "bottom" ? Image.AlignBottom : 
                         Image.AlignVCenter
        fillMode: config.CropBackground == "true" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
        source: config.background || config.Background
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
        color: config.DimBackgroundColor
        opacity: config.DimBackground || 0
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
        quote: config.Quote || "She was the Beautful gyaru, I was the dumb one to not notice! fuck!"
        textColor: config.QuoteColor || "white"
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
        textColor: config.DateTimeColor || "white"
        dateFontSize: config.DateFontSize || 24
        timeFontSize: config.TimeFontSize || 48
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
        anchors.bottomMargin: -50
        z: 3
        radius: width / 2

        Image {
            id: userPfpSource
            source: config.UserProfilePicture
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: userPfpSource
            maskEnabled: true
            maskSource: mask
            maskThresholdMin: 0.5
            smooth: true
            autoPaddingEnabled: true
        }

        Item {
            id: mask
            width: pfpContainer.width
            height: pfpContainer.height
            visible: false
            layer.enabled: true

            Rectangle {
                width: parent.width
                height: parent.height
                radius: width / 2
                color: "black"
            }
        }
        
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: width / 2
            border.width: 3 
            border.color: "#1c1d1d"
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
