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
                visible: controlRoot.page === "wifi"

                onVisibleChanged: {
                    if (visible) {
                        controlRoot.kickWifiScan()
                        controlRoot.wifiRecoverTimer.restart()
                    }
                    if (!visible) controlRoot.cancelWifiPassword()
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
                        onToggled: controlRoot.toggleWifi()
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
                                model: controlRoot.wifiSortedNetworks

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
                                    color: netMouse.containsMouse || controlRoot.pendingWifiNet === modelData
                                        ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground

                                    Row {
                                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                        spacing: 10

                                        Text {
                                            renderType: Text.NativeRendering
                                            text: controlRoot.wifiSignalGlyph(netRow.modelData.signalStrength)
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
                                                    controlRoot.wifiForget(netRow.modelData)
                                                }
                                            }
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

                            Text {
                                renderType: Text.NativeRendering
                                width: netCol.width
                                visible: controlRoot.wifiSortedNetworks.length === 0
                                text: controlRoot.wifiScanning ? "scanning for networks…" : "no networks found"
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
                    visible: controlRoot.pendingWifiNet !== null
                    radius: 0
                    color: Qt.lighter(PanelColors.rowBackground, 1.25)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)

                    Column {
                        anchors { fill: parent; margins: 8 }
                        spacing: 6

                        Text {
                            renderType: Text.NativeRendering
                            property bool enterprise: controlRoot.pendingWifiNet !== null
                                && (controlRoot.pendingWifiNet.security === WifiSecurityType.WpaEap
                                || controlRoot.pendingWifiNet.security === WifiSecurityType.Wpa2Eap)
                            text: "password for \"" + (controlRoot.pendingWifiNet?.name ?? "") + "\""
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
                                    onAccepted: controlRoot.submitWifiPassword()
                                    Keys.onEscapePressed: controlRoot.cancelWifiPassword()
                                    cursorDelegate: Rectangle { width: 1; height: 14; color: PanelColors.textDim }

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
                                    onClicked: controlRoot.submitWifiPassword()
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
                                    onClicked: controlRoot.cancelWifiPassword()
                                }
                            }
                        }
                    }
                }
            }
