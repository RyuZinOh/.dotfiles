pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.UPower
import qs.Services.Theme

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 54

    readonly property int btnW: Math.floor((root.implicitWidth - 8) / 3)
    readonly property int btnH: 54
    readonly property int pillH: 38

    readonly property int activeIdx: {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return 0;
        if (PowerProfiles.profile === PowerProfile.Balanced)
            return 1;
        if (PowerProfiles.profile === PowerProfile.Performance)
            return 2;
        return 1;
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Theme.surfaceContainer
        border.color: Theme.outlineVariant
        border.width: 1

        Rectangle {
            id: pill
            width: root.btnW - 8
            height: root.pillH
            y: (root.btnH - root.pillH) / 2
            x: 4 + root.activeIdx * root.btnW + (root.btnW - pill.width) / 2
            radius: 13
            color: Theme.primaryContainer
            border.width: 0

            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4

            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.PowerSaver
                icon: "\udb80\udf2a"
                label: "power-saver"
            }
            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.Balanced
                icon: "\uf24e"
                label: "balanced"
            }
            ProfileButton {
                width: root.btnW
                height: root.btnH
                profile: PowerProfile.Performance
                icon: "\udb85\udcde"
                label: "performance"
                opacity: PowerProfiles.hasPerformanceProfile ? 1.0 : 0.35
                isEnabled: PowerProfiles.hasPerformanceProfile
            }
        }
    }

    component ProfileButton: Item {
        id: btn
        required property int profile
        required property string icon
        required property string label
        property bool isEnabled: true

        readonly property bool active: PowerProfiles.profile === btn.profile
        property bool hovered: false
        property real tipOpacity: 0.0

        function showTip() {
            btn.tipOpacity = 1.0;
            tipFade.restart();
        }

        SequentialAnimation {
            id: tipFade
            PauseAnimation {
                duration: 1000
            }
            NumberAnimation {
                target: btn
                property: "tipOpacity"
                to: 0.0
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "CaskaydiaCove NF"
            font.pixelSize: 20
            color: btn.active ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
            scale: btn.active ? 1.15 : (btn.hovered ? 1.05 : 1.0)
            Behavior on color {
                ColorAnimation {
                    duration: 220
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutBack
                }
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 4
            width: tipText.implicitWidth + 14
            height: tipText.implicitHeight + 6
            opacity: btn.tipOpacity
            visible: opacity > 0.01

            Rectangle {
                anchors.fill: parent
                radius: 7
                color: Theme.primaryContainer
            }

            Text {
                id: tipText
                anchors.centerIn: parent
                text: btn.label
                font.family: "CaskaydiaCove NF"
                font.pixelSize: 10
                font.weight: Font.Medium
                color: Theme.onPrimaryContainer
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: btn.isEnabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: btn.hovered = true
            onExited: btn.hovered = false
            onClicked: {
                PowerProfiles.profile = btn.profile;
                btn.showTip();
            }
        }
    }
}
