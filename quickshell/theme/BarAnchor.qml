pragma Singleton
import QtQuick
import Quickshell

// ── BarAnchor ─────────────────────────────────────────────────────────────────
// Shared state that ties a popup (calendar, control center, etc.) to the bar
// module that opened it. Bar widgets call setAnchor(this, id) before firing
// their ipc toggle; popups read anchorCenterX to spawn nearby instead of a
// hardcoded x/y.
//
// Coordinates: bar is PanelWindow { anchors: bottom+left+right, width=screenW,
// height=32 }. So mapToItem(null).x == screen X. The overlay popups are
// fullscreen PanelWindows (anchors all true) so parent.width == screenW, and
// their inner card's x computed from anchorCenterX is directly comparable.
Singleton {
    id: root

    // -1 means "not set yet" -> popups fall back to centered/right-aligned
    property real anchorCenterX: -1
    property real anchorX: 0
    property real anchorW: 0
    property string anchorId: ""
    property real margin: 8

    // internal signals - bar calls these, popups listen (avoids ipc path mismatch)
    signal toggleCalendar()
    signal toggleControl()

    // Call from bar delegate: BarAnchor.setAnchor(clockRoot, "calendar")
    function setAnchor(item, id) {
        if (!item) return
        try {
            // mapToGlobal gives screen coords directly (Qt6). Falls back to
            // parent-chain sum if not available (e.g. in some tests).
            var gx = 0
            if (typeof item.mapToGlobal === "function") {
                var g = item.mapToGlobal(0, 0)
                gx = g.x
            } else {
                var p = item.mapToItem(null, 0, 0)
                gx = p.x
            }
            anchorX = gx
            anchorW = item.width
            anchorCenterX = gx + item.width / 2
            anchorId = id
            console.log("BarAnchor set", id, "gx", gx, "center", anchorCenterX)
        } catch (e) {
            console.log("BarAnchor setAnchor failed", e, id)
            // last-resort: assume centered or right-aligned
            anchorCenterX = -1
            anchorId = id
        }
    }

    // Direct center override (e.g. from mouse.x)
    function setCenterX(cx, id) {
        anchorCenterX = cx
        anchorId = id !== undefined ? id : anchorId
    }

    // Helper: clamped x for a popup of given width on a screen of given width
    function popupX(popupWidth, screenWidth) {
        if (anchorCenterX < 0) return screenWidth - popupWidth - margin
        var x = anchorCenterX - popupWidth / 2
        if (x < margin) x = margin
        if (x + popupWidth > screenWidth - margin) x = screenWidth - popupWidth - margin
        return x
    }

    // Convenience: set from a MouseArea click where you have mouse coordinates
    function setFromMouse(item, mouseX, id) {
        if (!item) return
        try {
            var gx = 0
            if (typeof item.mapToGlobal === "function") {
                gx = item.mapToGlobal(mouseX, 0).x
            } else {
                gx = item.mapToItem(null, mouseX, 0).x
            }
            anchorCenterX = gx
            anchorX = gx - mouseX
            anchorW = item.width
            anchorId = id
        } catch (e) {
            console.log("BarAnchor setFromMouse failed", e)
        }
    }
}
