import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Widgets
import "../theme"
import "apps"
import "pages"
import "components"
import "services"

PanelWindow {
    id: root
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors { left: true; right: true; bottom: true }
    implicitHeight: menuCard.height + 16 + bottomBarHeight
    WlrLayershell.namespace: "quickshell:control"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
    }

    property string animState: "closed"
    visible: animState !== "closed"
    onAnimStateChanged: if (animState === "closed") { ccAppsSearch = ""; ccAppsFiltered = []; ccAppsSelected = -1; _emojiQuery = ""; emojiFiltered = []; }

    property string page: "main"

    function open() {
        if (animState === "open") return
        animState = "open"
        page = "main"
        queryBtState()
    }

    function close() {
        if (animState !== "open") return
        animState = "closing"
        closeDelay.restart()
    }
    Timer { id: closeDelay; interval: 200; onTriggered: root.animState = "closed" }

    function toggle() {
        if (animState === "open") close()
        else open()
    }

    property real slideOffset: 0
    readonly property int bottomBarHeight: 24
    IpcHandler {
        target: "control"
        function toggle(): void { root.toggle() }
        function open(): void { root.open() }
        function close(): void { root.close() }
        function openMain(): void { root.openPage("main") }
        function openPower(): void { root.openPage("power") }
        function openClipboard(): void { root.openPage("clipboard") }
        function openWallpaper(): void { root.openPage("wallpaper") }
        function openWifi(): void { root.openPage("wifi") }
        function openBluetooth(): void { root.openPage("bluetooth") }
        function openNotifications(): void { root.openPage("notifications") }
        function openCalendar(): void { root.openCalendarPage() }
        function openApps(): void {
            if (root.page === "apps" && root.animState === "open") { root.close(); return }
            root.ccAppsSearch = ""; root._updateCcAppsFilter(); root.open(); root.page = "apps"
        }
        function openEmoji(): void {
            if (root.page === "emoji" && root.animState === "open") { root.close(); return }
            root._emojiQuery = ""; root.emojiLoad(); root.open(); root.page = "emoji"
        }
    }
    IpcHandler {
        target: "calendar"
        function toggle(): void { root.openCalendarPage() }
        function open(): void { root.openCalendarPage() }
        function close(): void { if (root.page === "calendar") root.close() }
    }
    Connections {
        target: BarAnchor
        function onToggleControl() { root.toggle() }
        function onToggleCalendar() { root.openCalendarPage() }
    }

    // kept for the waybar media button; opens the control center
    IpcHandler {
        target: "media"
        function toggle(): void { root.toggle() }
    }

    // Open (or refocus) the menu directly on a given page.
    function openPage(p) {
        if (animState === "open" && page === p) {
            close()
            return
        }
        open()
        page = p
        if (p === "calendar") calResetToday()
        else if (p === "clipboard") loadClipboard()
        else if (p === "wallpaper") loadWallpapers()
    }
    function openCalendarPage() {
        if (animState === "open" && page === "calendar") { close(); return }
        calResetToday()
        open()
        page = "calendar"
    }

    // ---- identity --------------------------------------------------------

    readonly property string userName: Quickshell.env("USER")
    readonly property string avatarPath: "/home/" + userName + "/.face"
    property string hostName: ""
    FileView {
        path: "/etc/hostname"
        printErrors: false
        onLoaded: root.hostName = text().trim()
    }

    // ---- wifi --------------------------------------------------------------
    // Logic lives in services/WifiService.qml (extracted move-only).
    // Forwards below keep the controlRoot.* API unchanged for pages.

    WifiService {
        id: wifiService
        page: root.page
        animState: root.animState
    }

    property alias wifiDevice: wifiService.wifiDevice
    property alias wifiSsid: wifiService.wifiSsid
    property alias wifiCliSsid: wifiService.wifiCliSsid
    property alias wifiCliNetworks: wifiService.wifiCliNetworks
    property alias wifiCliReady: wifiService.wifiCliReady
    property alias wifiScanning: wifiService.wifiScanning
    property alias wifiKnownNames: wifiService.wifiKnownNames
    property alias wifiProfiles: wifiService.wifiProfiles
    property alias wifiForgetQueue: wifiService.wifiForgetQueue
    property alias wifiListOutput: wifiService.wifiListOutput
    property alias wifiLastRescanMs: wifiService.wifiLastRescanMs
    property alias wifiRescanCooldownMs: wifiService.wifiRescanCooldownMs
    property alias wifiSortedNetworks: wifiService.wifiSortedNetworks
    property alias pendingWifiNet: wifiService.pendingWifiNet
    property alias wifiIpAddress: wifiService.wifiIpAddress
    property alias wifiToggleProc: wifiService.wifiToggleProc
    property alias wifiActionProc: wifiService.wifiActionProc
    property alias wifiListProc: wifiService.wifiListProc
    property alias wifiKnownProc: wifiService.wifiKnownProc
    property alias wifiRescanProc: wifiService.wifiRescanProc
    property alias wifiIpProc: wifiService.wifiIpProc
    property alias wifiKickTimer: wifiService.wifiKickTimer
    property alias wifiRecoverTimer: wifiService.wifiRecoverTimer
    function wifiSignalGlyph(strength) { return wifiService.wifiSignalGlyph(strength); }
    function wifiConnect(net) { return wifiService.wifiConnect(net); }
    function wifiReconnect(net) { return wifiService.wifiReconnect(net); }
    function wifiConnectCommand(ssid, password) { return wifiService.wifiConnectCommand(ssid, password); }
    function submitWifiPassword() { return wifiService.submitWifiPassword(); }
    function cancelWifiPassword() { return wifiService.cancelWifiPassword(); }
    function wifiForget(net) { return wifiService.wifiForget(net); }
    function deleteNextWifiProfile() { return wifiService.deleteNextWifiProfile(); }
    function splitNmcliLine(line) { return wifiService.splitNmcliLine(line); }
    function parseWifiList(output) { return wifiService.parseWifiList(output); }
    function toggleWifi() { return wifiService.toggleWifi(); }
    function refreshWifiCache() { return wifiService.refreshWifiCache(); }
    function kickWifiScan(force) { return wifiService.kickWifiScan(force); }
    function wifiDisconnect() { return wifiService.wifiDisconnect(); }
    function updateWifiIp() { return wifiService.updateWifiIp(); }

    // ---- bluetooth ---------------------------------------------------------
    // Logic lives in services/BluetoothService.qml (extracted move-only).
    // Forwards below keep the controlRoot.* API unchanged for pages.

    BluetoothService {
        id: btService
        page: root.page
        animState: root.animState
    }

    property alias btAdapter: btService.btAdapter
    property alias btCliState: btService.btCliState
    property alias btCliDevices: btService.btCliDevices
    property alias btPowered: btService.btPowered
    property alias btHasAdapter: btService.btHasAdapter
    property alias btDeviceList: btService.btDeviceList
    property alias btPairedList: btService.btPairedList
    property alias btNearbyList: btService.btNearbyList
    property alias btConnectedName: btService.btConnectedName
    property alias btStateProc: btService.btStateProc
    property alias btToggleProc: btService.btToggleProc
    property alias btCliListProc: btService.btCliListProc
    property alias btCliScanProc: btService.btCliScanProc
    property alias btCliActionProc: btService.btCliActionProc
    property alias queryBtTimer: btService.queryBtTimer
    property alias btScanResumeTimer: btService.btScanResumeTimer
    property alias btCliRefreshTimer: btService.btCliRefreshTimer
    function queryBtState() { return btService.queryBtState(); }
    function toggleBluetooth() { return btService.toggleBluetooth(); }
    function parseBtCliDevices(text) { return btService.parseBtCliDevices(text); }
    function refreshBtCliDevices() { return btService.refreshBtCliDevices(); }
    function setBtScanning(on) { return btService.setBtScanning(on); }
    function btDeviceGlyph(iconName, devName) { return btService.btDeviceGlyph(iconName, devName); }
    function btBatteryPct(d) { return btService.btBatteryPct(d); }
    function btToggleDevice(d) { return btService.btToggleDevice(d); }
    function btForgetDevice(d) { return btService.btForgetDevice(d); }

    // ---- calendar ------------------------------------------------------------
    property int _calViewYear: new Date().getFullYear()
    property int _calViewMonth: new Date().getMonth()
    property int _calSelectedDay: -1
    property int _calTodayDay: new Date().getDate()
    property int _calTodayMonth: new Date().getMonth()
    property int _calTodayYear: new Date().getFullYear()
    function calUpdateMonth(delta) { calUpdateMonthRequested(delta) }
    signal calUpdateMonthRequested(int delta)
    function _calMonthName(m) { return ["January","February","March","April","May","June","July","August","September","October","November","December"][m] }
    function _calDaysInMonth(y,m) { return new Date(y, m+1, 0).getDate() }
    function _calFirstWeekday(y,m) { return (new Date(y, m, 1).getDay() + 6) % 7 }
    function calResetToday() {
        var now = new Date()
        _calTodayDay = now.getDate(); _calTodayMonth = now.getMonth(); _calTodayYear = now.getFullYear()
        _calSelectedDay = -1; _calViewYear = _calTodayYear; _calViewMonth = _calTodayMonth
    }
    // ---- apps ----------------------------------------------------------------
    property string ccAppsSearch: ""
    property var ccAppsFiltered: []
    property int ccAppsSelected: -1
    property int ccAppsPage: 0
    readonly property int ccAppsTotalPages: 1
    Timer { id: ccAppsFilterTimer; interval: 10; onTriggered: root._updateCcAppsFilter() }
    function _updateCcAppsFilter() {
        var q = root.ccAppsSearch.toLowerCase()
        var items = []
        var apps = DesktopEntries.applications.values
        for (var i = 0; i < apps.length; i++) {
            var a = apps[i]
            if (!a) continue
            var hidden = LauncherHiddenApps.isHidden(a.id)
            var nameMatch = q === "" || a.name.toLowerCase().includes(q) || (a.genericName && String(a.genericName).toLowerCase().includes(q)) || (a.comment && String(a.comment).toLowerCase().includes(q)) || (a.keywords && String(a.keywords).toLowerCase().includes(q))
            var isMatch = !hidden && nameMatch
            if (isMatch) items.push({ idx: i, usage: AppUsageTracker.getUsage(a.id), name: a.name.toLowerCase() })
        }
        items.sort(function(a,b){ if (b.usage !== a.usage) return b.usage - a.usage; return a.name.localeCompare(b.name) })
        var mapped = []
        for (var j=0;j<items.length;j++) mapped.push(items[j].idx)
        root.ccAppsFiltered = mapped
        if (mapped.length > 0) root.ccAppsSelected = mapped[0]
        else root.ccAppsSelected = -1
        root.ccAppsPage = 0
    }
    function ccAppsLaunch(idx) {
        if (idx < 0) return
        var a = DesktopEntries.applications.values[idx]
        if (!a) return
        AppUsageTracker.recordLaunch(a.id)
        try {
            if (a.runInTerminal) {
                // portable: respect $TERMINAL, then xdg-terminal-exec/spec, then common terminals
                // Quickshell's execute() ignores runInTerminal, so we wrap manually
                var wd = a.workingDirectory
                var shCode = 'term="${TERMINAL:-}";'
                    + 'if [ -z "$term" ] && command -v xdg-terminal-exec >/dev/null 2>&1; then exec xdg-terminal-exec "$@"; fi;'
                    + 'if [ -z "$term" ] && command -v xdg-terminal >/dev/null 2>&1; then exec xdg-terminal -- "$@"; fi;'
                    + 'if [ -z "$term" ]; then for c in foot kitty alacritty wezterm ghostty gnome-terminal konsole xfce4-terminal xterm; do if command -v "$c" >/dev/null 2>&1; then term="$c"; break; fi; done; fi;'
                    + 'if [ -z "$term" ]; then echo "no terminal found for Terminal=true: $*" >&2; exit 1; fi;'
                    + 'case "$term" in gnome-terminal|konsole) exec "$term" -- "$@";; xfce4-terminal) exec "$term" -e "$*";; *) exec "$term" -e "$@";; esac'
                Quickshell.execDetached({ command: ["bash", "-c", shCode, "bash"].concat(a.command), workingDirectory: wd })
            } else {
                Quickshell.execDetached({ command: a.command, workingDirectory: a.workingDirectory })
            }
        } catch(e) { Quickshell.execDetached(["gtk-launch", a.id]) }
        root.close()
    }
    Connections { target: LauncherHiddenApps; function onHiddenAppsChanged() { if (root.page === "apps") ccAppsFilterTimer.restart() } }
    Connections { target: AppUsageTracker; function onUsageMapChanged() { if (root.page === "apps") ccAppsFilterTimer.restart() } }

    // ---- emoji ---------------------------------------------------------------
    property var _emojiAll: []
    property var emojiFiltered: []
    property string _emojiQuery: ""
    property int emojiSelected: 0
    Timer { id: emojiFilterDebounce; interval: 40; onTriggered: root._doEmojiFilter() }
    function _applyEmojiFilter() { emojiFilterDebounce.restart() }
    function _doEmojiFilter() {
        var q = _emojiQuery.toLowerCase()
        emojiFiltered = q === "" ? _emojiAll : _emojiAll.filter(function(e){ return e.name.includes(q) })
        emojiSelected = 0
    }
    function emojiLoad() {
        if (_emojiAll.length > 0) { _doEmojiFilter(); return }
        emojiLoaderProc.running = true
    }
    Process {
        id: emojiLoaderProc
        command: ["cat", Quickshell.shellDir + "/assets/emoji.json"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try { root._emojiAll = JSON.parse(text); root._doEmojiFilter() } catch(e) { console.warn("emoji load failed", e) }
            }
        }
    }
    Process { id: emojiCopyProc; command: ["true"]; function copyEmoji(ch) { command = ["bash","-c","printf '%s' '" + ch + "' | wl-copy"]; running = true } }

    // ---- caffeine ----------------------------------------------------------

    property bool cafOn: false
    FileView {
        path: "/tmp/caffeine"
        watchChanges: true
        printErrors: false
        onLoaded: root.cafOn = true
        onLoadFailed: root.cafOn = false
        onFileChanged: reload()
    }
    Process { id: cafProc; command: [Quickshell.env("HOME") + "/scripts/caffeine-toggle.sh"] }

    // ---- notifications -----------------------------------------------------
    // Backend lives in the NotifState singleton so NotifPopup.qml shares it.

    property bool dndOn: NotifState.dndOn
    readonly property var notificationHistory: NotifState.history

    function removeNotification(idx) { NotifState.removeNotification(idx) }
    function clearNotifications() { NotifState.clearNotifications() }

    function fmtNotiTime(ts) {
        if (!ts) return ""
        var d = new Date(ts)
        var h = d.getHours()
        var m = d.getMinutes()
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
    }

    // ---- clipboard page -------------------------------------------------------------

    property var clipEntries: []
    function loadClipboard() {
        clipListProc.running = false
        clipListProc.command = ["bash", "-c", "cliphist list | head -n 50"]
        clipListProc.running = true
    }
    Process {
        id: clipListProc
        command: ["true"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var entries = []
                const lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    const line = lines[i]
                    if (line === "") continue
                    const tab = line.indexOf("\t")
                    if (tab < 0) continue
                    const preview = line.substring(tab + 1)
                    entries.push({
                        index: line.substring(0, tab).trim(),
                        preview: preview,
                        raw: line,
                        isImage: preview.startsWith("[[ binary data")
                    })
                }
                root.clipEntries = entries
            }
        }
    }
    Process { id: clipActionProc; command: ["true"] }

    // Queued image decoder: renders [[ binary data entries to tmp pngs so
    // they can be previewed like the launcher's clipboard view.
    property var clipImgQueue: []
    property string clipDecodingId: ""
    property bool clipDecodeReady: false

    function enqueueClipImage(itemId, entry) {
        for (var i = 0; i < clipImgQueue.length; i++)
            if (clipImgQueue[i].itemId === itemId) return
        clipImgQueue.push({ itemId: itemId, entry: entry })
        if (!clipImgProc.running && clipDecodingId === "")
            decodeNextClipImage()
    }

    function decodeNextClipImage() {
        if (clipImgQueue.length === 0) {
            clipDecodingId = ""
            return
        }
        const job = clipImgQueue.shift()
        clipDecodingId = job.itemId
        clipDecodeReady = false
        clipImgProc.command = ["bash", "-c",
            'printf \'%s\' "$1" | cliphist decode > "/tmp/qs-cc-clip-"$2".png" 2>/dev/null; true',
            "clip", job.entry, job.itemId]
        clipImgProc.running = true
    }

    Process {
        id: clipImgProc
        command: ["true"]
        onRunningChanged: {
            if (!running) {
                root.clipDecodeReady = true
                root.decodeNextClipImage()
            }
        }
    }

    function clipCopy(entry) {
        clipActionProc.command = ["bash", "-c",
            'printf \'%s\' "$1" | cliphist decode | wl-copy 2>/dev/null; true', "clip", entry]
        clipActionProc.running = true
    }
    function clipDelete(entry) {
        clipActionProc.command = ["bash", "-c",
            'printf \'%s\' "$1" | cliphist delete 2>/dev/null; true', "clip", entry]
        clipActionProc.running = true
        loadClipboardTimer.restart()
    }

    Timer {
        id: loadClipboardTimer
        interval: 300
        onTriggered: root.loadClipboard()
    }

    // ---- session ----------------------------------------------------------------------

    function runSession(cmd) {
        sessProc.command = ["sh", "-c", cmd]
        sessProc.running = true
    }
    Process { id: sessProc; command: ["true"] }

    // ---- wallpaper page -----------------------------------------------------------------

    property var wallEntries: []
    function loadWallpapers() {
        scanProc.running = false
        scanProc.running = true
    }
    Process {
        id: scanProc
        running: false
        command: [
            "bash", "-c",
            "find \"$HOME/Pictures/Wallpapers\" -type f \\( " +
            "-iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' " +
            "-o -iname '*.gif' -o -iname '*.jxl' -o -iname '*.bmp' \\) 2>/dev/null | sort | sed 's/$/ IMAGE/'; " +
            "find \"$HOME/Videos/Wallpapers\" -type f \\( " +
            "-iname '*.mp4' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.mov' \\) 2>/dev/null | sort | sed 's/$/ VIDEO/'"
        ]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var entries = []
                const lines = text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    const line = lines[i].trim()
                    if (line === "") continue
                    const sp = line.lastIndexOf(" ")
                    const path = line.substring(0, sp).trim()
                    const tag = line.substring(sp + 1)
                    entries.push({
                        filePath: path,
                        wallName: path.split("/").pop().replace(/\.[^/.]+$/, ""),
                        isVideo: tag === "VIDEO"
                    })
                }
                root.wallEntries = entries
            }
        }
    }
    Process {
        id: wallpaperSetProc
        running: false
        command: ["true"]

        function apply(path, isVideo) {
            var p        = path.replace(/'/g, "'\\''")
            var home     = Quickshell.env("HOME")
            var cacheDir = home + "/.cache/quickshell"
            var lockImg  = cacheDir + "/lockscreen.png"
            var lock     = "\"" + lockImg + "\""
            var script

            if (isVideo) {
                script =
                    "pkill -x awww-daemon 2>/dev/null; " +
                    "pkill -x mpvpaper 2>/dev/null; " +
                    "mkdir -p \"" + cacheDir + "\"; " +
                    "echo 'video:" + p + "' > \"" + cacheDir + "/last-wallpaper\"; " +
                    "ffmpeg -y -ss 00:00:01 -i '" + p + "' -vframes 1 " + lock + " >/dev/null 2>&1 & " +
                    "mpvpaper -f -p -o '--loop-file=inf --no-audio --hwdec=auto' ALL '" + p + "'"
            } else {
                script =
                    "p=\"" + p + "\"; " +
                    "pkill -x mpvpaper 2>/dev/null; " +
                    "awww query >/dev/null 2>&1 || { awww-daemon &>/dev/null & " +
                    "for i in $(seq 1 20); do sleep 0.1 && awww query >/dev/null 2>&1 && break; done; }; " +
                    "awww img \"$p\" --transition-type random; " +
                    "cp -f \"$p\" " + lock + "; " +
                    "echo \"$p\" > \"" + cacheDir + "/last-wallpaper\""
            }
            var lockFile = home + "/.config/hypr/hyprlock.conf"
            script += "; " +
                "sed -i '/^background {/,/^}/s|path = .*|path = " + lockImg.replace(/\\/g, "\\\\").replace(/&/g, "\\&") + "|' \"" + lockFile + "\" 2>/dev/null\n" +
                "pkill -USR2 hyprlock 2>/dev/null"

            wallpaperSetProc.command = ["bash", "-c", script]
            wallpaperSetProc.running = false
            wallpaperSetProc.running = true
        }
    }

    // exposed for pages (modular) - must be after ids are defined
    property alias cafProc: cafProc
    property alias sessProc: sessProc
    property alias wallpaperSetProc: wallpaperSetProc
    property alias scanProc: scanProc
    property alias clipListProc: clipListProc
    property alias clipActionProc: clipActionProc
    property alias clipImgProc: clipImgProc
    property alias emojiCopyProc: emojiCopyProc
    property alias emojiLoaderProc: emojiLoaderProc

        property alias ccAppsFilterTimer: ccAppsFilterTimer

        property alias emojiFilterDebounce: emojiFilterDebounce






        property alias loadClipboardTimer: loadClipboardTimer







    // ---- window body ---------------------------------------------------------

    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: menuCard
        x: (parent.width - width) / 2
        y: 12
        width: 460
        height: contentCol.implicitHeight + 24
        radius: 0
        color: PanelColors.popupBackground
        border.color: PanelColors.popupBackground
        border.width: 1

         MouseArea { anchors.fill: parent; onPressed: (m) => m.accepted = true }

         Column {
            id: contentCol
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            spacing: 14

            // ---- profile header ----

            Item {
                width: parent.width
                height: 48

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    Rectangle {
                        width: 48; height: 48
                        color: "transparent"
                        border.width: 1
                        border.color: PanelColors.profile
                        visible: !avatarImg.visible

                        Text {
                            renderType: Text.NativeRendering
                            anchors.centerIn: parent
                            text: root.userName !== "" ? root.userName.charAt(0).toUpperCase() : "?"
                            font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textAccent
                        }
                    }

                    Image {
                        id: avatarImg
                        width: 48; height: 48
                        source: "file://" + root.avatarPath
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        visible: status === Image.Ready
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            renderType: Text.NativeRendering
                            text: root.userName
                            font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textAccent
                        }
                        Text {
                            renderType: Text.NativeRendering
                            text: "@" + (root.hostName !== "" ? root.hostName : "nixos")
                            font.pixelSize: 16; font.family: FontConfig.fontFamily
                            color: PanelColors.textDim
                        }
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    HeaderIconButton {
                        iconText: root.dndOn ? "󰂛" : (notificationHistory.count > 0 ? "󱅫" : "󰂚")
                        isActive: root.page === "notifications"
                        onClicked: root.page = root.page === "notifications" ? "main" : "notifications"
                    }
                    HeaderIconButton {
                        iconText: "󰃭"
                        isActive: root.page === "calendar"
                        onClicked: {
                            if (root.page === "calendar") root.page = "main"
                            else { root.calResetToday(); root.page = "calendar" }
                        }
                    }
                    HeaderIconButton {
                        iconText: ""
                        isActive: root.page === "apps"
                        onClicked: {
                            if (root.page === "apps") root.page = "main"
                            else { root.ccAppsSearch = ""; root._updateCcAppsFilter(); root.page = "apps" }
                        }
                    }
                    HeaderIconButton {
                        iconText: "󰞅"
                        isActive: root.page === "emoji"
                        onClicked: {
                            if (root.page === "emoji") root.page = "main"
                            else { root._emojiQuery = ""; root.emojiLoad(); root.page = "emoji" }
                        }
                    }
                    HeaderIconButton {
                        iconText: "󰸉"
                        isActive: root.page === "wallpaper"
                        onClicked: {
                            root.page = root.page === "wallpaper" ? "main" : "wallpaper"
                            if (root.page === "wallpaper") root.loadWallpapers()
                        }
                    }
                    HeaderIconButton {
                        iconText: "󰅌"
                        isActive: root.page === "clipboard"
                        onClicked: {
                            root.page = root.page === "clipboard" ? "main" : "clipboard"
                            if (root.page === "clipboard") root.loadClipboard()
                        }
                    }
                    HeaderIconButton {
                        iconText: "󰐥"
                        isActive: root.page === "power"
                        onClicked: root.page = root.page === "power" ? "main" : "power"
                    }
                }
            }

            Divider {}

            MainPage { controlRoot: root; visible: root.page === "main" }
            CalendarPage { controlRoot: root; visible: root.page === "calendar" }
            AppsPage { controlRoot: root; visible: root.page === "apps" }
            EmojiPage { controlRoot: root; visible: root.page === "emoji" }
            NotificationsPage { controlRoot: root; visible: root.page === "notifications" }
            WifiPage { controlRoot: root; visible: root.page === "wifi" }
            BluetoothPage { controlRoot: root; visible: root.page === "bluetooth" }
            PowerPage { controlRoot: root; visible: root.page === "power" }
            ClipboardPage { controlRoot: root; visible: root.page === "clipboard" }
            WallpaperPage { controlRoot: root; visible: root.page === "wallpaper" }

        }
    }

}