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
                spacing: 6
                visible: controlRoot.page === "notifications"

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
                        visible: controlRoot.notificationHistory.count > 0
                        text: "clear all"
                        font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                        color: clearNotiMouse.containsMouse ? PanelColors.error : PanelColors.textDim
                        MouseArea {
                            id: clearNotiMouse
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controlRoot.clearNotifications()
                        }
                    }
                }

                Text {
                    renderType: Text.NativeRendering
                    width: parent.width
                    visible: controlRoot.notificationHistory.count === 0
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
                    model: controlRoot.notificationHistory

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: notiList.width
                        height: notiRow.implicitHeight + 20; radius: 0
                        color: notiMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground
                        Behavior on color { ColorAnimation { duration: 0 } }

                        Row {
                            id: notiRow
                            anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; top: parent.top; topMargin: 10 }
                            spacing: 10

                            Rectangle {
                                width: 42; height: 42; radius: 0
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
                                    font.pixelSize: 18; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textAccent
                                }
                            }

                            Column {
                                spacing: 5
                                width: parent.width - 42 - notiTimeText.width - parent.spacing * 2

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    topPadding: 2
                                    text: modelData.summary !== "" ? modelData.summary : modelData.appName
                                    font.pixelSize: 15; font.bold: true; font.family: FontConfig.fontFamily
                                    color: PanelColors.textMain
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                }
                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    topPadding: 0
                                    visible: modelData.body !== ""
                                    text: modelData.body
                                    font.pixelSize: 12; font.family: FontConfig.fontFamily
                                    color: PanelColors.textDim
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 3
                                }
                            }

                            Text {
                                id: notiTimeText
                                renderType: Text.NativeRendering
                                anchors.verticalCenter: parent.verticalCenter
                                text: controlRoot.fmtNotiTime(modelData.timestamp)
                                font.pixelSize: 12; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                            }
                        }

                        MouseArea {
                            id: notiMouse
                            anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: controlRoot.removeNotification(index)
                        }
                    }
                }
            }
