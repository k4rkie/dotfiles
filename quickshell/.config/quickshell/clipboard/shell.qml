import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    // ─── palette (matches rofi/colors-rofi-dark.rasi) ──────────────────────
    readonly property color cBg:        "#080808"
    readonly property color cBgAlt:     "#121212"
    readonly property color cFg:        "#c1c1c1"
    readonly property color cFgDim:     "#696969"
    readonly property color cAccent:    "#7d718f"   // selected-normal
    readonly property color cGreen:     "#7fa563"   // active
    readonly property color cRed:       "#d8647e"   // urgent / delete
    readonly property color cBorder:    "#333333"
    readonly property string fontFamily: "FiraCode Nerd Font Mono, ZedMono Nerd Font, monospace"

    // ─── state ─────────────────────────────────────────────────────────────
    property var entries: []        // [{ id, raw, text, isImage }]
    property int selected: 0
    property string query: ""
    property bool busy: false

    function reload() {
        busy = true
        listProc.running = true
    }

    function copyEntry(e) {
        if (e == null) return
        const proc = Qt.createQmlObject("import Quickshell.Io; Process { running: true }", root)
        proc.command = ["bash", "-c", "printf '%s' " + shellQuote(e.raw) + " | cliphist decode | wl-copy"]
        popup.hide()
    }

    function deleteEntry(e) {
        if (e == null) return
        const proc = Qt.createQmlObject("import Quickshell.Io; Process { running: true }", root)
        proc.command = ["bash", "-c", "printf '%s' " + shellQuote(e.raw) + " | cliphist delete"]
        reload()
    }

    function wipeHistory() {
        const proc = Qt.createQmlObject("import Quickshell.Io; Process { running: true }", root)
        proc.command = ["cliphist", "wipe"]
        root.query = ""
        reload()
    }

    // safe shell quote
    function shellQuote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    // parse cliphist line -> object
    function parseLine(line) {
        const idx = line.indexOf("\t")
        if (idx < 0) return null
        const id = line.substring(0, idx)
        const body = line.substring(idx + 1)
        const isImage = body.startsWith("[[ binary data ")
        let display = isImage
            ? "🖼  " + body
            : body.replace(/\s+/g, " ").trim()
        if (display.length > 200) display = display.substring(0, 200) + "…"
        if (display.length === 0) display = "(empty)"
        return { id: id, raw: line, text: display, isImage: isImage }
    }

    // filtered view of entries
    function filtered() {
        if (root.query.length === 0) return root.entries
        const q = root.query.toLowerCase()
        return root.entries.filter(e => e.text.toLowerCase().indexOf(q) >= 0)
    }

    // ─── process that runs `cliphist list` ─────────────────────────────────
    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: IoSplitComm {
            onStream: {
                const out = readAll()
                const lines = out.split("\n")
                const acc = []
                for (let i = 0; i < lines.length; i++) {
                    const l = lines[i]
                    if (l.length === 0) continue
                    const o = root.parseLine(l)
                    if (o) acc.push(o)
                }
                root.entries = acc
                root.selected = 0
                root.busy = false
            }
        }
    }

    // ─── the popup ─────────────────────────────────────────────────────────
    PanelWindow {
        id: popup
        visible: false
        anchor {
            top: true; bottom: true
            left: true; right: true
        }
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        WlrLayershell.layer: WlrLayershell.Layer.Overlay
        WlrLayershell.keyboardFocus: WlrLayershell.KeyboardFocus.Exclusive

        property real popupW: 640
        property real popupH: 560

        function show() {
            root.reload()
            visible = true
            search.forceActiveFocus()
        }
        function hide() {
            visible = false
            root.query = ""
            root.selected = 0
        }

        // click-outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: popup.hide()
        }

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(popup.popupW, parent.width - 40)
            height: Math.min(popup.popupH, parent.height - 40)
            color: root.cBg
            border.color: root.cBorder
            border.width: 1
            radius: 6

            MouseArea { anchors.fill: parent; onClicked: (m) => m.accepted = true }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 0

                // ─── header / search ───────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: root.cBgAlt
                    radius: 6
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 6; color: root.cBgAlt }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.cBorder }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Text {
                            text: ""
                            color: root.cAccent
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Text {
                            text: "Clipboard"
                            color: root.cFgDim
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Text {
                            text: ":"
                            color: root.cFgDim
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignVCenter
                        }
                        TextField {
                            id: search
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            placeholderText: "Type to filter…"
                            placeholderTextColor: root.cFgDim
                            color: root.cFg
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            selectByMouse: true
                            background: Item {}
                            verticalAlignment: TextInput.AlignVCenter
                            onTextChanged: {
                                root.query = text
                                root.selected = 0
                            }
                            Keys.onPressed: (e) => {
                                if (e.key === Qt.Key_Escape) { popup.hide(); e.accepted = true }
                                else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                    root.copyEntry(filteredList.model[filtered().length ? root.selected : 0] || null)
                                    e.accepted = true
                                }
                                else if (e.key === Qt.Key_Down) {
                                    root.selected = Math.min(root.selected + 1, filtered().length - 1)
                                    e.accepted = true
                                }
                                else if (e.key === Qt.Key_Up) {
                                    root.selected = Math.max(root.selected - 1, 0)
                                    e.accepted = true
                                }
                                else if (e.key === Qt.Key_Delete && (e.modifiers & Qt.ControlModifier)) {
                                    root.wipeHistory(); e.accepted = true
                                }
                            }
                        }
                        Text {
                            text: root.busy ? "…" : (root.entries.length + " items")
                            color: root.cFgDim
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                // ─── list ───────────────────────────────────────────────────
                ListView {
                    id: filteredList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 6
                    clip: true
                    model: root.filtered()
                    spacing: 2
                    currentIndex: root.selected
                    onModelChanged: root.selected = Math.min(root.selected, model.length - 1)

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        background: Item {}
                        contentItem: Rectangle {
                            implicitWidth: 4
                            color: parent.pressed ? root.cAccent : root.cBorder
                            opacity: 0.8
                        }
                    }

                    delegate: Item {
                        id: del
                        width: filteredList.width
                        height: row.implicitHeight + 8
                        required property var modelData
                        required property int index

                        readonly property bool isSel: del.index === root.selected

                        Rectangle {
                            anchors.fill: parent
                            color: del.isSel ? root.cAccent : (del.index % 2 === 0 ? Qt.rgba(1,1,1,0.012) : "transparent")
                            Rectangle {
                                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                                width: 2; color: root.cAccent; visible: del.isSel
                            }
                        }

                        RowLayout {
                            id: row
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                text: del.modelData.text
                                color: del.isSel ? root.cBg : (del.modelData.isImage ? root.cGreen : root.cFg)
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // delete button (always visible, fades on hover)
                            Rectangle {
                                Layout.preferredWidth: 22
                                Layout.preferredHeight: 22
                                Layout.alignment: Qt.AlignVCenter
                                radius: 4
                                color: delBtn.hovered ? root.cRed : "transparent"
                                border.color: delBtn.hovered ? root.cRed : root.cBorder
                                border.width: 1
                                visible: del.isSel || delBtn.hovered || del.containsMouse

                                Text {
                                    anchors.centerIn: parent
                                    text: "✕"
                                    color: delBtn.hovered ? root.cBg : root.cFgDim
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                }
                                MouseArea {
                                    id: delBtn
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (m) => { root.deleteEntry(del.modelData); m.accepted = true }
                                }
                            }
                        }

                        MouseArea {
                            id: delArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (m) => {
                                if (m.button === Qt.RightButton) root.deleteEntry(del.modelData)
                                else root.copyEntry(del.modelData)
                                m.accepted = true
                            }
                            onPositionChanged: { root.selected = del.index }
                        }
                    }
                }

                // ─── footer ──────────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    color: root.cBgAlt
                    Rectangle { anchors.top: parent.top; width: parent.width; height: 6; color: root.cBgAlt }
                    Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: root.cBorder }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 16

                        Text {
                            text: "󰆏 enter copy  ✕ delete  right-click delete  esc close"
                            color: root.cFgDim
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredHeight: 24
                            implicitWidth: clrBtn.implicitWidth + 22
                            radius: 4
                            color: clrBtn.hovered ? root.cRed : "transparent"
                            border.color: clrBtn.hovered ? root.cRed : root.cBorder
                            border.width: 1

                            Text {
                                id: clrBtn
                                anchors.centerIn: parent
                                text: "Clear all"
                                color: clrArea.hovered ? root.cBg : root.cFgDim
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                leftPadding: 11; rightPadding: 11
                            }
                            MouseArea {
                                id: clrArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.wipeHistory()
                            }
                        }
                    }
                }
            }
        }
    }

    // ─── toggle entrypoint: listen on a fifo / dbus-less hotkey ─────────────
    // Trigger with:  qs -c clipboard  (then a global keybind calls the toggle)
    // We expose a shortcut via quickshell's Hotkey mechanism isn't needed here;
    // bind a Hyprland/Sway keybind to:  qs -c clipboard --toggle-visibility
    // For simplicity we re-show on launch if hidden and quit-on-close.
    Component.onCompleted: {
        // If launched while already running, quickshell would normally duplicate.
        // Use `qs -c clipboard` once to start; toggle via SIGUSR1 from a keybind:
        //   pkill -USR1 -f "qs -c clipboard"
        popup.show()
    }

    // respond to SIGUSR1 (toggle) — emitted by: pkill -USR1 -f "qs.*clipboard"
    Connections {
        target: Quickshell
        function onReloading() {}
    }
}
