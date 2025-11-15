pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.UPower
import qs.components

PanelWindow {
    id: window
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
                if (expanded) {
                    return;
                }
                expanded = hovered = true;
                window.visible = true;
                hideT.stop();
            } else if (!hovered) {
                expanded = false;
                closeT.start();
            }
        }
    }

    Timer {
        id: hideT
        interval: 200
        onTriggered: popup.toggle(false)
    }
    Timer {
        id: closeT
        interval: 200 // we can make it like more smaller interval but the pops will have glitch so syncing
        onTriggered: {
            if (!popup.expanded && !popup.hovered) {
                window.visible = false;
            }
        }
    }
    visible: false
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
        return barR + 220;
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
                        if (isFullyCharged) {
                            return "Fully";
                        }
                        if (isCharging && !hasValidTime) {
                            return "Charging";
                        }
                        if (!hasValidTime) {
                            return "";
                        }

                        const t = rawTime;
                        const h = Math.floor(t / 3600);
                        const m = Math.floor((t % 3600) / 60);
                        return h === 0 ? `${m}m` : `${h}h ${m}m`;
                    }
                    property string subText: {
                        if (isFullyCharged) {
                            return "Charged";
                        }
                        if (isCharging && !hasValidTime) {
                            return "";
                        }
                        return isCharging ? "to full" : "remaining";
                    }
                }

                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }

                    spacing: 4
                    opacity: popup.expanded ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        text: batteryData.timeText
                        visible: batteryData.timeText !== ""

                        font.family: "0xProto Nerd Font"
                        font.pointSize: 13
                        font.bold: true

                        color: "white"

                        wrapMode: Text.WordWrap
                    }

                    Text {
                        text: batteryData.subText
                        visible: batteryData.timeText !== ""

                        font.family: "0xProto Nerd Font"
                        font.pointSize: 10

                        color: "#aaaaaa"

                        wrapMode: Text.WordWrap
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
                closeT.stop();
            }
            onExited: {
                popup.hovered = false;
                hideT.restart();
            }
        }
    }
}
