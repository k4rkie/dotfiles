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

    readonly property var wifiDevice: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const d = Networking.devices.values[i]
            if (d.type === DeviceType.Wifi) return d
        }
        return null
    }
    readonly property string wifiSsid: {
        if (wifiCliSsid !== "") return wifiCliSsid
        if (!wifiDevice || !Networking.wifiEnabled) return ""
        for (let i = 0; i < wifiDevice.networks.values.length; i++) {
            const n = wifiDevice.networks.values[i]
            if (n.connected && n.name !== "") return n.name
        }
        return ""
    }

    property string wifiCliSsid: ""
    property var wifiCliNetworks: []
    property bool wifiCliReady: false
    property bool wifiScanning: false
    property var wifiKnownNames: []
    property var wifiProfiles: ({})
    property var wifiForgetQueue: []
    property string wifiListOutput: ""

    readonly property var wifiSortedNetworks: {
        const nets = wifiCliReady
            ? wifiCliNetworks : (wifiDevice?.networks.values ?? [])
        return nets.slice().sort((a, b) => b.signalStrength - a.signalStrength)
    }

    property var pendingWifiNet: null

    function wifiSignalGlyph(strength) {
        const pct = strength <= 1 ? strength * 100 : strength
        return pct > 75 ? "󰤨" : pct > 50 ? "󰤥"
            : pct > 25 ? "󰤢" : "󰤟"
    }

    function wifiConnect(net) {
        if (!net || net.stateChanging) return
        if (net.connected) {
            wifiReconnect(net)
            return
        }
        if (typeof net.connect !== "function") {
            if (wifiActionProc.running) return
            if (net.security !== "--" && !net.known) {
                root.pendingWifiNet = net
                return
            }
            wifiActionProc.command = root.wifiConnectCommand(net.name)
            wifiActionProc.running = true
            return
        }
        const secured = net.security !== WifiSecurityType.Open
            && net.security !== WifiSecurityType.Unknown && net.security !== WifiSecurityType.Owe
        if (secured && !net.known) {
            root.pendingWifiNet = net
            return
        }
        net.connect()
    }

    function wifiReconnect(net) {
        if (!net || wifiActionProc.running) return
        wifiActionProc.command = root.wifiConnectCommand(net.name)
        wifiActionProc.running = true
    }

    function wifiConnectCommand(ssid, password) {
        const command = ["nmcli", "device", "wifi", "connect", ssid]
        if (root.wifiDevice && root.wifiDevice.name)
            command.push("ifname", root.wifiDevice.name)
        if (password !== undefined) command.push("password", password)
        return command
    }

    function submitWifiPassword() {
        if (!pendingWifiNet || wifiPskInput.text === "" || wifiActionProc.running) return
        if (typeof pendingWifiNet.connectWithPsk === "function") {
            pendingWifiNet.connectWithPsk(wifiPskInput.text)
        } else {
            wifiActionProc.command = root.wifiConnectCommand(pendingWifiNet.name, wifiPskInput.text)
            wifiActionProc.running = true
        }
        pendingWifiNet = null
    }

    function cancelWifiPassword() {
        pendingWifiNet = null
    }

    function wifiForget(net) {
        if (!net || wifiActionProc.running) return
        if (typeof net.forget === "function") net.forget()
        else {
            const profiles = []
            const profileNames = Object.keys(root.wifiProfiles)
            for (let i = 0; i < profileNames.length; i++) {
                const profileName = profileNames[i]
                if (profileName === net.name || profileName.indexOf(net.name + " ") === 0)
                    profiles.push(...root.wifiProfiles[profileName])
            }
            root.wifiForgetQueue = profiles.map(profile => profile.uuid)
            root.deleteNextWifiProfile()
        }
    }

    function deleteNextWifiProfile() {
        if (wifiActionProc.running || wifiForgetQueue.length === 0) return
        const queue = wifiForgetQueue.slice()
        const uuid = queue.shift()
        root.wifiForgetQueue = queue
        wifiActionProc.command = ["nmcli", "connection", "delete", "uuid", uuid]
        wifiActionProc.running = true
    }

    Process { id: wifiToggleProc; command: ["true"] }
    Process {
        id: wifiActionProc
        command: ["true"]
        onExited: {
            if (root.wifiForgetQueue.length > 0) {
                root.deleteNextWifiProfile()
                return
            }
            if (root.page === "wifi" && Networking.wifiEnabled) {
                wifiKnownProc.exec(wifiKnownProc.command)
                wifiListProc.exec(wifiListProc.command)
            }
        }
    }
    Process {
        id: wifiListProc
        command: ["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                root.wifiListOutput = text
                root.parseWifiList(text)
            }
        }
    }
    Process {
        id: wifiKnownProc
        command: ["nmcli", "-t", "-e", "yes", "-f", "NAME,TYPE,UUID", "connection", "show"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                const names = []
                const profiles = {}
                const lines = text.trim().split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const f = root.splitNmcliLine(lines[i])
                    if (f.length >= 3 && f[1] === "802-11-wireless") {
                        names.push(f[0])
                        if (!profiles[f[0]]) profiles[f[0]] = []
                        profiles[f[0]].push({ name: f[0], uuid: f[2] })
                    }
                }
                root.wifiKnownNames = names
                root.wifiProfiles = profiles
                if (root.wifiListOutput !== "") root.parseWifiList(root.wifiListOutput)
            }
        }
    }
    Process {
        id: wifiRescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onStarted: root.wifiScanning = true
        onExited: {
            root.wifiScanning = false
            if (root.page === "wifi" && Networking.wifiEnabled)
                wifiListProc.exec(wifiListProc.command)
        }
    }

    function splitNmcliLine(line) {
        const fields = []
        let field = ""
        let escaped = false
        for (let i = 0; i < line.length; i++) {
            const c = line[i]
            if (escaped) { field += c; escaped = false }
            else if (c === "\\") escaped = true
            else if (c === ":") { fields.push(field); field = "" }
            else field += c
        }
        if (escaped) field += "\\"
        fields.push(field)
        return fields
    }

    function parseWifiList(output) {
        const result = []
        const lines = output.trim().split("\n")
        for (let i = 0; i < lines.length; i++) {
            if (!lines[i]) continue
            const f = root.splitNmcliLine(lines[i])
            if (f.length < 4 || f[1] === "") continue
            result.push({
                name: f[1], signalStrength: Number(f[2]) || 0,
                security: f[3] || "--", connected: f[0] === "*",
                stateChanging: false,
                known: root.wifiProfiles[f[1]] !== undefined
            })
            if (f[0] === "*") root.wifiCliSsid = f[1]
        }
        root.wifiCliNetworks = result
        root.wifiCliReady = true
        if (result.every(n => !n.connected)) root.wifiCliSsid = ""
    }

    function toggleWifi() {
        if (wifiToggleProc.running) return
        wifiToggleProc.command = ["nmcli", "radio", "wifi",
            Networking.wifiEnabled ? "off" : "on"]
        wifiToggleProc.running = true
    }

    function kickWifiScan() {
        if (!Networking.wifiEnabled) return
        if (!wifiKnownProc.running) wifiKnownProc.running = true
        if (!wifiListProc.running) wifiListProc.running = true
        if (!wifiRescanProc.running) {
            root.wifiScanning = true
            wifiRescanProc.running = true
        }
    }

    Timer {
        id: wifiKickTimer
        interval: 4000
        running: root.page === "wifi"
        repeat: true
        onTriggered: root.kickWifiScan()
    }

    Timer {
        id: wifiRecoverTimer
        interval: 2000
        onTriggered: root.kickWifiScan()
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() {
            if (!Networking.wifiEnabled) {
                root.wifiCliReady = false
                root.wifiCliSsid = ""
            }
            if (root.page === "wifi") wifiRecoverTimer.restart()
        }
    }

    // ---- bluetooth ---------------------------------------------------------

    readonly property var btAdapter: Bluetooth.defaultAdapter

    property string btCliState: "unknown"
    Process {
        id: btStateProc
        command: ["true"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.btCliState = text.trim()
        }
    }
    Process { id: btToggleProc; command: ["true"] }

    Timer {
        id: queryBtTimer
        interval: 1500
        onTriggered: root.queryBtState()
    }

    function queryBtState() {
        if (root.btAdapter) return
        btStateProc.command = ["bash", "-c",
            "if ! bluetoothctl list 2>/dev/null | grep -q Controller; then echo none; " +
            "elif bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then echo on; " +
            "else echo off; fi"]
        btStateProc.running = true
    }

    function toggleBluetooth() {
        if (btAdapter) {
            btAdapter.enabled = !btAdapter.enabled
            return
        }
        btToggleProc.command = ["bash", "-c",
            "if ! bluetoothctl list 2>/dev/null | grep -q Controller; then echo none; " +
            "elif bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then bluetoothctl power off; echo off; " +
            "else rfkill unblock bluetooth; sleep 0.3; bluetoothctl power on; echo on; fi"]
        btToggleProc.running = true
        queryBtTimer.restart()
        btScanResumeTimer.restart()
    }

    Timer {
        id: btScanResumeTimer
        interval: 1600
        onTriggered: {
            if (root.page === "bluetooth" && root.btCliState === "on")
                root.btCliSetScanning(true)
        }
    }

    readonly property bool btPowered: (btAdapter?.enabled ?? false) || btCliState === "on"

    property var btCliDevices: []
    Process {
        id: btCliListProc
        command: ["true"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseBtCliDevices(text)
        }
    }
    Process { id: btCliScanProc; command: ["true"] }
    Process { id: btCliActionProc; command: ["true"] }

    Timer {
        id: btCliRefreshTimer
        interval: 2500
        running: root.page === "bluetooth" && root.btAdapter === null
        repeat: true
        onTriggered: {
            root.refreshBtCliDevices()
            if (root.btCliState === "none") root.queryBtState()
        }
    }

    function parseBtCliDevices(text) {
        const pairedSet = {}
        const connMap = {}
        const all = []
        let section = ""
        for (const line of text.split("\n")) {
            if (line === "==PAIRED==" || line === "==ALL==" || line === "==CONN==") {
                section = line
                continue
            }
            let m
            if ((m = line.match(/^Device (\S+) (.*)$/))) {
                if (section === "==PAIRED==") pairedSet[m[1]] = true
                else if (section === "==ALL==")
                    all.push({ mac: m[1], name: m[2], address: m[1], icon: "", bonded: true,
                        paired: false, connected: false, batteryAvailable: false,
                        battery: 0, pairing: false, state: -1 })
                continue
            }
            if (section === "==CONN==") {
                m = line.match(/^(\S+) (yes|no)$/)
                if (m) connMap[m[1]] = m[2] === "yes"
            }
        }
        for (const d of all) {
            d.paired = !!pairedSet[d.mac]
            d.connected = connMap[d.mac] === true
        }
        root.btCliDevices = all
    }

    function refreshBtCliDevices() {
        btCliListProc.command = ["bash", "-c",
            "echo ==PAIRED==; bluetoothctl devices Paired 2>/dev/null; " +
            "echo ==ALL==; bluetoothctl devices 2>/dev/null; " +
            "echo ==CONN==; bluetoothctl devices 2>/dev/null | while read -r _ mac _; do " +
            "echo \"$mac $(bluetoothctl info \"$mac\" 2>/dev/null | awk '/Connected:/{print $2}')\"; done"]
        btCliListProc.running = true
    }

    function btCliSetScanning(on) {
        btCliScanProc.command = ["bluetoothctl", "scan", on ? "on" : "off"]
        btCliScanProc.running = true
    }

    readonly property var btDeviceList: btAdapter?.devices.values ?? []
    readonly property var btPairedList: btAdapter !== null
        ? btDeviceList.filter(d => d.bonded || d.paired || d.connected)
        : btCliDevices.filter(d => d.paired || d.connected)
    readonly property var btNearbyList: btAdapter !== null
        ? ((btAdapter.discovering ?? false)
            ? btDeviceList.filter(d => !(d.bonded || d.paired || d.connected)) : [])
        : (root.page === "bluetooth"
            ? btCliDevices.filter(d => !d.paired && !d.connected) : [])

    function btDeviceGlyph(iconName) {
        const i = iconName ?? ""
        if (i.includes("headset") || i.includes("headphone") || i.includes("audio")) return "󰋋"
        if (i.includes("keyboard")) return "󰌌"
        if (i.includes("mouse")) return "󰍽"
        if (i.includes("phone")) return "󰄜"
        if (i.includes("watch")) return "󰖉"
        return "󰂯"
    }

    function btBatteryPct(d) {
        if (!d.batteryAvailable) return -1
        return Math.round(d.battery <= 1 ? d.battery * 100 : d.battery)
    }

    function btToggleDevice(d) {
        if (!d) return
        if (root.btAdapter) {
            if (!d.paired && !d.bonded) { d.pair(); return }
            if (d.connected) { d.disconnect(); return }
            d.trusted = true
            d.connect()
            return
        }
        const mac = "\"" + d.mac + "\""
        btCliActionProc.command = ["bash", "-c",
            "if ! bluetoothctl info " + mac + " 2>/dev/null | grep -q 'Paired: yes'; then " +
            "bluetoothctl pair " + mac + " >/dev/null 2>&1; bluetoothctl trust " + mac + " >/dev/null 2>&1; fi; " +
            "if bluetoothctl info " + mac + " 2>/dev/null | grep -q 'Connected: yes'; then " +
            "bluetoothctl disconnect " + mac + " >/dev/null 2>&1; else bluetoothctl connect " + mac + " >/dev/null 2>&1; fi; true"]
        btCliActionProc.running = true
        btCliRefreshTimer.restart()
    }

    function btForgetDevice(d) {
        if (!d) return
        if (root.btAdapter) { d.forget(); return }
        btCliActionProc.command = ["bash", "-c", "bluetoothctl remove \"" + d.mac + "\" >/dev/null 2>&1; true"]
        btCliActionProc.running = true
        btCliRefreshTimer.restart()
    }

    // ---- calendar (moved from standalone CalendarPopup) ----------------------
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
    function _calFirstWeekday(y,m) { return (new Date(y, m, 1).getDay() + 6) % 7 }    function calResetToday() {
        var now = new Date()
        _calTodayDay = now.getDate(); _calTodayMonth = now.getMonth(); _calTodayYear = now.getFullYear()
        _calSelectedDay = -1; _calViewYear = _calTodayYear; _calViewMonth = _calTodayMonth
    }
    // ---- apps page (launcher embedded, 400px list) -----------------------
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
        try { a.execute() } catch(e) { Quickshell.execDetached(["gtk-launch", a.id]) }
        root.close()
    }
    Connections { target: LauncherHiddenApps; function onHiddenAppsChanged() { if (root.page === "apps") ccAppsFilterTimer.restart() } }
    Connections { target: AppUsageTracker; function onUsageMapChanged() { if (root.page === "apps") ccAppsFilterTimer.restart() } }

    // ---- emoji (from LauncherEmojiView, scaled to 460) ---------------------
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
    property alias wifiToggleProc: wifiToggleProc
    property alias wifiActionProc: wifiActionProc
    property alias btToggleProc: btToggleProc
    property alias btStateProc: btStateProc
    property alias emojiCopyProc: emojiCopyProc
    property alias emojiLoaderProc: emojiLoaderProc

        property alias ccAppsFilterTimer: ccAppsFilterTimer

        property alias emojiFilterDebounce: emojiFilterDebounce

        property alias wifiKickTimer: wifiKickTimer

        property alias wifiRecoverTimer: wifiRecoverTimer

        property alias queryBtTimer: queryBtTimer

        property alias btScanResumeTimer: btScanResumeTimer

        property alias btCliRefreshTimer: btCliRefreshTimer

        property alias loadClipboardTimer: loadClipboardTimer

        property alias wifiListProc: wifiListProc

        property alias wifiKnownProc: wifiKnownProc

        property alias wifiRescanProc: wifiRescanProc

        property alias btCliListProc: btCliListProc

        property alias btCliScanProc: btCliScanProc

        property alias btCliActionProc: btCliActionProc

    // ---- window body --------------------------------------------------------------------

    // click outside the card closes the menu
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

            // ---- main page ----


            // ---- pages (modular) ----
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

    // ---- components ---------------------------------------------------------------------

    // flat: no bevel — keep as no-op for compatibility
    component BevelOverlay: Item {
        property bool pressed: false
        anchors.fill: parent
        z: 1
    }

    component HeaderIconButton: Rectangle {
        id: hbtn
        property string iconText: ""
        property bool isActive: false
        signal clicked()
        width: 36; height: 36; radius: 0
        color: isActive ? Qt.darker(PanelColors.rowBackground, 1.2) : (hmouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.35) : PanelColors.rowBackground)
        border.width: 1
        border.color: isActive ? PanelColors.textAccent : PanelColors.border
        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            text: hbtn.iconText
            font.pixelSize: 16; font.family: FontConfig.fontFamily
            color: hmouse.containsMouse || hbtn.isActive ? PanelColors.textAccent : PanelColors.textMain
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: 20; height: 2
            radius: 1
            color: PanelColors.textAccent
            visible: hbtn.isActive
        }
        MouseArea {
            id: hmouse; z: 2; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: hbtn.clicked()
        }
    }

    component Pill: Rectangle {
        id: pill
        property string iconText: ""
        property string labelText: ""
        property bool checked: false
        property bool isActive: false
        property color accentColor: PanelColors.pillActive
        signal clicked()
        signal rightClicked()
        height: 42; radius: 0
        color: {
            if (checked || isActive)
                return pillMouse.containsMouse ? Qt.lighter(accentColor, 1.15) : accentColor
            return pillMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        }
        border.width: 1
        border.color: checked || isActive ? Qt.darker(accentColor, 1.2) : PanelColors.border


        Row {
            anchors.centerIn: parent
            spacing: 7

            Text {
                renderType: Text.NativeRendering
                text: pill.iconText
                font.pixelSize: 16; font.family: FontConfig.fontFamily
                color: pill.checked || pill.isActive ? PanelColors.pillForeground
                    : pillMouse.containsMouse ? PanelColors.textAccent : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
        
            }
            Text {
                renderType: Text.NativeRendering
                text: pill.labelText
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                width: Math.max(0, pill.width - 38)
                elide: Text.ElideRight
                color: pill.checked || pill.isActive ? PanelColors.pillForeground
                    : pillMouse.containsMouse ? PanelColors.textAccent : PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
        
            }
        }

        MouseArea {
            id: pillMouse; z: 2; anchors.fill: parent; hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) pill.rightClicked()
                else pill.clicked()
            }
        }
    }

    component ActionRow: Rectangle {
        id: actRow
        property string iconText: ""
        property string labelText: ""
        property bool danger: false
        signal clicked()
        width: parent.width; height: 46; radius: 0
        color: actMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border


        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                renderType: Text.NativeRendering
                text: actRow.iconText
                font.pixelSize: 16; font.family: FontConfig.fontFamily
                color: actRow.danger ? PanelColors.error : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: actRow.labelText
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                color: actRow.danger ? PanelColors.error : PanelColors.textMain
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: actMouse; z: 2; anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actRow.clicked()
        }
    }

    component ToggleSwitch: Rectangle {
        id: tswitch
        property bool checked: false
        signal toggled()
        width: 34; height: 18; radius: 0
        color: tswitch.checked ? PanelColors.pillActive : PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border

        Rectangle {
            x: tswitch.checked ? parent.width - width - 2 : 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14; radius: 0
            color: tswitch.checked ? PanelColors.pillForeground : PanelColors.textDim

        }
        MouseArea {
            id: tswitchMouse
            z: 2
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tswitch.toggled()
        }
    }

    component Divider: Rectangle {
        width: parent.width
        height: 1
        color: PanelColors.border
    }

}