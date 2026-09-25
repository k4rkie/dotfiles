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
    id: wallPage
    required property var controlRoot
    width: parent.width
    spacing: 12
    visible: controlRoot.page === "bluetooth"

    onVisibleChanged: {
        if (visible) {
            controlRoot.queryBtState()
            if (controlRoot.btPowered) {
                controlRoot.setBtScanning(true)
            }
            if (!controlRoot.btAdapter) {
                controlRoot.refreshBtCliDevices()
            }
        }
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
                text: "󰂯"
                font.pixelSize: 18; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: "Bluetooth"
                font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ToggleSwitch {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            checked: controlRoot.btPowered
            onToggled: controlRoot.toggleBluetooth()
        }
    }

    // Controls Row (Discoverable & Scanning)
    Row {
        width: parent.width
        spacing: 8
        visible: controlRoot.btPowered && controlRoot.btHasAdapter

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
                checked: controlRoot.btAdapter?.discoverable ?? false
                onToggled: {
                    if (controlRoot.btAdapter)
                        controlRoot.btAdapter.discoverable = !controlRoot.btAdapter.discoverable
                }
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
                checked: controlRoot.btAdapter ? (controlRoot.btAdapter.discovering ?? false) : true
                onToggled: {
                    const isScanning = controlRoot.btAdapter ? controlRoot.btAdapter.discovering : true
                    controlRoot.setBtScanning(!isScanning)
                }
            }
        }
    }

    // Off state message
    Text {
        renderType: Text.NativeRendering
        width: parent.width
        visible: !controlRoot.btPowered && controlRoot.btHasAdapter
        text: "Bluetooth is turned off"
        font.pixelSize: 13; font.family: FontConfig.fontFamily
        color: PanelColors.textDim
        horizontalAlignment: Text.AlignHCenter
        topPadding: 12
    }

    // No adapter message
    Text {
        renderType: Text.NativeRendering
        width: parent.width
        visible: !controlRoot.btHasAdapter
        text: "No Bluetooth adapter detected"
        font.pixelSize: 13; font.family: FontConfig.fontFamily
        color: PanelColors.textDim
        horizontalAlignment: Text.AlignHCenter
        topPadding: 12
    }

    // =========================================================================
    // SECTION 1: PAIRED DEVICES
    // =========================================================================
    Column {
        width: parent.width
        spacing: 6
        visible: controlRoot.btPowered

        // Section Header
        Row {
            width: parent.width
            spacing: 6

            Text {
                renderType: Text.NativeRendering
                text: "󰂱"
                font.pixelSize: 13; font.family: FontConfig.fontFamily
                color: PanelColors.textAccent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                renderType: Text.NativeRendering
                text: "PAIRED DEVICES"
                font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Section Card Container
        Rectangle {
            width: parent.width
            height: controlRoot.btPairedList.length > 0 ? Math.min(btPairedCol.implicitHeight + 8, 180) : 42
            color: PanelColors.rowBackground
            border.width: 1
            border.color: PanelColors.border

            // Empty paired devices fallback message
            Text {
                anchors.centerIn: parent
                visible: controlRoot.btPairedList.length === 0
                text: "No paired devices"
                font.pixelSize: 12; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                renderType: Text.NativeRendering
            }

            // List
            Flickable {
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: btPairedCol.implicitHeight
                clip: true
                interactive: contentHeight > height
                visible: controlRoot.btPairedList.length > 0

                Column {
                    id: btPairedCol
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: controlRoot.btPairedList

                        delegate: Rectangle {
                            id: pairedRow
                            required property var modelData

                            width: btPairedCol.width; height: 38; radius: 0
                            color: devMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : Qt.rgba(1, 1, 1, 0.02)
                            border.width: 1
                            border.color: pairedRow.modelData.connected ? Qt.rgba(1, 1, 1, 0.08) : Qt.transparent

                            Row {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    text: controlRoot.btDeviceGlyph(pairedRow.modelData.icon, pairedRow.modelData.name)
                                    font.pixelSize: 16; font.family: FontConfig.fontFamily
                                    color: pairedRow.modelData.connected ? PanelColors.pillActive : PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    width: pairedRow.width - 180
                                    text: pairedRow.modelData.name !== "" ? pairedRow.modelData.name : pairedRow.modelData.address
                                    font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                    color: pairedRow.modelData.connected ? PanelColors.textAccent : PanelColors.textMain
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    visible: pairedRow.modelData.batteryAvailable
                                    property int battPct: controlRoot.btBatteryPct(pairedRow.modelData)
                                    text: "󰥉 " + battPct + "%"
                                    font.pixelSize: 11; font.family: FontConfig.fontFamily
                                    color: battPct < 20 ? PanelColors.error : PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: pairedRow.modelData.connected
                                    text: "connected"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.pillActive
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: devMouse.containsMouse
                                    text: pairedRow.modelData.connected ? "disconnect" : "connect"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    visible: devMouse.containsMouse
                                    text: "forget"
                                    font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                    color: removeMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        id: removeMouse
                                        anchors.fill: parent; hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: controlRoot.btForgetDevice(pairedRow.modelData)
                                    }
                                }
                            }

                            MouseArea {
                                id: devMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlRoot.btToggleDevice(pairedRow.modelData)
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
        visible: controlRoot.btPowered
    }

    // =========================================================================
    // SECTION 2: NEARBY DEVICES
    // =========================================================================
    Column {
        width: parent.width
        spacing: 6
        visible: controlRoot.btPowered

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
                text: "NEARBY DEVICES"
                font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Section Card Container
        Rectangle {
            width: parent.width
            height: controlRoot.btNearbyList.length > 0 ? Math.min(btNearbyCol.implicitHeight + 8, 150) : 48
            color: PanelColors.rowBackground
            border.width: 1
            border.color: PanelColors.border

            // Searching / Empty nearby message inside card
            Text {
                anchors.centerIn: parent
                visible: controlRoot.btNearbyList.length === 0
                text: (controlRoot.btAdapter?.discovering ?? false) ? "Searching for nearby devices..." : "No nearby devices found"
                font.pixelSize: 12; font.family: FontConfig.fontFamily
                color: PanelColors.textDim
                renderType: Text.NativeRendering
            }

            // List
            Flickable {
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: btNearbyCol.implicitHeight
                clip: true
                interactive: contentHeight > height
                visible: controlRoot.btNearbyList.length > 0

                Column {
                    id: btNearbyCol
                    width: parent.width
                    spacing: 4

                    Repeater {
                        model: controlRoot.btNearbyList

                        delegate: Rectangle {
                            id: nearbyRow
                            required property var modelData

                            width: btNearbyCol.width; height: 36; radius: 0
                            color: nearMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.3) : Qt.rgba(1, 1, 1, 0.02)

                            Row {
                                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Text {
                                    renderType: Text.NativeRendering
                                    text: controlRoot.btDeviceGlyph(nearbyRow.modelData.icon, nearbyRow.modelData.name)
                                    font.pixelSize: 16; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    width: nearbyRow.width - 140
                                    text: nearbyRow.modelData.name !== "" ? nearbyRow.modelData.name : nearbyRow.modelData.address
                                    font.pixelSize: 13; font.family: FontConfig.fontFamily
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
                                font.pixelSize: 11; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                            }
                            Text {
                                renderType: Text.NativeRendering
                                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                visible: !nearbyRow.modelData.pairing && nearMouse.containsMouse
                                text: "pair & connect"
                                font.pixelSize: 11; font.bold: true; font.family: FontConfig.fontFamily
                                color: PanelColors.textAccent
                            }

                            MouseArea {
                                id: nearMouse
                                anchors.fill: parent; hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlRoot.btToggleDevice(nearbyRow.modelData)
                            }

                            Connections {
                                target: controlRoot.btAdapter ? nearbyRow.modelData : null
                                function onPairedChanged() {
                                    if (!controlRoot.btAdapter) return
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
    }
}
