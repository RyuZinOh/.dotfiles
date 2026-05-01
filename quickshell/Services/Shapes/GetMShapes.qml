pragma Singleton
import QtQuick
import Quickshell
import "material-shapes.js" as MaterialShapes

Singleton {
    id: root

    readonly property var getters: [MaterialShapes.getCircle, MaterialShapes.getSquare, MaterialShapes.getSlanted, MaterialShapes.getArch, MaterialShapes.getFan, MaterialShapes.getArrow, MaterialShapes.getSemiCircle, MaterialShapes.getOval, MaterialShapes.getPill, MaterialShapes.getTriangle, MaterialShapes.getDiamond, MaterialShapes.getClamShell, MaterialShapes.getPentagon, MaterialShapes.getGem, MaterialShapes.getSunny, MaterialShapes.getVerySunny, MaterialShapes.getCookie4Sided, MaterialShapes.getCookie6Sided, MaterialShapes.getCookie7Sided, MaterialShapes.getCookie9Sided, MaterialShapes.getCookie12Sided, MaterialShapes.getGhostish, MaterialShapes.getClover4Leaf, MaterialShapes.getClover8Leaf, MaterialShapes.getBurst, MaterialShapes.getSoftBurst, MaterialShapes.getBoom, MaterialShapes.getSoftBoom, MaterialShapes.getFlower, MaterialShapes.getPuffy, MaterialShapes.getPuffyDiamond, MaterialShapes.getPixelCircle, MaterialShapes.getPixelTriangle, MaterialShapes.getBun, MaterialShapes.getHeart]

    function get(idx) {
        return root.getters[idx % root.getters.length]();
    }
}
