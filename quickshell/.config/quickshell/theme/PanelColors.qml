pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "."

Singleton {
    readonly property bool isDark: ThemeState.isDark
    readonly property int transitionDuration: 250

    // Light theme definitions (Clean & Neutral, No Pure White)
    readonly property color lightBarBackground:    Colors.grey100
    readonly property color lightPopupBackground:  Colors.grey50
    readonly property color lightRowBackground:    Colors.grey200
    readonly property color lightTrackBackground:  Colors.grey300
    readonly property color lightBorder:           Colors.blueGrey100
    readonly property color lightTextMain:         Colors.blueGrey900
    readonly property color lightTextAccent:       Colors.blueGrey800
    readonly property color lightTextDim:          Colors.blueGrey400

    // Base16 Black Metal Bathory Tweaked
    readonly property color base00: "#030303"
    readonly property color base01: "#080808"
    readonly property color base02: "#121212"
    readonly property color base03: "#333333"
    readonly property color base04: "#999999"
    readonly property color base05: "#c1c1c1"
    readonly property color base06: "#999999"
    readonly property color base07: "#c1c1c1"
    readonly property color base08: "#696969"
    readonly property color base09: "#aaaaaa"
    readonly property color base0A: "#e78a53"
    readonly property color base0B: "#d9af82"
    readonly property color base0C: "#aaaaaa"
    readonly property color base0D: "#696969"
    readonly property color base0E: "#999999"
    readonly property color base0F: "#444444"

    // Surfaces
    readonly property color barBackground:     base00
    readonly property color pillForeground:    base01
    readonly property color overlayBackground: "#aa030303"

    // Accents
    readonly property color launcher:          base08
    readonly property color battery:           base0A
    readonly property color network:           base0B
    readonly property color audio:             base08
    readonly property color clock:             base05
    readonly property color date:              base0C
    readonly property color brightness:        base0A
    readonly property color bluetooth:         base0D
    readonly property color session:           base08
    readonly property color dashboard:         base02

    readonly property color tray:              base01
    readonly property color workspaceActive:   base05
    readonly property color workspaceInactive: base03
    readonly property color titleBackground:   base01
    readonly property color titleForeground:   base05

    readonly property color popupBackground:   base00
    readonly property color rowBackground:     base01
    readonly property color trackBackground:   base02
    readonly property color border:            base03

    // Text
    readonly property color textMain:          base05
    readonly property color textDim:           base04
    readonly property color textAccent:        base07
    readonly property color textBox:           base00
    readonly property color textBoxDim:        base03

    // Status
    readonly property color scanning:          base0A
    readonly property color networkScanning:   base0B
    readonly property color pairing:           base09
    readonly property color error:             base08

    // Dashboard specific
    readonly property color dashboardBackground: base00
    readonly property color dashboardCard:       base01
    readonly property color dashboardAccent:     base08
    readonly property color dashboardStripe:     base02

    readonly property color profile:           base0B
    readonly property color system:            base0D

    readonly property color cpuRing:           base08
    readonly property color ramRing:           base0D
    readonly property color gpuRing:           base0B

    // Functions
    function profileColor(profile) {
        if (profile === PowerProfile.PowerSaver)  return Colors.green200
        if (profile === PowerProfile.Performance) return Colors.red200
        return Colors.orange200
    }

    property var _hashCache: ({})
    function hashColor(str) {
        if (!str || str === "") return isDark ? Colors.blueGrey300 : Colors.blueGrey400
        if (_hashCache[str + isDark]) return _hashCache[str + isDark]

        var hash = 0
        for (var i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash)
            hash = hash & hash
        }

        var palette = isDark ? [
            Colors.teal200, Colors.lightBlue200, Colors.green200,
            Colors.purple200, Colors.orange200, Colors.pink200,
            Colors.yellow200, Colors.cyan200, Colors.deepPurple200,
            Colors.blueGrey300
        ] : [
            Colors.teal300, Colors.lightBlue300, Colors.green400,
            Colors.purple300, Colors.orange300, Colors.pink300,
            Colors.yellow700, Colors.cyan300, Colors.deepPurple300,
            Colors.blueGrey400
        ]

        var result = palette[Math.abs(hash) % palette.length]
        _hashCache[str + isDark] = result
        return result
    }
}
