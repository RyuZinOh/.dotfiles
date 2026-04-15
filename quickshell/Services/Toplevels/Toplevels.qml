pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
pragma Singleton

Singleton {
    id: root

    property var iconOverrides: ({
        "org.godotengine.ProjectManager": "godot",
        "codium": "vscodium",
        "obsidian": "md.obsidian.Obsidian", 
        "Postman": "postman",
        "org.qt-project.qtcreator": "QtProject-qtcreator",
        "org.kde.krita": "krita",
        "com.pokemmo.PokeMMO": "pokemmo-launcher",
        "Waydroid": "waydroid",
        "code": "visual-studio-code"
    })
    readonly property var model: ToplevelManager.toplevels
    readonly property var enriched: {
        return ToplevelManager.toplevels.values.map((tl) => {
            return ({
                "toplevel": tl,
                "hypr": Hyprland.toplevels.values.find((h) => {
                    return h.title === tl.title;
                }) ?? null
            });
        });
    }

    function iconCandidates(appId) {
        const id = appId ?? "";
        const last = id.split(".").pop();
        const all = [root.iconOverrides[id] ?? "", id, last, last.toLowerCase()];
        return all.filter((v, i, a) => {
            return v.length > 0 && a.indexOf(v) === i;
        });
    }

    function iconPath(appId, attempt) {
        const c = iconCandidates(appId);
        return c.length > 0 ? Quickshell.iconPath(c[attempt ?? 0]) : "";
    }

    function toggleToplevel(toplevel) {
        if (toplevel.activated)
            toplevel.minimized = true;
        else
            toplevel.activate();
    }

    function hyprFor(toplevel) {
        return Hyprland.toplevels.values.find((h) => {
            return h.title === toplevel.title;
        }) ?? null;
    }

}
