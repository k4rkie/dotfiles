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


            Column {
    required property var controlRoot
                width: parent.width
                spacing: 8
                visible: controlRoot.page === "bluetooth"

                onVisibleChanged: {
                    if (controlRoot.btAdapter) {
                        controlRoot.btAdapter.discovering = visible
                    } else {
                        controlRoot.btCliSetScanning(visible)
                        if (visible) controlRoot.refreshBtCliDevices()
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
                        checked: btAdapter ? (btAdapter.enabled ?? false) : controlRoot.btCliState === "on"
                        onToggled: controlRoot.toggleBluetooth()
                    }
                }

                Row {
                    width: parent.width
                    spacing: 8
                    visible: btAdapter !== null && controlRoot.btPowered

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
                    visible: !controlRoot.btPowered
                    text: "bluetooth is turned off"
                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 6
                }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: controlRoot.btPowered && controlRoot.btPairedList.length > 0
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
                            model: controlRoot.btPairedList

                            delegate: Rectangle {
                                id: pairedRow
                                required property var modelData

                                width: btPairedCol.width; height: 36; radius: 0
                                color: devMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground

                                Row {
                                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 10

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: controlRoot.btDeviceGlyph(pairedRow.modelData.icon)
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
                                        property int battPct: controlRoot.btBatteryPct(pairedRow.modelData)
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

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: controlRoot.btPowered && controlRoot.btNearbyList.length > 0
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
                            model: controlRoot.btNearbyList

                            delegate: Rectangle {
                                id: nearbyRow
                                required property var modelData

                                width: btNearbyCol.width; height: 34; radius: 0
                                color: nearMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground

                                Row {
                                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 10

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: controlRoot.btDeviceGlyph(nearbyRow.modelData.icon)
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

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: controlRoot.btPowered && controlRoot.btNearbyList.length === 0
                    text: "searching for devices…"
                    font.pixelSize: 13; font.family: FontConfig.fontFamily
                    color: PanelColors.textDim
                    horizontalAlignment: Text.AlignHCenter
                }
            }
