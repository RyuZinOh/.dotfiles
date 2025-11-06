pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import qs.components

PanelWindow {
    property alias expanded: popup.expanded
    property alias hovered: popup.hovered
    property alias hideT: hideT

    function toggle(show) {
        popup.toggle(show);
    }

    QtObject {
        id: popup
        property bool expanded: false
        property bool hovered: false
        function toggle(show) {
            if (show) {
                if (expanded)
                    return;
                expanded = hovered = true;
                hideT.stop();
            } else if (!hovered) {
                expanded = false;
            }
        }
    }

    Timer {
        id: hideT
        interval: 200
        onTriggered: popup.toggle(false)
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    screen: Quickshell.screens[0]
    implicitWidth: 140
    implicitHeight: 60
    anchors.top: true
    anchors.right: true
    margins.top: 40
    margins.right: {
        let scr = Quickshell.screens[0];
        let barW = Math.min(1440, scr.width - 40);
        let barR = (scr.width - barW) / 2;
        return barR + 250;
    }

    PopoutShape {
        id: panel
        anchors.fill: parent
        radius: 10
        color: "black"
        style: 1
        alignment: 0
        clip: true
        height: popup.expanded ? 50 : 0

        transform: Scale {
            origin.x: panel.width / 2
            origin.y: 0
            xScale: 1.0
            yScale: popup.expanded ? 1.0 : 0.0
            Behavior on yScale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Repeater {
            model: UPower.devices
            delegate: Item {
                required property UPowerDevice modelData
                visible: modelData.isLaptopBattery
                anchors.fill: parent

                QtObject {
                    id: batteryData
                    property int state: modelData.state
                    property bool isCharging: state === UPowerDeviceState.Charging
                    property bool isDischarging: state === UPowerDeviceState.Discharging
                    property bool isFullyCharged: state === UPowerDeviceState.FullyCharged
                    property int rawTime: isCharging ? modelData.timeToFull : modelData.timeToEmpty
                    property bool hasValidTime: rawTime > 0 && !isFullyCharged
                    property string timeText: {
                        if (!hasValidTime)
                            return "";
                        const t = rawTime;
                        const h = Math.floor(t / 3600);
                        const m = Math.floor((t % 3600) / 60);
                        return h === 0 ? `${m}m` : `${h}h ${m}m`;
                    }
                    property string subText: isCharging ? "to full" : "remaining"
                }

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2
                    opacity: popup.expanded ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }

                    Text {
                        text: batteryData.timeText
                        visible: batteryData.hasValidTime
                        font.family: "0xProto Nerd Font"
                        font.pointSize: 11
                        font.bold: true
                        color: "white"
                    }

                    Text {
                        text: batteryData.subText
                        visible: batteryData.hasValidTime
                        font.family: "0xProto Nerd Font"
                        font.pointSize: 12
                        color: "#bbbbbb"
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                popup.hovered = true;
                hideT.stop();
            }
            onExited: {
                popup.hovered = false;
                hideT.restart();
            }
        }
    }
}
