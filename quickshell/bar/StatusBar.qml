import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    color: "transparent"

    // Manual visibility toggle via IPC
    property bool barVisible: true
    // Hover state - when fullscreen, bar reveals on hover at screen edge
    property bool hovered: false
    // Allow disabling auto-hide
    property bool autoHideEnabled: true

    // mmsg fallback state
    property bool mmsgFullscreen: false
    // toplevel detection helper
    readonly property bool toplevelFullscreen: {
        if (!ToplevelManager) return false
        try {
            const vals = ToplevelManager.toplevels.values
            for (let i = 0; i < vals.length; i++) {
                if (vals[i] && vals[i].fullscreen) return true
            }
        } catch (e) {}
        return false
    }
    readonly property bool hasFullscreen: autoHideEnabled && (toplevelFullscreen || mmsgFullscreen)
    readonly property bool shouldShow: barVisible && (!hasFullscreen || hovered)



    // When shouldShow is false we collapse to a 2px trigger strip (still catches hover)
    // Use Ignore so fullscreen windows can use that space
    visible: barVisible
    exclusionMode: shouldShow ? ExclusionMode.Auto : ExclusionMode.Ignore
    exclusiveZone: shouldShow ? 34 : 0

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: shouldShow ? 34 : 3
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "quickshell:bar"

    // ipc for manual control
    IpcHandler {
        target: "bar"
        function toggle(): void { root.barVisible = !root.barVisible }
        function show(): void { root.barVisible = true }
        function hide(): void { root.barVisible = false }
        function setAutoHide(enabled: bool): void { root.autoHideEnabled = enabled }
    }

    // mmsg watcher for compositor fullscreen (mango/mmsg compositor 0.17.x)
    // Watches all-clients stream; each line is JSON with {clients:[...]}
    Process {
        id: mmsgWatcher
        command: ["mmsg", "watch", "all-clients"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const txt = data.trim()
                if (txt === "") return
                try {
                    const parsed = JSON.parse(txt)
                    const clients = parsed.clients
                    if (!Array.isArray(clients)) return
                    let fs = false
                    for (let i = 0; i < clients.length; i++) {
                        const c = clients[i]
                        // visible + fullscreen; also consider fakefullscreen if needed
                        if ((c.is_fullscreen || c.is_fakefullscreen) && c.is_visible) {
                            fs = true
                            break
                        }
                    }
                    root.mmsgFullscreen = fs
                } catch (e) {}
            }
        }
        onExited: (code, status) => {
            // restart after delay if crashed
            restartTimer.restart()
        }
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: mmsgWatcher.running = true
    }

    // Poll fallback for startup and if watch misses events
    Timer {
        id: pollTimer
        interval: 800
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: pollProc.running = true
    }

    Process {
        id: pollProc
        command: ["mmsg", "get", "all-clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text.trim())
                    const clients = parsed.clients || []
                    let fs = false
                    for (let i = 0; i < clients.length; i++) {
                        if ((clients[i].is_fullscreen || clients[i].is_fakefullscreen) && clients[i].is_visible) { fs = true; break }
                    }
                    // only use poll result if watcher hasn't set recently? just OR
                    // prefer watcher but poll ensures initial state
                    if (!mmsgWatcher.running) root.mmsgFullscreen = fs
                    else if (fs) root.mmsgFullscreen = true
                    // if poll says no fullscreen but watcher says yes, keep watcher value
                    // if poll says no and watcher not running, clear
                    // Simplify: if watcher is running and poll says false, don't clear immediately - wait for watcher
                    // Instead sync when both agree no fs
                    if (!fs && !root.toplevelFullscreen) {
                        // check watcher would have set false if it saw no fs, so we can clear
                        // use small debounce via timer?
                    }
                } catch (e) {}
            }
        }
    }

    // Also watch ToplevelManager directly for quick reaction when Poll says no fullscreen
    onToplevelFullscreenChanged: {
        if (!toplevelFullscreen) {
            Qt.callLater(() => { if (pollProc.running === false) pollProc.running = true })
        }
    }

    // Hover handling - the collapsed 3px strip catches mouse
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        // Don't block clicks on bar content when shown; let them propagate
        // When collapsed, we just need enter/exit to reveal
        onEntered: {
            if (root.hasFullscreen) {
                root.hovered = true
                autoHideTimer.stop()
            }
        }
        onExited: {
            if (root.hasFullscreen && root.hovered) {
                // small delay before hiding to avoid flicker when moving within bar
                autoHideTimer.restart()
            }
        }
        onClicked: mouse => {
            // don't intercept clicks when bar is shown; propagate to children
            mouse.accepted = false
        }
    }

    Timer {
        id: autoHideTimer
        interval: 400
        onTriggered: root.hovered = false
    }

    // Keep bar visible while mouse is over content area (more reliable than hoverArea alone)
    // When bar is shown due to fullscreen hover, any movement inside should keep it
    Rectangle {
        id: barContent
        anchors.fill: parent
        color: root.shouldShow ? PanelColors.barBackground : "transparent"
        border.width: 0
        clip: false
        opacity: root.shouldShow ? 1 : 0

        // Content - only interactive when shouldShow
        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0
            opacity: root.shouldShow ? 1 : 0
            enabled: root.shouldShow

            Workspaces {}
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0
            opacity: root.shouldShow ? 1 : 0
            enabled: root.shouldShow

            Clock {}
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            spacing: 8
            opacity: root.shouldShow ? 1 : 0
            enabled: root.shouldShow

            Memory {}
            Separator {}
            Storage {}
            Separator {}
            Battery {}
            Separator {}
            Wifi {}
            Tray { barWindow: root }
        }

    }

    // When collapsed, show subtle hint line at edge so user knows to hover
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: PanelColors.barBorder
        opacity: (root.hasFullscreen && !root.shouldShow) ? 0.6 : 0
    }
}
