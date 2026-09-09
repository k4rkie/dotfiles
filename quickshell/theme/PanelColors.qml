pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property int transitionDuration: 250

    // Base16 Black Metal Bathory Tweaked
    readonly property color base00: "#080610"
    readonly property color base01: "#0c0a16"
    readonly property color base02: "#110e1c"
    readonly property color base03: "#5e5a74"
    readonly property color base04: "#807a94"
    readonly property color base05: "#d0cce4"
    readonly property color base06: "#d0cce4"
    readonly property color base07: "#424057"
    readonly property color base08: "#c27282"
    readonly property color base09: "#d0a872"
    readonly property color base0A: "#c4a29a"
    readonly property color base0B: "#4a7a8a"
    readonly property color base0C: "#8ab5be"
    readonly property color base0D: "#a890c4"
    readonly property color base0E: "#d0a872"
    readonly property color base0F: "#424057"

    // Surfaces
    readonly property color barBackground:     base00
    readonly property color pillForeground:    base01
    readonly property color overlayBackground: Qt.rgba(base00.r, base00.g, base00.b, 0.667)

    // Returns barBackground blended with accent for module tinting
    function tintedBackground(accent) {
        var c = Qt.colorEqual(accent, "transparent") ? barBackground : accent
        return Qt.rgba(
            barBackground.r * 0.85 + c.r * 0.15,
            barBackground.g * 0.85 + c.g * 0.15,
            barBackground.b * 0.85 + c.b * 0.15,
            1
        )
    }

    // Accents
    readonly property color launcher:          base08
    readonly property color pillActive:        base08
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
    readonly property color border:            base02

    // Text
    readonly property color textMain:          base05
    readonly property color textDim:           base04
    readonly property color textAccent:        base05
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

    readonly property color profile:           base08
    readonly property color system:            base0D

    readonly property color cpuRing:           base08
    readonly property color ramRing:           base0D
    readonly property color gpuRing:           base0B

    FileView {
        path: Quickshell.env("HOME") + "/.cache/dynamic-theme/base00"
        watchChanges: true
        printErrors: false
        onLoaded: root.wallpaperBase00 = text().trim()
        onFileChanged: reload()
    }

    property var _hashCache: ({})
    function hashColor(str) {
        if (!str || str === "") return "#90A4AE"
        if (_hashCache[str]) return _hashCache[str]

        var hash = 0
        for (var i = 0; i < str.length; i++) {
            hash = str.charCodeAt(i) + ((hash << 5) - hash)
            hash = hash & hash
        }

        var palette = [
            "#80cbc4", "#81D4FA", "#a5d6a7",
            "#CE93D8", "#ffcc80", "#f48fb1",
            "#fff59d", "#80DEEA", "#B39DDB",
            "#90A4AE"
        ]

        var result = palette[Math.abs(hash) % palette.length]
        _hashCache[str] = result
        return result
    }
}
