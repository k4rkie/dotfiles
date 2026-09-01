import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import "../theme"

PanelWindow {
    id: root
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; left: true; right: true; bottom: true }

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
    }

    property string animState: "closed"
    visible: animState !== "closed"

    property string page: "main"

    function open() {
        if (animState === "open") return
        animState = "open"
        page = "main"
        queryBtState()
        closeAnim.stop()
        openAnim.restart()
    }

    function close() {
        if (animState !== "open") return
        animState = "closing"
        openAnim.stop()
        closeAnim.restart()
    }

    function toggle() {
        if (animState === "open") close()
        else open()
    }

    SequentialAnimation {
        id: openAnim
        ScriptAction { script: { root.slideOffset = 60; menuCard.opacity = 0 } }
        ParallelAnimation {
            NumberAnimation { target: root; property: "slideOffset"; to: 0; duration: 0; easing.type: Easing.OutExpo }
            NumberAnimation { target: menuCard; property: "opacity"; to: 1; duration: 0; easing.type: Easing.OutQuad }
        }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "slideOffset"; to: 60; duration: 0; easing.type: Easing.InQuad }
            NumberAnimation { target: menuCard; property: "opacity"; to: 0; duration: 0; easing.type: Easing.InQuad }
        }
        ScriptAction { script: { root.animState = "closed"; root.slideOffset = 0; menuCard.opacity = 1 } }
    }

    property real slideOffset: 0

    readonly property int bottomBarHeight: 38
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
        if (p === "clipboard") loadClipboard()
        else if (p === "wallpaper") loadWallpapers()
    }

    // ---- identity --------------------------------------------------------

    readonly property string userName: Quickshell.env("USER")
    readonly property string avatarPath: "/var/lib/AccountsService/icons/" + userName
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

    // ---- window body --------------------------------------------------------------------

    // click outside the card closes the menu
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    Rectangle {
        id: menuCard
        x: parent.width - width - 8 - 30
        y: parent.height - height - 8 - root.bottomBarHeight - root.slideOffset
        width: 400
        height: contentCol.implicitHeight + 24
        radius: 0
        color: PanelColors.popupBackground
        border.color: "#090909"
        border.width: 2

        Behavior on height { NumberAnimation { duration: 0; easing.type: Easing.OutCubic } }

         MouseArea { anchors.fill: parent; onPressed: (m) => m.accepted = true }

         Rectangle {
             z: 2
             anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 2 }
             height: 2
             color: "#303030"
         }
         Rectangle {
             z: 2
             anchors { top: parent.top; left: parent.left; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }
             width: 2
             color: "#242424"
         }
         Rectangle {
             z: 2
             anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 2 }
             height: 2
             color: "#000000"
         }
         Rectangle {
             z: 2
             anchors { top: parent.top; right: parent.right; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }
             width: 2
             color: "#000000"
         }

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
                        width: 48; height: 48; radius: 24
                        color: "transparent"
                        border.width: 1
                        border.color: PanelColors.profile

                        Rectangle {
                            anchors.fill: parent; anchors.margins: 1
                            radius: width / 2
                            color: PanelColors.rowBackground
                            clip: true

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                source: "file://" + root.avatarPath
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                visible: status === Image.Ready
                            }
                            Text {
                                renderType: Text.NativeRendering
                                anchors.centerIn: parent
                                visible: !avatarImg.visible
                                text: root.userName !== "" ? root.userName.charAt(0).toUpperCase() : "?"
                                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                                color: PanelColors.textAccent
                            }
                        }
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

            Column {
                width: parent.width
                spacing: 14
                visible: root.page === "main"

                Row {
                    spacing: 8
                    width: parent.width

                    Pill {
                        width: (parent.width - parent.spacing) / 2
                        iconText: Networking.wifiEnabled ? "󰤨" : "󰤭"
                        labelText: root.wifiSsid !== "" ? root.wifiSsid : "Disconnected"
                        checked: Networking.wifiEnabled
                        onClicked: root.toggleWifi()
                        onRightClicked: root.openPage("wifi")
                    }

                    Pill {
                        width: (parent.width - parent.spacing) / 2
                        iconText: checked ? "󰂯" : "󰂲"
                        labelText: btAdapter ? ((btAdapter.enabled ?? false) ? "On" : "Off")
                            : root.btCliState === "on" ? "On"
                            : root.btCliState === "off" ? "Off"
                            : "No adapter"
                        checked: btAdapter ? (btAdapter.enabled ?? false) : root.btCliState === "on"
                        onClicked: root.toggleBluetooth()
                        onRightClicked: root.openPage("bluetooth")
                    }
                }

                Row {
                    spacing: 8
                    width: parent.width

                    Pill {
                        width: (parent.width - parent.spacing) / 2
                        iconText: "󰅶"
                        labelText: root.cafOn ? "Caff: on" : "Caff: off"
                        checked: root.cafOn
                        onClicked: cafProc.running = true
                    }

                    Pill {
                        width: (parent.width - parent.spacing) / 2
                        iconText: "󰂛"
                        labelText: root.dndOn ? "DND On" : "DND Off"
                        checked: root.dndOn
                        onClicked: NotifState.dndOn = !NotifState.dndOn
                    }
                }

                Divider {}

                // ---- media ----
                Column {
                    width: parent.width
                    spacing: 6

                    Item {
                        width: parent.width
                        height: 36

                        Text {
                            renderType: Text.NativeRendering
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Media"
                            font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textAccent
                        }

                        Row {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            spacing: 4
                            visible: mediaSection.multiPlayer

                            HeaderIconButton {
                                iconText: "\uF053"
                                onClicked: mediaSection.prevPlayer()
                            }
                            HeaderIconButton {
                                iconText: "\uF054"
                                onClicked: mediaSection.nextPlayer()
                            }
                        }
                    }

                    MediaSection { id: mediaSection; width: parent.width }
                }

            }

            // ---- notifications page ----

            Column {
                width: parent.width
                spacing: 6
                visible: root.page === "notifications"

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Notifications"
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                Text {
                    id: clearNotiText
                        renderType: Text.NativeRendering
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        visible: notificationHistory.count > 0
                        text: "clear all"
                        font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                        color: clearNotiMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                        MouseArea {
                            id: clearNotiMouse
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.clearNotifications()
                        }
                    }
                }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: notificationHistory.count === 0
                    text: "No notifications"
                    font.pixelSize: 16; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 12
                }

                ListView {
                    id: notiList
                    width: parent.width
                    height: Math.min(contentHeight, 300)
                    spacing: 4
                    clip: true
                    interactive: contentHeight > height
                    model: notificationHistory

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: notiList.width
                        height: 44; radius: 0
                        color: notiMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                        Behavior on color { ColorAnimation { duration: 0 } }

                        Row {
                            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                            spacing: 8

                            Rectangle {
                                width: 30; height: 30; radius: 0
                                anchors.verticalCenter: parent.verticalCenter
                                color: PanelColors.rowBackground
                                border.width: 1
                                border.color: PanelColors.border
                                clip: true

                                Image {
                                    anchors.fill: parent; anchors.margins: 2
                                    source: modelData.image !== "" ? modelData.image : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    visible: modelData.image !== ""
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    visible: modelData.image === ""
                                    text: modelData.appName !== "" ? modelData.appName.charAt(0).toUpperCase() : "?"
                                    font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - 30 - notiTimeText.width - parent.spacing * 2

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    text: modelData.appName !== "" ? modelData.appName : "notification"
                                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                    elide: Text.ElideRight
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    text: modelData.summary + (modelData.body !== "" ? " — " + modelData.body : "")
                                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                                    color: PanelColors.textMain
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                id: notiTimeText
                                renderType: Text.NativeRendering
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.fmtNotiTime(modelData.timestamp)
                                font.pixelSize: 12; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                            }
                        }

                        MouseArea {
                            id: notiMouse
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.removeNotification(index)
                        }
                    }
                }
            }

            // ---- wifi page ----

            Column {
                width: parent.width
                spacing: 8
                visible: root.page === "wifi"

                onVisibleChanged: {
                    if (visible) {
                        root.kickWifiScan()
                        wifiRecoverTimer.restart()
                    }
                    if (!visible) root.cancelWifiPassword()
                }

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi"
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                    ToggleSwitch {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        checked: Networking.wifiEnabled
                        onToggled: root.toggleWifi()
                    }
                }

                Item {
                    width: parent.width
                    height: Networking.wifiEnabled ? Math.min(netCol.implicitHeight, 260)
                        : emptyText.implicitHeight + 8

                    Flickable {
                        anchors.fill: parent
                        contentHeight: netCol.implicitHeight
                        clip: true
                        interactive: contentHeight > height
                        visible: Networking.wifiEnabled

                        Column {
                            id: netCol
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: root.wifiSortedNetworks

                                delegate: Rectangle {
                                    id: netRow
                                    required property var modelData

                                    readonly property bool secured:
                                        typeof modelData.security === "string"
                                        ? modelData.security !== "--"
                                        : modelData.security !== WifiSecurityType.Open
                                        && modelData.security !== WifiSecurityType.Unknown
                                        && modelData.security !== WifiSecurityType.Owe

                                    width: netCol.width; height: 34; radius: 0
                                    color: netMouse.containsMouse || root.pendingWifiNet === modelData
                                        ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                                    Behavior on color { ColorAnimation { duration: 0 } }

                                    Row {
                                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                        spacing: 10

                                        Text {
                                            renderType: Text.NativeRendering
                                            text: root.wifiSignalGlyph(netRow.modelData.signalStrength)
                                            font.pixelSize: 15; font.family: FontConfig.fontFamily
                                            color: netRow.modelData.connected ? PanelColors.pillActive : PanelColors.textDim
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            renderType: Text.NativeRendering
                                            text: "󰌾"
                                            visible: netRow.secured
                                            font.pixelSize: 11; font.family: FontConfig.fontFamily
                                            color: PanelColors.textDim
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            renderType: Text.NativeRendering
                                            width: netRow.width - 130
                                            text: netRow.modelData.name !== "" ? netRow.modelData.name : "(hidden network)"
                                            font.pixelSize: 14; font.family: FontConfig.fontFamily
                                            color: netRow.modelData.connected ? PanelColors.textAccent : PanelColors.textMain
                                            elide: Text.ElideRight
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Row {
                                        z: 2
                                        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                        spacing: 12

                                        Text {
                                            renderType: Text.NativeRendering
                                            visible: netRow.modelData.stateChanging
                                                || netRow.modelData.state === ConnectionState.Connecting
                                            text: "connecting…"
                                            font.pixelSize: 12; font.family: FontConfig.fontFamily
                                            color: PanelColors.textDim
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {
                                            renderType: Text.NativeRendering
                                            visible: netRow.modelData.connected && !netRow.modelData.stateChanging
                                            text: "connected"
                                            font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                            color: PanelColors.pillActive
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: netRow.modelData.known && netMouse.containsMouse
                                            text: "forget"
                                            font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                            color: forgetMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                                            MouseArea {
                                                id: forgetMouse
                                                anchors.fill: parent; hoverEnabled: true
                                                z: 2
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    mouse.accepted = true
                                                    root.wifiForget(netRow.modelData)
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: netMouse
                                        anchors.fill: parent; hoverEnabled: true
                                        z: 1
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.wifiConnect(netRow.modelData)
                                    }
                                }
                            }

                            Text {
                                renderType: Text.NativeRendering
                                width: netCol.width
                                visible: root.wifiSortedNetworks.length === 0
                                text: root.wifiScanning ? "scanning for networks…" : "no networks found"
                                font.pixelSize: 13; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                                horizontalAlignment: Text.AlignHCenter
                                topPadding: 8
                            }
                        }
                    }

                    Text {
                        id: emptyText
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        visible: !Networking.wifiEnabled
                        text: "wi-fi is turned off"
                        font.pixelSize: 13; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                    }
                }

                Rectangle {
                    width: parent.width
                    height: visible ? 64 : 0
                    visible: root.pendingWifiNet !== null
                    radius: 0
                    color: Qt.lighter(PanelColors.rowBackground, 1.25)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)

                    Column {
                        anchors { fill: parent; margins: 8 }
                        spacing: 6

                        Text {
                            renderType: Text.NativeRendering
                            property bool enterprise: root.pendingWifiNet !== null
                                && (root.pendingWifiNet.security === WifiSecurityType.WpaEap
                                || root.pendingWifiNet.security === WifiSecurityType.Wpa2Eap)
                            text: "password for \"" + (root.pendingWifiNet?.name ?? "") + "\""
                                + (enterprise ? " (enterprise network)" : "")
                            font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textAccent
                        }

                        Row {
                            spacing: 10

                            Rectangle {
                                width: 210; height: 24; radius: 0
                                color: PanelColors.textBox
                                border.color: wifiPskInput.activeFocus ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.06)

                                TextInput {
                                    id: wifiPskInput
                                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                                    color: PanelColors.textMain
                                    echoMode: TextInput.Password
                                    clip: true
                                    selectByMouse: true
                                    onAccepted: root.submitWifiPassword()
                                    Keys.onEscapePressed: root.cancelWifiPassword()
                                    cursorDelegate: Rectangle { width: 1; height: 14; color: PanelColors.textDim }

                                    Connections {
                                        target: root
                                        function onPendingWifiNetChanged() {
                                            if (root.pendingWifiNet) {
                                                wifiPskInput.text = ""
                                                wifiPskInput.forceActiveFocus()
                                            } else {
                                                wifiPskInput.text = ""
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: "connect"
                                font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                color: pskOk.containsMouse ? PanelColors.pillActive : PanelColors.textDim
                                MouseArea {
                                    id: pskOk
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.submitWifiPassword()
                                }
                            }
                            Text {
                                renderType: Text.NativeRendering
                                text: "cancel"
                                font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                color: pskCancel.containsMouse ? PanelColors.error : PanelColors.textDim
                                MouseArea {
                                    id: pskCancel
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.cancelWifiPassword()
                                }
                            }
                        }
                    }
                }
            }

            // ---- bluetooth page ----

            Column {
                width: parent.width
                spacing: 8
                visible: root.page === "bluetooth"

                onVisibleChanged: {
                    if (root.btAdapter) {
                        root.btAdapter.discovering = visible
                    } else {
                        root.btCliSetScanning(visible)
                        if (visible) root.refreshBtCliDevices()
                    }
                }

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Bluetooth"
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                    ToggleSwitch {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        checked: btAdapter ? (btAdapter.enabled ?? false) : root.btCliState === "on"
                        onToggled: root.toggleBluetooth()
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8
                    visible: btAdapter !== null && root.btPowered

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2; height: 32; radius: 0
                        color: PanelColors.rowBackground
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.04)

                        Text {
                            renderType: Text.NativeRendering
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "Discoverable"
                            font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textMain
                        }
                        ToggleSwitch {
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            checked: btAdapter?.discoverable ?? false
                            onToggled: btAdapter.discoverable = !btAdapter.discoverable
                        }
                    }

                    Rectangle {
                        width: (parent.width - parent.spacing) / 2; height: 32; radius: 0
                        color: PanelColors.rowBackground
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.04)

                        Text {
                            renderType: Text.NativeRendering
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: "Scanning"
                            font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                            color: PanelColors.textMain
                        }
                        ToggleSwitch {
                            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                            checked: btAdapter?.discovering ?? false
                            onToggled: btAdapter.discovering = !btAdapter.discovering
                        }
                    }
                }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: !root.btPowered
                    text: "bluetooth is turned off"
                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 6
                }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: root.btPowered && root.btPairedList.length > 0
                    text: "paired devices"
                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    topPadding: 4
                }

                Item {
                    width: parent.width
                    height: Math.min(btPairedCol.implicitHeight, 190)

                    Flickable {
                        anchors.fill: parent
                        contentHeight: btPairedCol.implicitHeight
                        clip: true
                        interactive: contentHeight > height

                    Column {
                        id: btPairedCol
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: root.btPairedList

                            delegate: Rectangle {
                                id: pairedRow
                                required property var modelData

                                width: btPairedCol.width; height: 36; radius: 0
                                color: devMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                                Behavior on color { ColorAnimation { duration: 0 } }

                                Row {
                                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 10

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: root.btDeviceGlyph(pairedRow.modelData.icon)
                                        font.pixelSize: 15; font.family: FontConfig.fontFamily
                                        color: pairedRow.modelData.connected ? PanelColors.pillActive : PanelColors.textDim
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        width: pairedRow.width - 170
                                        text: pairedRow.modelData.name !== "" ? pairedRow.modelData.name : pairedRow.modelData.address
                                        font.pixelSize: 14; font.family: FontConfig.fontFamily
                                        color: pairedRow.modelData.connected ? PanelColors.textAccent : PanelColors.textMain
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 12

                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: pairedRow.modelData.state === BluetoothDeviceState.Connecting
                                            || pairedRow.modelData.state === BluetoothDeviceState.Disconnecting
                                        text: "…"
                                        font.pixelSize: 12; font.family: FontConfig.fontFamily
                                        color: PanelColors.textDim
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: pairedRow.modelData.batteryAvailable
                                        property int battPct: root.btBatteryPct(pairedRow.modelData)
                                        text: battPct + "%"
                                        font.pixelSize: 12; font.family: FontConfig.fontFamily
                                        color: battPct < 20 ? PanelColors.error : PanelColors.textDim
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: pairedRow.modelData.connected
                                        text: "connected"
                                        font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                        color: PanelColors.pillActive
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: devMouse.containsMouse
                                        text: pairedRow.modelData.connected ? "disconnect" : "connect"
                                        font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                        color: PanelColors.textAccent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: devMouse.containsMouse
                                        text: "remove"
                                        font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                        color: removeMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                                        MouseArea {
                                            id: removeMouse
                                            anchors.fill: parent; hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.btForgetDevice(pairedRow.modelData)
                                        }
                                    }
                                }

                                MouseArea {
                                    id: devMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.btToggleDevice(pairedRow.modelData)
                                }
                            }
                        }
                    }
                        }
                    }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: root.btPowered && root.btNearbyList.length > 0
                    text: "nearby devices"
                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    topPadding: 4
                }

                Item {
                    width: parent.width
                    height: Math.min(btNearbyCol.implicitHeight, 140)

                    Flickable {
                        anchors.fill: parent
                        contentHeight: btNearbyCol.implicitHeight
                        clip: true
                        interactive: contentHeight > height

                    Column {
                        id: btNearbyCol
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: root.btNearbyList

                            delegate: Rectangle {
                                id: nearbyRow
                                required property var modelData

                                width: btNearbyCol.width; height: 34; radius: 0
                                color: nearMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                                Behavior on color { ColorAnimation { duration: 0 } }

                                Row {
                                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 10

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: root.btDeviceGlyph(nearbyRow.modelData.icon)
                                        font.pixelSize: 15; font.family: FontConfig.fontFamily
                                        color: PanelColors.textDim
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        width: nearbyRow.width - 140
                                        text: nearbyRow.modelData.name !== "" ? nearbyRow.modelData.name : nearbyRow.modelData.address
                                        font.pixelSize: 14; font.family: FontConfig.fontFamily
                                        color: PanelColors.textMain
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                    visible: nearbyRow.modelData.pairing
                                    text: "pairing…"
                                    font.pixelSize: 12; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                    visible: !nearbyRow.modelData.pairing && nearMouse.containsMouse
                                    text: "pair & connect"
                                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                }

                                MouseArea {
                                    id: nearMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.btToggleDevice(nearbyRow.modelData)
                                }

                                Connections {
                                    target: root.btAdapter ? nearbyRow.modelData : null
                                    function onPairedChanged() {
                                        if (!root.btAdapter) return
                                        if (nearbyRow.modelData.paired) {
                                            nearbyRow.modelData.trusted = true
                                            nearbyRow.modelData.connect()
                                        }
                                    }
                                }
                            }
                        }
                    }
                        }
                    }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: root.btPowered && root.btNearbyList.length === 0
                    text: "searching for devices…"
                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // ---- power page ----

            Column {
                width: parent.width
                spacing: 8
                visible: root.page === "power"

                ActionRow {
                    iconText: "󰌾"; labelText: "Lock"
                    onClicked: root.runSession("pidof hyprlock >/dev/null || hyprlock")
                }
                ActionRow {
                    iconText: "󰍃"; labelText: "Logout"
                    onClicked: root.runSession("loginctl terminate-session ${XDG_SESSION_ID}")
                }
                ActionRow {
                    iconText: "󰤄"; labelText: "Suspend"
                    onClicked: root.runSession("systemctl suspend")
                }
                ActionRow {
                    iconText: "󰜎"; labelText: "Restart"
                    onClicked: root.runSession("systemctl reboot")
                }
                ActionRow {
                    iconText: "󰐥"; labelText: "Power Off"
                    danger: true
                    onClicked: root.runSession("systemctl poweroff")
                }
            }

            // ---- clipboard page ----

            Column {
                width: parent.width
                spacing: 6
                visible: root.page === "clipboard"

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clipboard"
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                    Text {
                        renderType: Text.NativeRendering
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: "left: copy   right: delete"
                        font.pixelSize: 13; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                    }
                }

                Item {
                    width: parent.width
                    height: Math.min(clipCol.implicitHeight, 300)

                    Flickable {
                        anchors.fill: parent
                        contentHeight: clipCol.implicitHeight
                        clip: true
                        interactive: contentHeight > height

                        Column {
                            id: clipCol
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: root.clipEntries
                                delegate: Rectangle {
                                    id: clipRow
                                    required property var modelData

                                    readonly property string imgPath: "/tmp/qs-cc-clip-" + modelData.index + ".png"

                                    width: clipCol.width; height: modelData.isImage ? 160 : 32; radius: 0
                                    color: clipMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                                    Behavior on color { ColorAnimation { duration: 0 } }

                                    Component.onCompleted: {
                                        if (modelData.isImage)
                                            root.enqueueClipImage(modelData.index, modelData.raw)
                                    }

                                    // image entry: same preview style as the launcher's clipboard view
                                    Item {
                                        visible: clipRow.modelData.isImage
                                        anchors {
                                            top: parent.top; topMargin: 8
                                            bottom: parent.bottom; bottomMargin: 8
                                            left: parent.left; leftMargin: 14
                                            right: parent.right; rightMargin: 12
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: PanelColors.rowBackground
                                            visible: imgPreviewImg.status !== Image.Ready
                                        }

                                        Image {
                                            id: imgPreviewImg
                                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                            width: status === Image.Ready
                                                ? Math.min(implicitWidth, parent.width)
                                                : parent.width
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            cache: false
                                            smooth: true
                                            mipmap: true
                                            sourceSize: Qt.size(480, 480)
                                            source: "file://" + clipRow.imgPath

                                            Connections {
                                                target: root
                                                function onClipDecodeReadyChanged() {
                                                    if (root.clipDecodeReady && root.clipDecodingId === clipRow.modelData.index) {
                                                        imgPreviewImg.source = ""
                                                        imgPreviewImg.source = "file://" + clipRow.imgPath
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            anchors.centerIn: imgPreviewImg
                                            color: "transparent"
                                            border.color: PanelColors.border
                                            border.width: 3
                                            width: imgPreviewImg.paintedWidth + border.width * 2
                                            height: imgPreviewImg.paintedHeight + border.width * 2
                                            visible: imgPreviewImg.status === Image.Ready
                                        }
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: !clipRow.modelData.isImage
                                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                        text: clipRow.modelData.preview.replace(/\n/g, " ")
                                        font.pixelSize: 16; font.family: FontConfig.fontFamily
                                        color: PanelColors.textMain
                                        elide: Text.ElideRight
                                    }
                                    MouseArea {
                                        id: clipMouse
                                        anchors.fill: parent; hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: (mouse) => {
                                            if (mouse.button === Qt.RightButton) root.clipDelete(modelData.index)
                                            else root.clipCopy(modelData.index)
                                        }
                                    }
                                }
                            }

                            Text {
                                renderType: Text.NativeRendering
                                width: clipCol.width
                                visible: root.clipEntries.length === 0
                                text: "clipboard history is empty"
                                font.pixelSize: 16; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                                horizontalAlignment: Text.AlignHCenter
                                topPadding: 12
                            }
                        }
                    }
                }
            }

            // ---- wallpaper page ----

            Column {
                id: wallPage
                width: parent.width
                spacing: 8
                visible: root.page === "wallpaper"

                onVisibleChanged: {
                    if (visible) {
                        root.loadWallpapers()
                        wallSearch.forceActiveFocus()
                    }
                }

                // name filter; empty query = everything
                readonly property var filteredWalls: {
                    const q = wallSearch.text.toLowerCase().trim()
                    if (q === "") return root.wallEntries
                    return root.wallEntries.filter(e => e.wallName.toLowerCase().includes(q))
                }

                Rectangle {
                    width: parent.width; height: 34; radius: 0
                    color: wallSearch.activeFocus ? Qt.lighter(PanelColors.rowBackground, 1.15) : PanelColors.rowBackground
                    border.color: wallSearch.activeFocus ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                    border.width: wallSearch.activeFocus ? 1 : 0

                    Row {
                        anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text {
                            renderType: Text.NativeRendering
                            text: "󰍉"
                            font.pixelSize: 13; font.family: FontConfig.fontFamily
                            color: PanelColors.textDim
                        }
                        TextInput {
                            id: wallSearch
                            width: parent.width - 23 - 8
                            font.pixelSize: 13; font.family: FontConfig.fontFamily
                            color: PanelColors.textMain
                            renderType: TextInput.NativeRendering
                            clip: true
                            selectByMouse: true
                            Keys.onEscapePressed: {
                                text = ""
                                root.close()
                            }
                            cursorDelegate: Rectangle {
                                width: 1
                                height: 14
                                color: PanelColors.textDim
                            }
                        }
                    }
                    MouseArea { anchors.fill: parent; z: -1; onClicked: wallSearch.forceActiveFocus() }
                    Text {
                        renderType: Text.NativeRendering
                        visible: wallSearch.text === ""
                        anchors { left: parent.left; leftMargin: 37; verticalCenter: parent.verticalCenter }
                        text: "search..."
                        font.pixelSize: 13; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                    }
                }

                // Fixed height so fewer results never shrink the menu.
                Item {
                    width: parent.width
                    height: 320

                    GridView {
                        id: wallGrid
                        anchors.fill: parent
                        clip: true

                        readonly property int cols: 3
                        readonly property int thumbW: Math.floor((width - 8) / cols)
                        readonly property int thumbH: Math.floor(thumbW * 0.58)
                        cellWidth: thumbW
                        cellHeight: thumbH + 22
                        model: wallPage.filteredWalls

                        delegate: Item {
                            required property var modelData
                            width: wallGrid.cellWidth
                            height: wallGrid.cellHeight

                            Column {
                                anchors { fill: parent; margins: 4 }
                                spacing: 4

                                Rectangle {
                                    width: parent.width
                                    height: wallGrid.thumbH - 8
                                    radius: 0
                                    color: PanelColors.rowBackground
                                    border.width: wallHover.containsMouse ? 2 : 1
                                    border.color: wallHover.containsMouse ? PanelColors.launcher : PanelColors.border
                                    Behavior on border.color { ColorAnimation { duration: 0 } }

                                    Image {
                                        anchors.fill: parent; anchors.margins: 2
                                        source: "file://" + modelData.filePath
                                        sourceSize: Qt.size(256, 160)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        smooth: true
                                        mipmap: true
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: modelData.isVideo
                                        anchors { right: parent.right; bottom: parent.bottom; margins: 4 }
                                        text: "VID"
                                        font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                        color: PanelColors.scanning
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    height: 18
                                    text: modelData.wallName
                                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                    color: wallHover.containsMouse ? PanelColors.launcher : PanelColors.textMain
                                    Behavior on color { ColorAnimation { duration: 0 } }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: wallHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wallpaperSetProc.apply(modelData.filePath, modelData.isVideo)
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- components ---------------------------------------------------------------------

    component BevelOverlay: Item {
        property bool pressed: false
        anchors.fill: parent
        z: 1

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 2 }
            height: 1
            color: parent.pressed ? "#090909" : "#303030"
        }
        Rectangle {
            anchors { top: parent.top; left: parent.left; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }
            width: 1
            color: parent.pressed ? "#090909" : "#242424"
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 2 }
            height: 1
            color: parent.pressed ? "#686868" : "#000000"
        }
        Rectangle {
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }
            width: 1
            color: parent.pressed ? "#686868" : "#000000"
        }
    }

    component HeaderIconButton: Rectangle {
        id: hbtn
        property string iconText: ""
        property bool isActive: false
        signal clicked()
        width: 36; height: 36; radius: 0
        color: hmouse.containsMouse || isActive ? Qt.lighter(PanelColors.rowBackground, 1.35) : PanelColors.rowBackground
        border.width: 1
        border.color: "#090909"
        Behavior on color { ColorAnimation { duration: 0 } }
        BevelOverlay { pressed: hmouse.pressed }
        Text {
            renderType: Text.NativeRendering
            anchors.centerIn: parent
            text: hbtn.iconText
            font.pixelSize: 16; font.family: FontConfig.fontFamily
            color: hmouse.containsMouse || hbtn.isActive ? PanelColors.textAccent : PanelColors.textMain
            Behavior on color { ColorAnimation { duration: 0 } }
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
        border.width: 2
        border.color: "#090909"
        Behavior on color { ColorAnimation { duration: 0 } }
        BevelOverlay { pressed: pillMouse.pressed }

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
                Behavior on color { ColorAnimation { duration: 0 } }
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
                Behavior on color { ColorAnimation { duration: 0 } }
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
        border.width: 2
        border.color: "#090909"
        Behavior on color { ColorAnimation { duration: 0 } }
        BevelOverlay { pressed: actMouse.pressed }

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
        border.color: "#090909"

        BevelOverlay { pressed: tswitchMouse.pressed }

        Rectangle {
            x: tswitch.checked ? parent.width - width - 2 : 2
            anchors.verticalCenter: parent.verticalCenter
            width: 14; height: 14; radius: 0
            color: tswitch.checked ? PanelColors.pillForeground : PanelColors.textDim
            Behavior on x { NumberAnimation { duration: 0 } }
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
