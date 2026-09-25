import QtQuick
import ".."
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Widgets
import "../../theme"
import "../apps"
import "../components"

Column {
    id: wifiPage
    required property var controlRoot
    width: parent.width
    spacing: 10
    visible: controlRoot.page === "wifi"

    property bool showPsk: false
    property bool showHiddenCard: false

    onVisibleChanged: {
        if (visible) {
            controlRoot.kickWifiScan()
            controlRoot.updateWifiIp()
            controlRoot.wifiRecoverTimer.restart()
        }
        if (!visible) {
            controlRoot.cancelWifiPassword()
            showPsk = false
            showHiddenCard = false
        }
    }

    // Active Connected Network (helper)
    readonly property var activeNet: {
        if (!controlRoot.wifiSortedNetworks) return null
        return controlRoot.wifiSortedNetworks.find(n => n.connected) ?? null
    }

    // Saved/Known Networks (not currently connected)
    readonly property var knownNets: {
        if (!controlRoot.wifiSortedNetworks) return []
        return controlRoot.wifiSortedNetworks.filter(n => n.known && !n.connected)
    }

    // Available Nearby Networks (not known and not connected)
    readonly property var availableNets: {
        if (!controlRoot.wifiSortedNetworks) return []
        return controlRoot.wifiSortedNetworks.filter(n => !n.known && !n.connected)
    }

    // Top Header: Title & Power Switch
    Item {
        width: parent.width
        height: 28

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                renderType: Text.NativeRendering
                text: "󰤨"
                font.pixelSize: 18; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: "Wi-Fi"
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            // Rescan Button
            Rectangle {
                width: 28; height: 28; radius: 0
                color: rescanMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : PanelColors.rowBackground
                border.width: 1
                border.color: PanelColors.border
                visible: Networking.wifiEnabled

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: "󰑐"
                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                    color: controlRoot.wifiScanning ? PanelColors.pillActive : (rescanMouse.containsMouse ? PanelColors.textAccent : PanelColors.textDim)
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        controlRoot.kickWifiScan()
                        controlRoot.updateWifiIp()
                    }
                }
            }

            ToggleSwitch {
                anchors.verticalCenter: parent.verticalCenter
                checked: Networking.wifiEnabled
                onToggled: controlRoot.toggleWifi()
            }
        }
    }

    // Off state message
    Text {
        renderType: Text.NativeRendering
        width: parent.width
        visible: !Networking.wifiEnabled
        text: "Wi-Fi is turned off"
        font.pixelSize: 13; font.family: FontConfig.fontFamily
        color: PanelColors.textDim
        horizontalAlignment: Text.AlignHCenter
        topPadding: 12
    }

    Rectangle {
        width: parent.width
        height: visible ? 56 : 0
        visible: Networking.wifiEnabled && activeNet !== null
        color: PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border

        Item {
            anchors { fill: parent; margins: 10 }

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Text {
                    renderType: Text.NativeRendering
                    text: controlRoot.wifiSignalGlyph(activeNet?.signalStrength ?? 0)
                    font.pixelSize: 18; font.family: FontConfig.fontFamily
                    color: PanelColors.pillActive
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        renderType: Text.NativeRendering
                        text: activeNet?.name ?? ""
                        font.pixelSize: 14; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }

                    Text {
                        renderType: Text.NativeRendering
                        visible: controlRoot.wifiIpAddress !== ""
                        text: "󰩟 " + controlRoot.wifiIpAddress
                        font.pixelSize: 11; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    implicitWidth: disBtnText.implicitWidth + 20; height: 26; radius: 0
                    color: disMouse.containsMouse ? Qt.rgba(1, 0.2, 0.2, 0.15) : Qt.rgba(1, 1, 1, 0.04)
                    border.width: 1; border.color: PanelColors.border

                    Text {
                        id: disBtnText
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "Disconnect"
                        font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                        color: disMouse.containsMouse ? PanelColors.error : PanelColors.textMain
                    }
                    MouseArea {
                        id: disMouse
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: controlRoot.wifiDisconnect()
                    }
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: visible ? 76 : 0
        visible: controlRoot.pendingWifiNet !== null && Networking.wifiEnabled
        radius: 0
        color: PanelColors.rowBackground
        border.width: 1
        border.color: PanelColors.border

        Column {
            anchors { fill: parent; margins: 10 }
            spacing: 8

            Text {
                renderType: Text.NativeRendering
                property bool enterprise: controlRoot.pendingWifiNet !== null
                    && (controlRoot.pendingWifiNet.security === WifiSecurityType.WpaEap
                    || controlRoot.pendingWifiNet.security === WifiSecurityType.Wpa2Eap)
                text: "Password for \"" + (controlRoot.pendingWifiNet?.name ?? "") + "\""
                    + (enterprise ? " (enterprise)" : "")
                font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
            }

            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: parent.width - 150; height: 26; radius: 0
                    color: PanelColors.textBox
                    border.color: PanelColors.border

                    Row {
                        anchors.fill: parent

                        TextInput {
                            id: wifiPskInput
                            width: parent.width - 24
                            anchors.verticalCenter: parent.verticalCenter
                            leftPadding: 8; rightPadding: 4
                            font.pixelSize: 13; font.family: FontConfig.fontFamily
                            color: PanelColors.textMain
                            echoMode: wifiPage.showPsk ? TextInput.Normal : TextInput.Password
                            clip: true
                            selectByMouse: true
                            onAccepted: controlRoot.submitWifiPassword()
                            Keys.onEscapePressed: controlRoot.cancelWifiPassword()

                            Connections {
                                target: controlRoot
                                function onPendingWifiNetChanged() {
                                    if (controlRoot.pendingWifiNet) {
                                        wifiPskInput.text = ""
                                        wifiPskInput.forceActiveFocus()
                                    } else {
                                        wifiPskInput.text = ""
                                    }
                                }
                            }
                        }

                        // Eye toggle button
                        Text {
                            renderType: Text.NativeRendering
                            anchors.verticalCenter: parent.verticalCenter
                            text: wifiPage.showPsk ? "󰈈" : "󰈉"
                            font.pixelSize: 12; font.family: FontConfig.fontFamily
                            color: eyeMouse.containsMouse ? PanelColors.textAccent : PanelColors.textDim
                            MouseArea {
                                id: eyeMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: wifiPage.showPsk = !wifiPage.showPsk
                            }
                        }
                    }
                }

                Rectangle {
                    width: 62; height: 26; radius: 0
                    color: pskOk.containsMouse ? PanelColors.pillActive : PanelColors.rowBackground
                    border.width: 1; border.color: PanelColors.border

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "Connect"
                        font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                        color: pskOk.containsMouse ? PanelColors.pillForeground : PanelColors.textMain
                    }
                    MouseArea {
                        id: pskOk
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: controlRoot.submitWifiPassword()
                    }
                }

                Rectangle {
                    width: 54; height: 26; radius: 0
                    color: pskCancel.containsMouse ? Qt.rgba(1, 0.2, 0.2, 0.15) : PanelColors.rowBackground
                    border.width: 1; border.color: PanelColors.border

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                        color: pskCancel.containsMouse ? PanelColors.error : PanelColors.textDim
                    }
                    MouseArea {
                        id: pskCancel
                        anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: controlRoot.cancelWifiPassword()
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: 6
        visible: Networking.wifiEnabled && knownNets.length > 0

        Row {
            width: parent.width
            spacing: 6

            Text {
                renderType: Text.NativeRendering
                text: "󰌾"
                font.pixelSize: 13; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: "SAVED NETWORKS"
                font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: Math.min(knownCol.implicitHeight + 8, 120)
            color: PanelColors.rowBackground
            border.width: 1
            border.color: PanelColors.border

            Flickable {
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: knownCol.implicitHeight
                clip: true
                interactive: contentHeight > height

                Column {
                    id: knownCol
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: wifiPage.knownNets

                        delegate: Rectangle {
                            id: kRow
                            required property var modelData

                            width: knownCol.width; height: 36; radius: 0
                            color: kMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : Qt.rgba(1, 1, 1, 0.02)

                            Row {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    text: controlRoot.wifiSignalGlyph(kRow.modelData.signalStrength)
                                    font.pixelSize: 15; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    width: kRow.width - 150
                                    text: kRow.modelData.name !== "" ? kRow.modelData.name : "(hidden network)"
                                    font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textMain
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    visible: kMouse.containsMouse
                                    text: "connect"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: kMouse.containsMouse
                                    text: "forget"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: kForget.containsMouse ? PanelColors.error : PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        id: kForget
                                        anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: controlRoot.wifiForget(kRow.modelData)
                                    }
                                }
                            }

                            MouseArea {
                                id: kMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlRoot.wifiConnect(kRow.modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // Divider Line
    Rectangle {
        width: parent.width
        height: 1
        color: PanelColors.border
        visible: Networking.wifiEnabled && knownNets.length > 0 && availableNets.length > 0
    }

    Column {
        width: parent.width
        spacing: 6
        visible: Networking.wifiEnabled

        // Section Header
        Row {
            width: parent.width
            spacing: 6

            Text {
                renderType: Text.NativeRendering
                text: "󰤨"
                font.pixelSize: 13; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: "AVAILABLE NETWORKS"
                font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Section Card Container
        Rectangle {
            width: parent.width
            height: availableNets.length > 0 ? Math.min(netCol.implicitHeight + 8, 200) : 48
            color: PanelColors.rowBackground
            border.width: 1
            border.color: PanelColors.border

            // Searching / Empty networks message inside card
            Text {
                anchors.centerIn: parent
                visible: availableNets.length === 0
                text: controlRoot.wifiScanning ? "Scanning for networks..." : "No available networks found"
                font.pixelSize: 12; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                renderType: Text.NativeRendering
            }

            // Flickable List
            Flickable {
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: netCol.implicitHeight
                clip: true
                interactive: contentHeight > height
                visible: availableNets.length > 0

                Column {
                    id: netCol
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: wifiPage.availableNets

                        delegate: Rectangle {
                            id: netRow
                            required property var modelData

                            readonly property bool secured:
                                typeof modelData.security === "string"
                                ? modelData.security !== "--"
                                : modelData.security !== WifiSecurityType.Open
                                && modelData.security !== WifiSecurityType.Unknown
                                && modelData.security !== WifiSecurityType.Owe

                            width: netCol.width; height: 36; radius: 0
                            color: netMouse.containsMouse || controlRoot.pendingWifiNet === modelData
                                ? Qt.lighter(PanelColors.rowBackground, 1.3) : Qt.rgba(1, 1, 1, 0.02)

                            Row {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    text: controlRoot.wifiSignalGlyph(netRow.modelData.signalStrength)
                                    font.pixelSize: 15; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
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
                                    width: netRow.width - 150
                                    text: netRow.modelData.name !== "" ? netRow.modelData.name : "(hidden network)"
                                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                                    color: PanelColors.textMain
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                z: 2
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    visible: netRow.modelData.stateChanging
                                        || netRow.modelData.state === ConnectionState.Connecting
                                    text: "connecting…"
                                    font.pixelSize: 11; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: netMouse.containsMouse && !netRow.modelData.stateChanging
                                    text: "connect"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: netMouse
                                anchors.fill: parent; hoverEnabled: true
                                z: 1
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlRoot.wifiConnect(netRow.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
