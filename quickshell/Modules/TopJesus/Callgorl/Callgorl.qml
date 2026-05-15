pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.utils

Item {
    id: root

    function toggle(service, isActive) {
        if (service === "dancer") {
            DancerConfig.isActive = !isActive;
            StateManager.set("dancer", !isActive);
            isActive ? DancerConfig.hideDancer() : DancerConfig.showDancer();
        } else if (service === "omnitrix") {
            OmnitrixConfig.isActive = !isActive;
            StateManager.set("omnitrix", !isActive);
            isActive ? OmnitrixConfig.hideOmnitrix() : OmnitrixConfig.showOmnitrix();
        } else if (service === "artiqa") {
            ArtiqaConfig.isActive = !isActive;
            StateManager.set("artiqa", !isActive);
            isActive ? ArtiqaConfig.hideArtiqa() : ArtiqaConfig.showArtiqa();
        } else if (service === "poketwo") {
            PoketwoConfig.isActive = !isActive;
            StateManager.set("poketwo", !isActive);
            isActive ? PoketwoConfig.hidePoketwo() : PoketwoConfig.showPoketwo();
        }
    }

    readonly property int btnHeight: 56
    readonly property int btnNormal: 56
    readonly property int btnExpanded: 80
    readonly property int btnCompressed: 46
    readonly property int outerRadius: 28
    readonly property int innerRadius: 4
    readonly property int groupSpacing: 4

    property real w0: btnNormal
    property real w1: btnNormal
    property real w2: btnNormal
    property real w3: btnNormal

    readonly property real totalWidth: w0 + w1 + w2 + w3 + groupSpacing * 3

    Item {
        anchors.centerIn: parent
        width: root.totalWidth
        height: root.btnHeight

        Repeater {
            model: [
                {
                    "icon": "\udb85\uddcf",
                    "active": DancerConfig.isActive,
                    "activeColor": Theme.primaryContainer,
                    "activeBorder": Theme.primaryColor,
                    "activeText": Theme.onPrimaryContainer,
                    "service": "dancer"
                },
                {
                    "icon": "\udb81\udeb1",
                    "active": OmnitrixConfig.isActive,
                    "activeColor": Theme.secondaryContainer,
                    "activeBorder": Theme.secondaryColor,
                    "activeText": Theme.onSecondaryContainer,
                    "service": "omnitrix"
                },
                {
                    "icon": "\uf1fc",
                    "active": ArtiqaConfig.isActive,
                    "activeColor": Theme.tertiaryContainer,
                    "activeBorder": Theme.tertiaryColor,
                    "activeText": Theme.onTertiaryContainer,
                    "service": "artiqa"
                },
                {
                    "icon": "\udb84\udf93",
                    "active": PoketwoConfig.isActive,
                    "activeColor": Theme.tertiaryContainer,
                    "activeBorder": Theme.tertiaryColor,
                    "activeText": Theme.onTertiaryContainer,
                    "service": "poketwo"
                }
            ]

            delegate: Item {
                id: btn

                required property var modelData
                required property int index

                readonly property bool isActive: modelData.active
                readonly property bool leftActive: index > 0 && [DancerConfig.isActive, OmnitrixConfig.isActive, ArtiqaConfig.isActive, PoketwoConfig.isActive][index - 1]
                readonly property bool rightActive: index < 3 && [DancerConfig.isActive, OmnitrixConfig.isActive, ArtiqaConfig.isActive, PoketwoConfig.isActive][index + 1]
                readonly property bool isCompressed: !isActive && (leftActive || rightActive)

                readonly property real targetWidth: isActive ? root.btnExpanded : isCompressed ? root.btnCompressed : root.btnNormal

                property real animWidth: root.btnNormal
                onTargetWidthChanged: animWidth = targetWidth

                Behavior on animWidth {
                    SpringAnimation {
                        spring: 5.0
                        damping: 0.7
                        epsilon: 0.5
                    }
                }

                onAnimWidthChanged: {
                    if (index === 0)
                        root.w0 = animWidth;
                    else if (index === 1)
                        root.w1 = animWidth;
                    else if (index === 2)
                        root.w2 = animWidth;
                    else if (index === 3)
                        root.w3 = animWidth;
                }

                readonly property real naturalX: {
                    if (index === 0)
                        return 0;
                    if (index === 1)
                        return root.w0 + root.groupSpacing;
                    if (index === 2)
                        return root.w0 + root.w1 + root.groupSpacing * 2;
                    return root.w0 + root.w1 + root.w2 + root.groupSpacing * 3;
                }

                readonly property real inactiveLeftR: index === 0 ? root.outerRadius : root.innerRadius
                readonly property real inactiveRightR: index === 3 ? root.outerRadius : root.innerRadius

                x: naturalX
                y: 0
                width: animWidth
                height: root.btnHeight

                Rectangle {
                    anchors.fill: parent

                    topLeftRadius: btn.isActive ? root.outerRadius : btn.inactiveLeftR
                    bottomLeftRadius: btn.isActive ? root.outerRadius : btn.inactiveLeftR
                    topRightRadius: btn.isActive ? root.outerRadius : btn.inactiveRightR
                    bottomRightRadius: btn.isActive ? root.outerRadius : btn.inactiveRightR

                    color: btn.isActive ? btn.modelData.activeColor : (btnMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
                    border.color: btn.isActive ? btn.modelData.activeBorder : Theme.outlineVariant
                    border.width: 1

                    Behavior on topLeftRadius {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on bottomLeftRadius {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on topRightRadius {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on bottomRightRadius {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Text {
                    text: btn.modelData.icon
                    font.family: "CaskaydiaCove NF"
                    font.pixelSize: 26
                    anchors.centerIn: parent
                    color: btn.isActive ? btn.modelData.activeText : Theme.onSurface

                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggle(btn.modelData.service, btn.modelData.active)
                }
            }
        }
    }
}
