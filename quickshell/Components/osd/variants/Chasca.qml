pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root
    width: 120
    height: width * 1.42

    property real normalizedValue: 0

    property string spriteCache: "/home/safal726/.cache/safalQuick/nightsoul/Chasca/"

    Component.onCompleted: {
        console.log("Chasca variant created");
    }

    Component.onDestruction: {
        console.log("Chasca variant destroyed");
    }

    ShaderEffect {
        anchors.centerIn: parent
        width: parent.width * 1.4
        anchors.horizontalCenterOffset: -15
        anchors.verticalCenterOffset: -25
        height: parent.height * 1.6
        z: -1

        property variant source: Image {
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_EffColor_02.png"
        }
        property real time: 0

        NumberAnimation on time {
            from: 0
            to: 100
            duration: 100000
            loops: Animation.Infinite
            running: true
        }

        vertexShader: root.spriteCache + "/flame.vert.qsb"
        fragmentShader: root.spriteCache + "/flame.frag.qsb"
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg.png"
        fillMode: Image.PreserveAspectFit
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * root.normalizedValue
        clip: true

        Image {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: root.width
            height: root.height
            source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarFill.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarMask.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_BarBg02.png"
        fillMode: Image.PreserveAspectFit
    }

    Image {
        anchors.fill: parent
        source: root.spriteCache + "/UI_NyxStateBar_Chasca_Mask_02.png"
        fillMode: Image.PreserveAspectFit
    }
}
