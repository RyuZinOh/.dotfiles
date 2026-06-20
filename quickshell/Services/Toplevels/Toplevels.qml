pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property var model: ToplevelManager.toplevels

    readonly property list<var> enriched: ToplevelManager.toplevels.values.map(tl => {
        const appId = (tl.appId ?? "").toLowerCase();
        const lastToken = appId.split(".").pop();

        const entry = DesktopEntries.applications.values.find(e => {
            if (!e.id)
                return false;
            const eid = e.id.toLowerCase();
            return eid === appId || eid === `${appId}.desktop` || eid === `${lastToken}.desktop` || e.name?.toLowerCase() === lastToken;
        });

        return {
            "toplevel": tl,
            "hypr": root.hyprFor(tl),
            "icon": entry?.icon ? Quickshell.iconPath(entry.icon) : ""
        };
    })

    function toggleToplevel(toplevel) {
        if (toplevel.activated)
            toplevel.minimized = true;
        else
            toplevel.activate();
    }

    function hyprFor(toplevel) {
        return Hyprland.toplevels.values.find(h => h.title === toplevel.title) ?? null;
    }
}
