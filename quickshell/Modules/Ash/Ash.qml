import QtQuick
import Quickshell.Io
import qs.Services.Theme

Item {
    id: ashRoot
    property bool isHovered: hoverHandler.hovered
    
    readonly property int circleSize: 40
    readonly property int expandedWidth: 280
    readonly property int expandedHeight: 120
    
    implicitWidth: isHovered ? expandedWidth : circleSize
    implicitHeight: isHovered ? expandedHeight : circleSize
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }
    
    Process {
        id: notifyProcess
        command: ["notify-send", "Ash", "hi.."]
    }
    
    Rectangle {
        id: ashContainer
        anchors.fill: parent
        radius: isHovered ? 16 : width / 2
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 2
        clip: true
        
        Behavior on radius {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }
        
        HoverHandler {
            id: hoverHandler
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: 6
            color: Theme.primaryColor
            opacity: isHovered ? 0 : 1
            visible: !isHovered
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 12
            opacity: isHovered ? 1 : 0
            scale: isHovered ? 1 : 0.7
            visible: opacity > 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuad
                }
            }
            
            Behavior on scale {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Hello Safal,"
                font.pixelSize: 16
                font.weight: Font.Medium
                color: Theme.onSurface
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Hope you're ok.."
                font.pixelSize: 14
                color: Theme.dimColor
            }
            
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 120
                height: 32
                radius: 8
                color: buttonTapHandler.pressed ? Qt.darker(Theme.primaryColor, 1.1) : (buttonHoverHandler.hovered ? Qt.lighter(Theme.primaryColor, 1.1) : Theme.primaryColor)
                
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "Test Button"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Theme.onPrimary
                }
                
                HoverHandler {
                    id: buttonHoverHandler
                    cursorShape: Qt.PointingHandCursor
                }
                
                TapHandler {
                    id: buttonTapHandler
                    cursorShape: Qt.PointingHandCursor
                    onTapped: {
                        notifyProcess.running = true;
                    }
                }
            }
        }
    }
}
