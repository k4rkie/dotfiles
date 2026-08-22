import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.Mpris
import Quickshell.Networking
import "../theme"

PanelWindow {
    id: root

    color: PanelColors.barBackground
    implicitHeight: 26
    anchors { left: true; right: true; bottom: true }

    WlrLayershell.layer: WlrLayershell.Top

    IpcHandler {
        target: "statusbar"
        function toggle(): void { root.visible = !root.visible }
        function show(): void { root.visible = true }
        function hide(): void { root.visible = false }
    }

    component BarText: Text {
        font.family: "Maple Mono NF"
        font.pixelSize: 14
        color: "#a1a1a1"
    }

    // workspaces
    Row {
        id: wsRow
        anchors { left: parent.left; leftMargin: 2; verticalCenter: parent.verticalCenter }
        spacing: 4

        Repeater {
            model: root.mangoTags.filter(t => t.client_count > 0 || t.is_active)

            delegate: Rectangle {
                id: wsBtn
                required property var modelData
                readonly property bool isActive: modelData.is_active
                readonly property bool isUrgent: modelData.is_urgent
                readonly property string label:
                    ["I","II","III","IV","V","VI","VII","VIII","IX"][modelData.index - 1] ?? String(modelData.index)

                width: Math.max(18, wsLabel.implicitWidth + 8)
                height: 18
                radius: 0
                color: isUrgent ? "#ad401f" : (isActive ? "#a1a1a1" : "transparent")
                opacity: wsArea.containsMouse ? 0.75 : 1.0

                Behavior on opacity { NumberAnimation { duration: 100 } }

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text: wsBtn.label
                    font.family: "Maple Mono NF"
                    font.pixelSize: 14
                    color: wsBtn.isActive || wsBtn.isUrgent ? "#030303" : "#444444"
                }

                MouseArea {
                    id: wsArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wsSwitchProc.command = ["mmsg", "dispatch", "view," + wsBtn.modelData.index]
                }
            }
        }
    }

    // focused window title
    Item {
        anchors { left: wsRow.right; leftMargin: 8; verticalCenter: parent.verticalCenter }
        visible: root.focusedTitle !== ""
        width: visible ? Math.min(focusTitleText.implicitWidth, 320) : 0
        height: root.height

        BarText {
            id: focusTitleText
            anchors.centerIn: parent
            width: parent.width
            elide: Text.ElideRight
            text: root.focusedTitle === "" ? "" : "> " + root.focusedTitle
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onContainsMouseChanged: focusTitleText.opacity = containsMouse ? 0.75 : 1.0
        }
    }

    // center: media animation + clock
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        spacing: 0

        // media playing animation
        Item {
            width: mediaAnimText.implicitWidth
            height: root.height

            BarText {
                id: mediaAnimText
                font.pixelSize: 12
                anchors.centerIn: parent
                text: root.mediaPlaying ? root.mediaFrames[root.mediaFrameIdx] : root.mediaPauseFrame
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: mediaAnimText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "media", "toggle"])
            }
        }

        Item {
            width: 8
            height: parent.height
        }

        // clock
        Item {
            width: clockText.implicitWidth
            height: parent.height

            BarText {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clockTime.date, "ddd MMM-dd, hh:mm AP")
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: clockText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "calendar", "toggle"])
            }
        }
    }

    // right side
    Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 0

        // memory
        Item {
            width: memText.implicitWidth + 16
            height: root.height

            BarText { id: memText; anchors.centerIn: parent; text: "mem:" + root.memPct + "%" }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: memText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["footclient", "-a", "btop", "btop"])
            }
        }

        // volume
        Item {
            width: volText.implicitWidth + 16
            height: root.height

            BarText {
                id: volText
                anchors.centerIn: parent
                text: (root.volMuted ? "volx:" : "vol:") + root.volPct + "%"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                scrollGestureEnabled: true
                onContainsMouseChanged: volText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["pavucontrol"])
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0)
                        volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "1%+"]
                    else
                        volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "1%-"]
                    volSetProc.running = true
                }
            }
        }

        // battery
        Item {
            visible: root.hasBattery
            width: visible ? batText.implicitWidth + 16 : 0
            height: root.height

            BarText {
                id: batText
                anchors.centerIn: parent
                text: root.batCharging
                    ? " bat:" + root.batPct + "%"
                    : "󱊣 bat:" + root.batPct + "%"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: batText.opacity = containsMouse ? 0.75 : 1.0
            }
        }

        // caffeine
        Item {
            width: cafText.implicitWidth + 16
            height: root.height

            BarText { id: cafText; anchors.centerIn: parent; text: "caf:" + (root.caffeineOn ? "on" : "off") }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: cafText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: cafToggleProc.running = true
            }
        }

        // network
        Item {
            width: netText.implicitWidth + 16
            height: root.height

            BarText {
                id: netText
                anchors.centerIn: parent
                text: "net:" + (root.ethConnected ? "" : (root.wifiConnected ? "󰖩" : "󰖪"))
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: netText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "wifi", "toggle"])
            }
        }

        // notifications
        Item {
            width: notiText.implicitWidth + 24
            height: root.height

            BarText { id: notiText; anchors.centerIn: parent; text: "noti:" + root.notiIcon }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onContainsMouseChanged: notiText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        notiProc.command = ["swaync-client", "-d", "-sw"]
                    else
                        notiProc.command = ["swaync-client", "-t", "-sw"]
                    notiProc.running = true
                }
            }
        }

        // tray
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            rightPadding: 4

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    id: trayItem
                    required property var modelData
                    width: 14
                    height: 14

                    Image {
                        anchors.fill: parent
                        source: parent.modelData.icon
                        sourceSize.width: 28
                        sourceSize.height: 28
                        mipmap: true
                        opacity: trayArea.containsMouse ? 0.75 : 1.0

                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    QsMenuAnchor {
                        id: trayMenuAnchor
                        anchor.window: root.QsWindow.window
                        anchor.item: trayItem
                        anchor.edges: Edges.Bottom | Edges.Right
                        anchor.gravity: Edges.Bottom | Edges.Right
                    }

                    MouseArea {
                        id: trayArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            const item = trayItem.modelData
                            if (mouse.button === Qt.RightButton || item.onlyMenu) {
                                if (item.hasMenu) {
                                    trayMenuAnchor.menu = item.menu
                                    trayMenuAnchor.open()
                                }
                            } else {
                                item.activate()
                            }
                        }
                    }
                }
            }
        }
    }

    // state
    property var mangoTags: []
    property string focusedTitle: ""

    // mangowc IPC: focused client
    function _setFocusedTitle(line) {
        try {
            const c = JSON.parse(line)
            root.focusedTitle = c && c.appid ? String(c.appid).trim() : ""
        } catch (e) { root.focusedTitle = "" }
    }
    Process {
        id: focusWatch
        command: ["mmsg", "watch", "focusing-client"]
        running: true
        stdout: SplitParser { onRead: (line) => root._setFocusedTitle(line) }
    }
    Process {
        id: focusGet
        command: ["mmsg", "get", "focusing-client"]
        stdout: StdioCollector { onStreamFinished: root._setFocusedTitle(text.trim()) }
    }
    Timer {
        interval: 2000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: if (!focusGet.running) focusGet.running = true
    }

    // media animation
    readonly property var mediaFrames: ["▂▄▆", "▄▂▆", "▄▆▂", "▆▄▂", "▆▂▄"]
    property int mediaFrameIdx: 0
    property string mediaPauseFrame: "▂▄▆"
    readonly property bool mediaPlaying: {
        const vals = Mpris.players.values
        for (let i = 0; i < vals.length; i++)
            if (vals[i].playbackState === MprisPlaybackState.Playing) return true
        return false
    }
    onMediaPlayingChanged: if (!mediaPlaying) {
        mediaPauseFrame = mediaFrames[Math.floor(Math.random() * mediaFrames.length)]
        mediaFrameIdx = 0
    }

    Timer {
        interval: 200; running: root.mediaPlaying; repeat: true
        onTriggered: root.mediaFrameIdx = (root.mediaFrameIdx + 1) % root.mediaFrames.length
    }

    // clock
    QtObject {
        id: clockTime
        property date date: new Date()
    }
    Timer {
        interval: 30000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: clockTime.date = new Date()
    }

    // mangowc IPC: live tag state
    Process {
        id: tagWatch
        command: ["mmsg", "watch", "all-monitors"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const mons = JSON.parse(line).monitors || []
                    const arr = []
                    for (let i = 0; i < mons.length; i++)
                        for (let j = 0; j < mons[i].tags.length; j++)
                            arr.push(mons[i].tags[j])
                    arr.sort((a, b) => a.index - b.index)
                    root.mangoTags = arr
                } catch (e) {}
            }
        }
    }
    Process {
        id: wsSwitchProc
        command: ["true"]
    }
    property int memPct: 0
    property int volPct: 0
    property bool volMuted: false
    property int batPct: 0
    property bool batCharging: false
    property bool caffeineOn: false
    property bool wifiConnected: false
    property bool ethConnected: false
    property string notiIcon: ""

    readonly property var wifiDevice: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const d = Networking.devices.values[i]
            if (d.type === DeviceType.Wifi) return d
        }
        return null
    }
    readonly property bool wifiActive: {
        if (!wifiDevice) return false
        for (let i = 0; i < wifiDevice.networks.values.length; i++)
            if (wifiDevice.networks.values[i].connected) return true
        return false
    }
    onWifiActiveChanged: wifiConnected = wifiActive
    Component.onCompleted: {
        wifiConnected = wifiActive
        ethConnected = Qt.binding(function() {
            for (let i = 0; i < Networking.devices.values.length; i++) {
                const d = Networking.devices.values[i]
                if (d.type === DeviceType.Ethernet && d.state === DeviceState.Activated) return true
            }
            return false
        })
    }

    // memory poll
    Timer {
        interval: 3000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: memProc.running = true
    }
    Process {
        id: memProc
        command: ["sh", "-c",
            "awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d\", (1-a/t)*100}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.memPct = parseInt(text.trim()) || 0
        }
    }

    // volume poll
    Timer {
        interval: 2000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: volProc.running = true
    }
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                root.volMuted = out.indexOf("[MUTED]") >= 0
                const v = parseFloat(out.replace("Volume:", ""))
                root.volPct = isFinite(v) ? Math.round(v * 100) : 0
            }
        }
    }
    Process {
        id: volSetProc
        onRunningChanged: if (!running) volProc.running = true
    }

    // battery (sysfs, like waybar)
    property bool hasBattery: false
    Timer {
        interval: 10000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: batProc.running = true
    }
    Process {
        id: batProc
        command: ["sh", "-c",
            "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null; echo ---; cat /sys/class/power_supply/BAT*/status 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("---")
                const cap = parseInt((parts[0] || "").trim())
                const status = (parts[1] || "").trim()
                root.hasBattery = isFinite(cap)
                if (isFinite(cap)) root.batPct = cap
                root.batCharging = status.indexOf("Charging") >= 0 || status === "Full"
            }
        }
    }

    // caffeine
    FileView {
        path: "/tmp/caffeine"
        watchChanges: true
        printErrors: false
        onLoaded: root.caffeineOn = true
        onLoadFailed: root.caffeineOn = false
        onFileChanged: reload()
    }
    Process {
        id: cafToggleProc
        command: [Quickshell.env("HOME") + "/scripts/caffeine-toggle.sh"]
    }

    // notifications
    Timer {
        interval: 2000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: {
            if (notiProc.running) return
            notiPoll.running = true
        }
    }
    Process {
        id: notiPoll
        command: ["sh", "-c", "swaync-client -swb 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text.trim())
                    const alt = String(obj.alt || "")
                    const dnd = alt.indexOf("dnd") >= 0
                    const inhibited = alt.indexOf("inhibited") >= 0
                    const hasNoti = alt.indexOf("none") < 0
                    if (inhibited) root.notiIcon = hasNoti ? "󰂛" : "󰪑"
                    else if (dnd) root.notiIcon = hasNoti ? "󰂠" : "󰪓"
                    else root.notiIcon = hasNoti ? "󱅫" : ""
                } catch (e) { root.notiIcon = "" }
            }
        }
    }
    Process { id: notiProc }
}
