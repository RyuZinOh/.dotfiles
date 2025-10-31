import QtQuick
import QtQuick.Controls
import SddmComponents 2.0 as SDDM

Item {
    id: sessionButton

    height: root.font.pointSize * 2
    width: implicitWidth
    
    property alias implicitWidth: selectSession.implicitWidth
    property alias currentIndex: selectSession.currentIndex
    property alias currentText: selectSession.currentText
    property alias model: selectSession.model
    property alias hovered: selectSession.hovered
    property alias pressed: selectSession.down
    property ComboBox exposeSession: selectSession

    ComboBox {
        id: selectSession

        anchors.fill: parent
        implicitWidth: displayedItem.implicitWidth + 20
        implicitHeight: root.font.pointSize * 2

        hoverEnabled: true
        model: sessionModel
        currentIndex: model.lastIndex
        textRole: "name"
        
        Keys.onPressed: function(event) {
            if ((event.key == Qt.Key_Left || event.key == Qt.Key_Right) && !popup.opened) {
                popup.open();
            }
        }

        delegate: ItemDelegate {
            width: popupHandler.width - 20
            anchors.horizontalCenter: popupHandler.horizontalCenter
            
            contentItem: Text {
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: model.name
                font.pointSize: root.font.pointSize * 0.8
                font.family: root.font.family
                color: "#000000"
            }
            
            background: Rectangle {
                color: selectSession.highlightedIndex === index ? "#e0e0e0" : "transparent"
            }
        }

        indicator: Item {
            visible: false
        }

        contentItem: Text {
            id: displayedItem

            verticalAlignment: Text.AlignVCenter
            text: "Session (" + selectSession.currentText + ")"
            color: "#ffffff"
            font.pointSize: root.font.pointSize * 0.8
            font.family: root.font.family

            Keys.onReleased: parent.popup.open()
        }

        background: Rectangle {
            height: parent.visualFocus ? 2 : 0
            width: displayedItem.implicitWidth
            color: "transparent"
        }

        popup: Popup {
            id: popupHandler

            implicitHeight: contentItem.implicitHeight
            width: sessionButton.width
            y: parent.height - 1
            x: -popupHandler.width/2 + displayedItem.width/2
            padding: 10

            contentItem: ListView {
                implicitHeight: contentHeight + 20
                clip: true
                model: selectSession.popup.visible ? selectSession.delegateModel : null
                currentIndex: selectSession.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                radius: 8
                color: "#ffffff"
                layer.enabled: true
            }

            enter: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1 }
            }
        }

        states: [
            State {
                name: "pressed"
                when: selectSession.down
                PropertyChanges {
                    target: displayedItem
                    color: "#cccccc"
                }
            },
            State {
                name: "hovered"
                when: selectSession.hovered
                PropertyChanges {
                    target: displayedItem
                    color: "#ffffff"
                }
            },
            State {
                name: "focused"
                when: selectSession.visualFocus
                PropertyChanges {
                    target: displayedItem
                    color: "#ffffff"
                }
            }
        ]
        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "color"
                    duration: 150
                }
            }
        ]
    }
}
