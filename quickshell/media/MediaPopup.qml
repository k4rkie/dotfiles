import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../theme"

PanelWindow {
    id: root
    implicitHeight: 400
    color: "transparent"

    anchors.bottom: true
    margins.bottom: 8
    exclusiveZone: 0

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Shortcut {
        sequence: "Escape"
        onActivated: root.toggle()
    }

    property string animState: "closed"
    visible: animState !== "closed"

    readonly property int contentCardWidth: 300
    readonly property int arrowWidth: 36
    readonly property int arrowGap: 6
    readonly property int arrowOffset: arrowWidth + arrowGap

    implicitWidth: contentCardWidth + arrowOffset * 2

    function toggle() {
        if (animState === "closed" || animState === "closing") animState = "open"
        else animState = "closed"
    }

    IpcHandler {
        target: "media"
        function toggle(): void { root.toggle() }
    }

    readonly property var playerList: {
        const result = []
        const vals = Mpris.players.values
        for (let i = 0; i < vals.length; i++) {
            const p = vals[i]
            if (p && (p.trackTitle ?? "") !== "") result.push(p)
        }
        return result
    }

    property int selectedIndex: 0
    onPlayerListChanged: {
        if (root.playerList.length === 0) root.selectedIndex = 0
        else if (root.selectedIndex >= root.playerList.length) root.selectedIndex = root.playerList.length - 1
    }

    readonly property MprisPlayer activePlayer: {
        if (root.playerList.length === 0) return null
        const sel = root.playerList[root.selectedIndex]
        if (sel) return sel
        for (let i = 0; i < root.playerList.length; i++) {
            if (root.playerList[i].playbackState === MprisPlaybackState.Playing)
                return root.playerList[i]
        }
        return root.playerList[0]
    }

    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property bool hasContent: activePlayer !== null
    readonly property bool multiPlayer: root.playerList.length > 1

    property real livePosition: activePlayer?.position ?? 0
    property bool userSeeking: false
    property real _stableLength: 0
    property bool _playerSwitching: false

    readonly property int _liveStreamThreshold: 86400 * 365
    readonly property bool isLiveStream: (_stableLength <= 0 || _stableLength > _liveStreamThreshold) && !_playerSwitching

    function getCleanMetadata(rawTitle, rawArtist) {
        let t = (rawTitle || "").replace(/\s*-\s*YouTube$/, "").replace(/\s*-\s*Mozilla Firefox$/, "").replace(/\s*-\s*Zen Browser$/, "").trim()
        let a = (rawArtist || "").trim()
        if (a === "" && t.includes(" - ")) {
            const parts = t.split(" - ")
            a = parts[0].trim()
            t = parts.slice(1).join(" - ").trim()
        }
        return { title: t, artist: a }
    }

    function getPlayerIcon(identity) {
        const id = (identity || "").toLowerCase()
        if (id.includes("spotify")) return "\uf2bc"
        if (id.includes("firefox")) return "\uf269"
        if (id.includes("zen")) return "\uf269"
        if (id.includes("chrome")) return "\uf268"
        if (id.includes("vlc")) return "\uf1c7"
        return "\uf1eb"
    }

    function fmtTime(secs) {
        if (!secs || secs < 0) return "0:00"
        const s = Math.floor(secs)
        const m = Math.floor(s / 60)
        const rem = s % 60
        return m + ":" + (rem < 10 ? "0" + rem : rem)
    }

    property bool _textShowA: true
    property string _titleA: ""; property string _artistA: ""; property string _identityA: ""
    property string _titleB: ""; property string _artistB: ""; property string _identityB: ""

    function _crossfadeText() {
        const meta = getCleanMetadata(activePlayer?.trackTitle, activePlayer?.trackArtist)
        let id = activePlayer?.identity ?? ""
        const idLow = id.toLowerCase()
        if (idLow.includes("firefox")) id = "Firefox"
        else if (idLow.includes("zen")) id = "Zen"
        else if (idLow.includes("chrome")) id = "Chrome"
        else if (idLow.includes("spotify")) id = "Spotify"
        const newTitle = meta.title || "Unknown Title"
        const newArtist = meta.artist || "Unknown Artist"
        const cur = _textShowA ? { t: _titleA, a: _artistA, i: _identityA } : { t: _titleB, a: _artistB, i: _identityB }
        if (cur.t === newTitle && cur.a === newArtist && cur.i === id) return
        if (_textShowA) { _titleB = newTitle; _artistB = newArtist; _identityB = id }
        else { _titleA = newTitle; _artistA = newArtist; _identityA = id }
        _textShowA = !_textShowA
    }

    Timer { id: metaSettleTimer; interval: 120; onTriggered: root._crossfadeText() }
    Timer { id: playerSwitchSettleTimer; interval: 150; onTriggered: root._playerSwitching = false }

    Connections {
        target: root.activePlayer
        function onTrackChanged() {
            livePosition = 0
            _stableLength = activePlayer?.length ?? 0
            _trackChangeCooldown = 3
            metaSettleTimer.restart()
        }
        function onTrackTitleChanged() { metaSettleTimer.restart() }
        function onTrackArtistChanged() { metaSettleTimer.restart() }
        function onLengthChanged() {
            const newLen = activePlayer?.length ?? 0
            if (newLen <= 0) return
            if (Math.abs(newLen - livePosition) < 2) return
            if (_stableLength <= 0 || newLen >= _stableLength) _stableLength = newLen
        }
    }

    Connections {
        target: root
        function onActivePlayerChanged() {
            userSeeking = false; _playerSwitching = true
            _stableLength = activePlayer?.length ?? 0
            livePosition = activePlayer?.position ?? 0
            _lastTrackTitle = activePlayer?.trackTitle ?? ""
            _trackChangeCooldown = 0
            playerSwitchSettleTimer.restart()
            _crossfadeText(); metaSettleTimer.restart()
        }
    }
    property string _lastTrackTitle: ""
    property int _trackChangeCooldown: 0

    Timer {
        interval: 1000; repeat: true; running: isPlaying && !userSeeking
        onTriggered: {
            if (activePlayer) {
                const pos = activePlayer.position
                const curTitle = activePlayer.trackTitle ?? ""
                if (curTitle !== root._lastTrackTitle) {
                    root._lastTrackTitle = curTitle
                    root.livePosition = 0
                    root._stableLength = activePlayer.length ?? 0
                    root._trackChangeCooldown = 3
                    return
                }
                if (root._trackChangeCooldown > 0) {
                    root._trackChangeCooldown--
                    root._stableLength = activePlayer.length ?? 0
                    if (root._stableLength > 0 && pos > root._stableLength) return
                    if (pos > 5) return
                }
                livePosition = pos
            }
        }
    }

    Rectangle {
        id: contentCard
        x: root.arrowOffset
        width: root.contentCardWidth
        anchors.bottom: parent.bottom
        height: popupColumn.implicitHeight + 24
        color: PanelColors.popupBackground
        border.color: "#090909"
        border.width: 2
        radius: 0

        Column {
            id: popupColumn
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            spacing: 12

            Text {
                visible: !root.hasContent
                width: parent.width
                text: "No active media session"
                font.pixelSize: 13
                font.family: "MapleMono NF"
                color: PanelColors.textDim
                horizontalAlignment: Text.AlignHCenter
                topPadding: 8; bottomPadding: 8
            }

            Row {
                visible: root.hasContent
                width: parent.width
                spacing: 12

                Item {
                    id: artContainer
                    width: 64; height: 64
                    property string _urlA: activePlayer?.trackArtUrl ?? ""
                    property string _urlB: ""
                    property bool _showA: true
                    function _switchArt(newUrl) {
                        if (_showA) { _urlB = newUrl; _showA = false }
                        else { _urlA = newUrl; _showA = true }
                    }
                    Connections { target: root; function onActivePlayerChanged() { artContainer._switchArt(activePlayer?.trackArtUrl ?? "") } }
                    Connections { target: activePlayer; function onTrackArtUrlChanged() { artContainer._switchArt(activePlayer?.trackArtUrl ?? "") } }

                    Image {
                        id: artB
                        anchors.fill: parent; anchors.margins: 2
                        source: artContainer._urlB
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true; mipmap: true; smooth: true
                        opacity: artContainer._showA ? 0.0 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.InOutSine } }
                        visible: opacity > 0
                    }
                    Image {
                        id: artA
                        anchors.fill: parent; anchors.margins: 2
                        source: artContainer._urlA
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true; mipmap: true; smooth: true
                        opacity: artContainer._showA ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.InOutSine } }
                        visible: opacity > 0
                    }
                    Text {
                        visible: artA.status !== Image.Ready && artB.status !== Image.Ready
                        anchors.centerIn: parent
                        text: {
                            const id = (activePlayer?.identity ?? "").toLowerCase()
                            if (id.includes("firefox")) return "\uf269"
                            if (id.includes("zen")) return "\uf269"
                            if (id.includes("chrome") || id.includes("chromium")) return "\uf268"
                            return "\uf001"
                        }
                        font.pixelSize: 24; font.family: "MapleMono NF"; color: PanelColors.textDim; z: 1
                    }
                    Rectangle { anchors.fill: parent; color: "transparent"; border.width: 2; border.color: PanelColors.clock; radius: 0 }
                }

                Item {
                    width: parent.width - 64 - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    height: Math.max(textSlotA.implicitHeight, textSlotB.implicitHeight)

                    Column { id: textSlotA; width: parent.width; spacing: 6; opacity: root._textShowA ? 1.0 : 0.0; Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutSine } }
                        Item { width: parent.width; height: 20; clip: true
                            Text { text: root._titleA || "Unknown Title"; font.pixelSize: 15; font.bold: true; font.family: "MapleMono NF"; color: PanelColors.textAccent }
                        }
                        Text { width: parent.width; text: root._artistA || "Unknown Artist"; font.pixelSize: 12; font.family: "MapleMono NF"; color: PanelColors.textDim; elide: Text.ElideRight }
                        Rectangle { visible: root._identityA !== ""; height: 18; width: identRowA.implicitWidth + 12; radius: height / 2; color: Qt.rgba(PanelColors.clock.r, PanelColors.clock.g, PanelColors.clock.b, 0.15)
                            Row { id: identRowA; anchors.centerIn: parent; spacing: 4
                                Text { text: root.getPlayerIcon(root._identityA); font.pixelSize: 10; font.family: "MapleMono NF"; color: PanelColors.textAccent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: root._identityA; font.pixelSize: 9; font.bold: true; font.family: "MapleMono NF"; color: PanelColors.textAccent; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }

                    Column { id: textSlotB; width: parent.width; spacing: 6; opacity: root._textShowA ? 0.0 : 1.0; Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutSine } }
                        Item { width: parent.width; height: 20; clip: true
                            Text { text: root._titleB || "Unknown Title"; font.pixelSize: 15; font.bold: true; font.family: "MapleMono NF"; color: PanelColors.textAccent }
                        }
                        Text { width: parent.width; text: root._artistB || "Unknown Artist"; font.pixelSize: 12; font.family: "MapleMono NF"; color: PanelColors.textDim; elide: Text.ElideRight }
                        Rectangle { visible: root._identityB !== ""; height: 18; width: identRowB.implicitWidth + 12; radius: height / 2; color: Qt.rgba(PanelColors.clock.r, PanelColors.clock.g, PanelColors.clock.b, 0.15)
                            Row { id: identRowB; anchors.centerIn: parent; spacing: 4
                                Text { text: root.getPlayerIcon(root._identityB); font.pixelSize: 10; font.family: "MapleMono NF"; color: PanelColors.textAccent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: root._identityB; font.pixelSize: 9; font.bold: true; font.family: "MapleMono NF"; color: PanelColors.textAccent; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }
            }

            Column {
                visible: root.hasContent && (activePlayer?.positionSupported ?? false)
                width: parent.width; spacing: 4

                WaveBar {
                    width: parent.width
                    accentColor: PanelColors.clock
                    from: 0
                    to: root.isLiveStream ? 1 : Math.max(1, root._stableLength)
                    value: root.isLiveStream ? 1.0 : Math.min(root.livePosition, Math.max(1, root._stableLength))
                    playing: root.isPlaying
                    forceNoNeedle: root.isLiveStream
                    seekable: !root.isLiveStream && (activePlayer?.canSeek ?? false)
                    onSeeked: (v) => {
                        root.userSeeking = true
                        const targetPos = Math.max(0, Math.min(v, root._stableLength))
                        root.activePlayer.position = targetPos
                        root.livePosition = targetPos
                        seekReleaseTimer.restart()
                    }
                }

                Timer { id: seekReleaseTimer; interval: 1200; onTriggered: root.userSeeking = false }

                Row { width: parent.width
                    Text { id: posL; text: root.isLiveStream ? "Live" : root.fmtTime(root.livePosition); font.pixelSize: 11; font.family: "MapleMono NF"; color: PanelColors.textDim }
                    Item { width: parent.width - posL.implicitWidth - posR.implicitWidth; height: 1 }
                    Text { id: posR; text: root.isLiveStream ? "\u221e" : root.fmtTime(root._stableLength); font.pixelSize: 11; font.family: "MapleMono NF"; color: PanelColors.textDim }
                }
            }

            Item {
                visible: root.hasContent
                width: parent.width
                height: playBtn.height

                MediaBtn {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    opacity: (activePlayer?.shuffleSupported ?? false) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: opacity > 0
                    icon: "\uf074"; accentColor: PanelColors.clock
                    highlighted: activePlayer?.shuffle ?? false
                    onClicked: { if (activePlayer) activePlayer.shuffle = !(activePlayer.shuffle ?? false) }
                }

                Row { anchors.centerIn: parent; spacing: 4
                    MediaBtn {
                        icon: "\uf04a"; accentColor: PanelColors.clock
                        enabled: activePlayer?.canGoPrevious ?? false
                        opacity: enabled ? 1.0 : 0.45
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        onClicked: activePlayer?.previous()
                    }
                    MediaBtn {
                        id: playBtn; highlighted: true; accentColor: PanelColors.clock
                        icon: root.isPlaying ? "\uf04c" : "\uf04b"
                        enabled: root.isPlaying ? (activePlayer?.canPause ?? false) : (activePlayer?.canPlay ?? false)
                        onClicked: root.isPlaying ? activePlayer?.pause() : activePlayer?.play()
                    }
                    MediaBtn {
                        icon: "\uf04e"; accentColor: PanelColors.clock
                        enabled: activePlayer?.canGoNext ?? false
                        opacity: enabled ? 1.0 : 0.45
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        onClicked: activePlayer?.next()
                    }
                }

                MediaBtn {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    opacity: (activePlayer?.loopSupported ?? false) ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    visible: opacity > 0
                    icon: (activePlayer?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\uf07d" : "\uf07e"
                    accentColor: PanelColors.clock
                    highlighted: (activePlayer?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                    onClicked: {
                        if (!activePlayer) return
                        const s = activePlayer.loopState ?? MprisLoopState.None
                        if (s === MprisLoopState.None) activePlayer.loopState = MprisLoopState.Playlist
                        else if (s === MprisLoopState.Playlist) activePlayer.loopState = MprisLoopState.Track
                        else activePlayer.loopState = MprisLoopState.None
                    }
                }
            }
        }
    }

    PlayerNavBtn {
        visible: root.multiPlayer
        icon: "\uf053"
        x: 0
        anchors.verticalCenter: contentCard.verticalCenter
        accentColor: PanelColors.clock
        onClicked: root.selectedIndex = (root.selectedIndex - 1 + root.playerList.length) % root.playerList.length
    }

    PlayerNavBtn {
        visible: root.multiPlayer
        icon: "\uf054"
        x: contentCard.x + contentCard.width + root.arrowGap
        anchors.verticalCenter: contentCard.verticalCenter
        accentColor: PanelColors.clock
        onClicked: root.selectedIndex = (root.selectedIndex + 1) % root.playerList.length
    }

    component PlayerNavBtn: Rectangle {
        id: navBtn
        property string icon: ""
        property color accentColor: PanelColors.clock
        signal clicked()
        width: 36; height: 36; radius: 0
        color: navMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : PanelColors.rowBackground
        border.color: PanelColors.border
        border.width: 2
        scale: navMouse.pressed ? 0.88 : 1.0
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        Text {
            anchors.centerIn: parent
            text: navBtn.icon
            font.pixelSize: 16
            font.family: "MapleMono NF"
            color: navMouse.containsMouse ? navBtn.accentColor : PanelColors.textMain
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        MouseArea {
            id: navMouse
            anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navBtn.clicked()
        }
    }

    component MediaBtn: Rectangle {
        id: btn
        property string icon: ""
        property bool highlighted: false
        property color accentColor: PanelColors.clock
        property bool enabled: true
        signal clicked()
        width: 40; height: 40; radius: 0
        color: {
            if (!enabled) return Qt.rgba(PanelColors.rowBackground.r, PanelColors.rowBackground.g, PanelColors.rowBackground.b, 0.35)
            if (highlighted) return btnMouse.containsMouse ? Qt.lighter(accentColor, 1.1) : accentColor
            return btnMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
        }
        border.color: highlighted ? "transparent" : Qt.rgba(1, 1, 1, btnMouse.containsMouse ? 0.10 : 0.04)
        border.width: 1
        scale: btnMouse.pressed ? 0.91 : 1.0
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        Text {
            anchors.centerIn: parent; text: btn.icon
            font.pixelSize: 18; font.family: "MapleMono NF"
            color: {
                if (!btn.enabled) return PanelColors.textDim
                if (btn.highlighted) return PanelColors.pillForeground
                return btnMouse.containsMouse ? PanelColors.textAccent : PanelColors.textMain
            }
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        MouseArea {
            id: btnMouse; anchors.fill: parent; hoverEnabled: true; enabled: btn.enabled
            cursorShape: Qt.PointingHandCursor; onClicked: btn.clicked()
        }
    }

    component WaveBar: Item {
        id: bar
        property real value: 0
        property real from: 0
        property real to: 100
        property color accentColor: PanelColors.clock
        property bool playing: false
        property bool seekable: true
        property bool forceNoNeedle: false
        signal seeked(real value)
        implicitWidth: 120
        implicitHeight: 32
        property bool dragging: barMouse.pressed
        property real internalValue: 0
        readonly property bool activeInteraction: dragging
        readonly property bool isNeedle: !forceNoNeedle && (activeInteraction || playing)
        readonly property bool hovered: barMouse.containsMouse || barMouse.pressed
        readonly property real targetValue: activeInteraction ? internalValue : value
        property real animValue: targetValue
        Behavior on animValue { enabled: !bar.dragging; NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
        readonly property real _fillWidth: ((bar.animValue - bar.from) / (bar.to - bar.from)) * bar.width
        function _updateFromMouse(mouseX) {
            var newVal = Math.max(bar.from, Math.min(bar.to, bar.from + (mouseX / bar.width) * (bar.to - bar.from)))
            bar.internalValue = newVal
            bar.seeked(newVal)
        }
        property real _phase: 0
        NumberAnimation on _phase { from: 0; to: Math.PI * 2; duration: 1200; loops: Animation.Infinite; running: bar.playing && !bar.activeInteraction }
        property real _waveAmount: 0.0
        Behavior on _waveAmount { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }
        onPlayingChanged: _waveAmount = (playing && !activeInteraction) ? 1.0 : 0.0
        onActiveInteractionChanged: _waveAmount = (playing && !activeInteraction) ? 1.0 : 0.0

        property color _strokeColor: hovered ? Qt.lighter(bar.accentColor, 1.15) : bar.accentColor
        Behavior on _strokeColor { ColorAnimation { duration: 150 } }

        Rectangle {
            x: Math.max(0, bar._fillWidth - 3)
            width: Math.max(0, parent.width - x - 3); height: 6; radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: bar.hovered ? Qt.rgba(PanelColors.trackBackground.r, PanelColors.trackBackground.g, PanelColors.trackBackground.b, 0.4) : Qt.lighter(PanelColors.trackBackground, 1.1)
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        Canvas {
            id: waveCanvas
            anchors.fill: parent; antialiasing: true
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                if (bar._fillWidth <= 0) return
                const cy = height / 2; const amp = 3.5 * bar._waveAmount; const freq = 0.16
                ctx.beginPath(); ctx.lineWidth = 6; ctx.lineCap = "round"
                ctx.strokeStyle = bar._strokeColor
                const startX = 3
                const endX = Math.min(bar._fillWidth, width - 3)
                if (bar._waveAmount > 0) {
                    for (let x = startX; x <= endX; x++) {
                        const y = cy + Math.sin(x * freq + bar._phase) * amp
                        if (x === startX) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                } else { ctx.moveTo(startX, cy); ctx.lineTo(endX, cy) }
                ctx.stroke()
            }
            Connections {
                target: bar
                function onAnimValueChanged() { waveCanvas.requestPaint() }
                function on_PhaseChanged() { waveCanvas.requestPaint() }
                function on_WaveAmountChanged() { waveCanvas.requestPaint() }
                function onHoveredChanged() { waveCanvas.requestPaint() }
                function on_StrokeColorChanged() { waveCanvas.requestPaint() }
            }
        }
        Item {
            width: 0; height: 0; anchors.verticalCenter: parent.verticalCenter; x: bar._fillWidth
            opacity: bar.forceNoNeedle ? 0.0 : 1.0
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutSine } }
            Rectangle {
                anchors.centerIn: parent
                width: bar.isNeedle ? 6 : (bar.hovered ? 18 : 14)
                height: bar.isNeedle ? 24 : (bar.hovered ? 18 : 14)
                radius: width / 2
                color: bar.hovered ? Qt.lighter(bar.accentColor, 1.15) : bar.accentColor
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
        MouseArea {
            id: barMouse; anchors.fill: parent; hoverEnabled: true; enabled: bar.seekable
            property bool _hasDragged: false
            onPressed: (mouse) => { bar.internalValue = bar.animValue; _hasDragged = false }
            onPositionChanged: (mouse) => { if (pressed) { _hasDragged = true; bar._updateFromMouse(mouse.x) } }
            onClicked: (mouse) => { if (!_hasDragged) bar._updateFromMouse(mouse.x) }
        }
    }
}
