import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

// BluetoothService: extracted move-only from ControlCenter.qml.
// ControlCenter instantiates this and forwards the same
// controlRoot.* API, so pages are untouched.
Item {
    id: root
    property string page: ""
    property string animState: "closed"

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
        interval: 1000
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
            "else rfkill unblock bluetooth 2>/dev/null; bluetoothctl power on; echo on; fi"]
        btToggleProc.running = true
        queryBtTimer.restart()
        btScanResumeTimer.restart()
    }

    Timer {
        id: btScanResumeTimer
        interval: 1500
        onTriggered: {
            if (root.page === "bluetooth" && root.btPowered)
                root.setBtScanning(true)
        }
    }

    readonly property bool btPowered: (btAdapter?.enabled ?? false) || btCliState === "on"
    readonly property bool btHasAdapter: (btAdapter !== null) || (btCliState !== "none" && btCliState !== "unknown")

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
        interval: 4000
        running: root.page === "bluetooth" && root.btAdapter === null && root.animState === "open"
        repeat: true
        onTriggered: {
            root.refreshBtCliDevices()
            if (root.btCliState === "none" || root.btCliState === "unknown") root.queryBtState()
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

    function setBtScanning(on) {
        if (btAdapter) {
            btAdapter.discovering = on
        } else {
            btCliScanProc.command = ["bluetoothctl", "scan", on ? "on" : "off"]
            btCliScanProc.running = true
        }
    }

    readonly property var btDeviceList: btAdapter?.devices.values ?? []
    readonly property var btPairedList: btAdapter !== null
        ? btDeviceList.filter(d => d.bonded || d.paired || d.connected)
        : btCliDevices.filter(d => d.paired || d.connected)
    readonly property var btNearbyList: btAdapter !== null
        ? btDeviceList.filter(d => !(d.bonded || d.paired || d.connected))
        : (root.page === "bluetooth" ? btCliDevices.filter(d => !d.paired && !d.connected) : [])

    readonly property string btConnectedName: {
        const conn = btPairedList.find(d => d.connected)
        if (conn) return conn.name !== "" ? conn.name : conn.address
        return ""
    }

    function btDeviceGlyph(iconName, devName) {
        const i = (iconName ?? "").toLowerCase()
        const n = (devName ?? "").toLowerCase()
        if (i.includes("headset") || i.includes("headphone") || i.includes("audio") || n.includes("buds") || n.includes("headphone") || n.includes("wh-") || n.includes("airpods")) return "󰋋"
        if (i.includes("keyboard") || n.includes("keychron") || n.includes("keyboard")) return "󰌌"
        if (i.includes("mouse") || n.includes("mouse") || n.includes("mx master")) return "󰍽"
        if (i.includes("phone") || n.includes("phone") || n.includes("iphone") || n.includes("android")) return "󰄜"
        if (i.includes("watch") || n.includes("watch")) return "󰖉"
        return "󰂯"
    }

    function btBatteryPct(d) {
        if (!d || !d.batteryAvailable) return -1
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

    // ids forwarded by ControlCenter compat aliases
    property alias btStateProc: btStateProc
    property alias btToggleProc: btToggleProc
    property alias btCliListProc: btCliListProc
    property alias btCliScanProc: btCliScanProc
    property alias btCliActionProc: btCliActionProc
    property alias queryBtTimer: queryBtTimer
    property alias btScanResumeTimer: btScanResumeTimer
    property alias btCliRefreshTimer: btCliRefreshTimer
}
