import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root
    color: "transparent"

    property bool barVisible: true
    property var clients: []

    // Hidden while a visible client is fullscreen. Inactive workspaces
    // report is_visible=false, so they are never affected.
    readonly property bool fullscreenActive: {
        for (let i = 0; i < clients.length; i++) {
            const c = clients[i]
            if (c && c.is_visible && (c.is_fullscreen || c.is_fakefullscreen)) return true
        }
        return false
    }

    // Window geometry and reserved space never change, so fullscreen
    // transitions cause no re-layout. Only the content hides.
    visible: barVisible
    exclusionMode: ExclusionMode.Auto
    exclusiveZone: 34

    anchors {
        bottom: true
        left: true
        right: true
    }
    margins {
        left: 0
        right: 0
    }

    implicitHeight: 34
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.namespace: "quickshell:bar"

    // ipc for manual control
    IpcHandler {
        target: "bar"
        function toggle(): void { root.barVisible = !root.barVisible }
        function show(): void { root.barVisible = true }
        function hide(): void { root.barVisible = false }
    }

    // Single event stream from the compositor; each line carries all clients.
    Process {
        id: clientsWatcher
        command: ["mmsg", "watch", "all-clients"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const txt = data.trim()
                if (txt === "") return
                try {
                    const parsed = JSON.parse(txt)
                    if (Array.isArray(parsed.clients)) root.clients = parsed.clients
                } catch (e) {}
            }
        }
        onExited: restartTimer.restart()
    }

    Timer {
        id: restartTimer
        interval: 2000
        onTriggered: clientsWatcher.running = true
    }

    Rectangle {
        id: barContent
        anchors.fill: parent
        color: PanelColors.barBackground
        visible: !fullscreenActive
        enabled: !fullscreenActive

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0

            Workspaces {}
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            spacing: 0

            Clock {}
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 4
            spacing: 8

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
}
