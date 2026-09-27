import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// WifiService: extracted move-only from ControlCenter.qml.
// ControlCenter instantiates this and forwards the same
// controlRoot.* API, so pages are untouched.
Item {
    id: root
    property string page: ""
    property string animState: "closed"

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
    // Cache / throttle: keep last good scan so reopening the page is instant
    // and a scan in progress never wipes the visible list.
    property double wifiLastRescanMs: 0
    readonly property int wifiRescanCooldownMs: 20000

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
        // --rescan no: fast cached read, never triggers/clears a scan itself.
        // Active scanning is done explicitly via wifiRescanProc.
        command: ["nmcli", "-t", "-e", "yes", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.parseWifiList(text)
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
        const bySsid = {}
        const lines = (output || "").trim().split("\n")
        for (let i = 0; i < lines.length; i++) {
            if (!lines[i]) continue
            const f = root.splitNmcliLine(lines[i])
            if (f.length < 4 || f[1] === "") continue
            const ssid = f[1]
            const sig = Number(f[2]) || 0
            const isConnected = f[0] === "*"
            const prev = bySsid[ssid]
            if (!prev) {
                bySsid[ssid] = {
                    name: ssid, signalStrength: sig,
                    security: f[3] || "--", connected: isConnected,
                    stateChanging: false,
                    known: root.wifiProfiles[ssid] !== undefined
                }
            } else {
                if (sig > prev.signalStrength) {
                    prev.signalStrength = sig
                    prev.security = f[3] || "--"
                }
                if (isConnected) prev.connected = true
            }
        }
        const result = []
        for (const key in bySsid) result.push(bySsid[key])
        // Never wipe a good cache with an empty/transient result
        // (happens while nmcli is rescanning). Keep old list visible.
        if (result.length === 0) {
            if (root.wifiCliNetworks.length > 0) return
            root.wifiCliNetworks = []
            root.wifiCliReady = true
            return
        }
        root.wifiListOutput = output
        root.wifiCliNetworks = result
        root.wifiCliReady = true
        let activeName = ""
        for (let j = 0; j < result.length; j++) {
            if (result[j].connected) { activeName = result[j].name; break }
        }
        root.wifiCliSsid = activeName
    }

    function toggleWifi() {
        if (wifiToggleProc.running) return
        wifiToggleProc.command = ["nmcli", "radio", "wifi",
            Networking.wifiEnabled ? "off" : "on"]
        wifiToggleProc.running = true
    }

    function refreshWifiCache() {
        // Fast path: show/refresh from cache, never triggers a rescan.
        if (!Networking.wifiEnabled) return
        if (!wifiKnownProc.running) wifiKnownProc.running = true
        if (!wifiListProc.running) wifiListProc.running = true
    }

    function kickWifiScan(force) {
        if (!Networking.wifiEnabled) return
        // Throttle rescans: reopening the page shows cache instantly,
        // background rescan only runs if the last one is stale.
        const now = Date.now()
        if (force !== true && now - wifiLastRescanMs < wifiRescanCooldownMs) {
            refreshWifiCache()
            return
        }
        if (!wifiKnownProc.running) wifiKnownProc.running = true
        // Don't fire a cached list concurrently with rescan start;
        // with --rescan no it would just return stale data anyway.
        // If we already have a cache, keep showing it until rescan finishes.
        if (root.wifiCliNetworks.length === 0 && !wifiListProc.running)
            wifiListProc.running = true
        if (!wifiRescanProc.running) {
            root.wifiLastRescanMs = now
            wifiRescanProc.running = true
        }
    }

    Timer {
        id: wifiKickTimer
        interval: 15000
        running: root.page === "wifi" && root.animState === "open"
        repeat: true
        onTriggered: root.kickWifiScan(false)
    }

    Timer {
        id: wifiRecoverTimer
        interval: 2000
        // Safety net only: re-read cache (no rescan). Used after radio
        // toggle when the first read may race the driver coming up.
        onTriggered: root.refreshWifiCache()
    }

    property string wifiIpAddress: ""
    Process {
        id: wifiIpProc
        command: ["bash", "-c", "ip -4 addr show dev $(nmcli -g GENERAL.DEVICE device show 2>/dev/null | head -n1 || echo wlan0) 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.wifiIpAddress = text.trim()
        }
    }

    function wifiDisconnect() {
        if (!wifiDevice || wifiActionProc.running) return
        wifiActionProc.command = ["nmcli", "device", "disconnect", wifiDevice.name]
        wifiActionProc.running = true
    }

    function updateWifiIp() {
        if (Networking.wifiEnabled && !wifiIpProc.running)
            wifiIpProc.running = true
    }

    Connections {
        target: Networking
        function onWifiEnabledChanged() {
            if (!Networking.wifiEnabled) {
                root.wifiCliReady = false
                root.wifiCliNetworks = []
                root.wifiListOutput = ""
                root.wifiCliSsid = ""
                root.wifiIpAddress = ""
                root.wifiLastRescanMs = 0
            }
            if (root.page === "wifi") {
                root.refreshWifiCache()
                root.kickWifiScan(false)
                wifiRecoverTimer.restart()
                root.updateWifiIp()
            }
        }
    }

    // ids forwarded by ControlCenter compat aliases
    property alias wifiToggleProc: wifiToggleProc
    property alias wifiActionProc: wifiActionProc
    property alias wifiListProc: wifiListProc
    property alias wifiKnownProc: wifiKnownProc
    property alias wifiRescanProc: wifiRescanProc
    property alias wifiIpProc: wifiIpProc
    property alias wifiKickTimer: wifiKickTimer
    property alias wifiRecoverTimer: wifiRecoverTimer
}
