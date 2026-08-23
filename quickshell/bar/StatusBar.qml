import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../theme"

PanelWindow {
    id: root

    color: PanelColors.barBackground
    implicitHeight: 28
    anchors { left: true; right: true; bottom: true }

    WlrLayershell.layer: WlrLayershell.Top

    IpcHandler {
        target: "statusbar"
        function toggle(): void { root.visible = !root.visible }
        function show(): void { root.visible = true }
        function hide(): void { root.visible = false }
    }

    component BarText: Text {
        renderType: Text.NativeRendering
        font.family: "SevrainsMono Nerd Font"
        font.pixelSize: 16
        color: "#aaaaaa"
    }

    // ---- workspaces ------------------------------------------------------------------

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
                    ["one","two","three","four","five","six","seven","eight","nine"][modelData.index - 1] ?? String(modelData.index)

                width: Math.max(isActive ? 28 : 18, wsLabel.implicitWidth + 8)
                height: 18
                radius: 0
                color: isUrgent ? "#ad401f" : (isActive ? "#a1a1a1" : "transparent")
                opacity: wsArea.containsMouse ? 0.75 : 1.0

                Behavior on opacity { NumberAnimation { duration: 0 } }

                Text {
                    renderType: Text.NativeRendering
                    id: wsLabel
                    anchors.centerIn: parent
                    text: wsBtn.label
                    font.family: "SevrainsMono Nerd Font"
                    font.pixelSize: 16
                    color: wsBtn.isActive || wsBtn.isUrgent ? "#000000" : "#444444"
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

    // ---- center: media animation + clock ----------------------------------------------

    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        spacing: 0

        // media playing animation (rainbow bars, mirrors waybar media-animation.sh)
        Item {
            width: mediaAnimText.implicitWidth
            height: root.height

            BarText {
                id: mediaAnimText
                font.pixelSize: 12
                textFormat: Text.StyledText
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: mediaAnimText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "media", "toggle"])
            }
        }

        Item {
            width: 12
            height: parent.height
        }

        // clock
        Item {
            width: clockText.implicitWidth + 12
            height: parent.height

            BarText {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(clockTime.date, "ddd, hh:mm AP")
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: clockText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "calendar", "toggle"])
            }
        }
    }

    // ---- right side -------------------------------------------------------------------

    Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 0

        // memory
        Item {
            width: memText.implicitWidth + 12
            height: root.height

            BarText {
                id: memText
                anchors.centerIn: parent
                color: "#a9b665"
                text: "mem:" + root.memPct + "%"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: memText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["footclient", "-a", "btop", "btop"])
            }
        }

        // battery
        Item {
            visible: root.hasBattery
            width: visible ? batText.implicitWidth + 12 : 0
            height: root.height

            BarText {
                id: batText
                anchors.centerIn: parent
                text: root.batCharging
                    ? "pow:" + root.batPct + "%"
                    : "bat:" + root.batPct + "%"
                color: !root.batCharging && root.batPct <= 15 ? "#ea6962"
                    : !root.batCharging && root.batPct <= 30 ? "#e78a4e"
                    : "#7daea3"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: batText.opacity = containsMouse ? 0.75 : 1.0
            }
        }

        // control center
        Item {
            width: ctrlText.implicitWidth + 12
            height: root.height

            BarText {
                id: ctrlText
                anchors.centerIn: parent
                color: "#e78a4e"
                text: "ctrl:\uE690"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onContainsMouseChanged: ctrlText.opacity = containsMouse ? 0.75 : 1.0
                onClicked: Quickshell.execDetached(["quickshell", "ipc", "call", "control", "toggle"])
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

                        Behavior on opacity { NumberAnimation { duration: 0 } }
                    }

                    QsMenuAnchor {
                        id: trayMenuAnchor
                        anchor.window: root.QsWindow.window ?? null
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

    // ---- state ------------------------------------------------------------------------

    property var mangoTags: []

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
                    const next = JSON.stringify(arr.map(t => [t.index, t.is_active, t.is_urgent, t.client_count]))
                    const cur = JSON.stringify(root.mangoTags.map(t => [t.index, t.is_active, t.is_urgent, t.client_count]))
                    if (next !== cur) root.mangoTags = arr
                } catch (e) {}
            }
        }
    }
    Process {
        id: wsSwitchProc
        command: ["true"]
    }

    readonly property var mediaFrames:
    [ "▁▃▅▇", "▃▅▇▅", "▅▇▅▃", "▇▅▃▁", "▅▃▁▃", "▃▁▃▅" ]
    readonly property var mediaColors:
        ["#ea6962", "#e78a4e", "#d8a657", "#a9b665", "#7daea3", "#d3869b"]
    property bool audioActive: false
    property int mediaFrameIdx: 0
    property string pauseFrame: ""
    property int pauseOffset: 0
    property bool wasPlaying: true

    function _renderBars(frame, offset) {
        let out = ""
        for (let i = 0; i < frame.length; i++)
            out += "<font color='" + mediaColors[(i + offset) % mediaColors.length] + "'>" + frame[i] + "</font>"
        return out
    }

    Process {
        id: audioWatch
        running: true
        command: ["sh", "-c",
            "while :; do wpctl status 2>/dev/null | grep -q '\\[active\\]' && echo P || echo S; sleep 0.3; done"]
        stdout: SplitParser { onRead: (line) => root.audioActive = line.trim() === "P" }
    }

    onAudioActiveChanged: {
        if (audioActive) {
            wasPlaying = true
            mediaAnimText.text = _renderBars(mediaFrames[mediaFrameIdx], mediaFrameIdx)
        } else {
            if (wasPlaying) {
                pauseFrame = mediaFrames[Math.floor(Math.random() * mediaFrames.length)]
                pauseOffset = Math.floor(Math.random() * mediaColors.length)
                wasPlaying = false
            }
            mediaAnimText.text = _renderBars(pauseFrame, pauseOffset)
        }
    }

    Timer {
        interval: 150; running: root.audioActive; repeat: true
        onTriggered: {
            root.mediaFrameIdx = (root.mediaFrameIdx + 1) % root.mediaFrames.length
            mediaAnimText.text = root._renderBars(
                root.mediaFrames[root.mediaFrameIdx], root.mediaFrameIdx)
        }
    }

    Component.onCompleted: mediaAnimText.text = _renderBars(mediaFrames[0], 0)

    // clock
    QtObject {
        id: clockTime
        property date date: new Date()
    }
    Timer {
        interval: 30000; running: true; triggeredOnStart: true; repeat: true
        onTriggered: clockTime.date = new Date()
    }

    // memory: persistent stream, no repeated forks
    property int memPct: 0
    Process {
        id: memProc
        command: ["sh", "-c",
            "while :; do awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf \"%d\\n\", (1-a/t)*100}' /proc/meminfo; sleep 5; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => { root.memPct = parseInt(line.trim()) || 0 }
        }
    }

    // battery (sysfs): persistent stream
    property bool hasBattery: false
    property int batPct: 0
    property bool batCharging: false
    Process {
        id: batProc
        command: ["sh", "-c",
            "while :; do c=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null); s=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null); echo \"$c $s\"; sleep 10; done"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(" ")
                const cap = parseInt(parts[0])
                const status = parts.slice(1).join(" ")
                root.hasBattery = isFinite(cap)
                if (isFinite(cap)) root.batPct = cap
                root.batCharging = status.indexOf("Charging") >= 0 || status === "Full"
            }
        }
    }
}
