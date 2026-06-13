pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property var model: ToplevelManager.toplevels
    readonly property var enriched: {
        return ToplevelManager.toplevels.values.map(tl => {
            return ({
                    "toplevel": tl,
                    "hypr": Hyprland.toplevels.values.find(h => {
                        return h.title === tl.title;
                    }) ?? null
                });
        });
    }

    function iconCandidates(appId) {
        const id = appId ?? "";
        const last = id.split(".").pop();
        const lowerId = id.toLowerCase();
        const lowerLast = last.toLowerCase();

        let desktopIcon = "";

        if (id !== "") {
            const entries = [...DesktopEntries.applications.values];

            const match = entries.find(e => {
                if (!e.id)
                    return false;
                const eid = e.id.toLowerCase();

                return eid === lowerId || eid === lowerId + ".desktop" || eid === lowerLast + ".desktop" || (e.name && e.name.toLowerCase() === lowerLast);
            });

            if (match && match.icon) {
                desktopIcon = match.icon;
            }
        }

        const all = [desktopIcon, id, last, lowerLast];

        return all.filter((v, i, a) => {
            return typeof v === "string" && v.trim().length > 0 && a.indexOf(v) === i;
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
        return Hyprland.toplevels.values.find(h => {
            return h.title === toplevel.title;
        }) ?? null;
    }
}
