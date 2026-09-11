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
                visible: controlRoot.page === "clipboard"

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        renderType: Text.NativeRendering
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Clipboard"
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                    Text {
                        renderType: Text.NativeRendering
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: "left: copy   right: delete"
                        font.pixelSize: 13; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                    }
                }

                Item {
                    width: parent.width
                    height: Math.min(clipCol.implicitHeight, 300)

                    Flickable {
                        anchors.fill: parent
                        contentHeight: clipCol.implicitHeight
                        clip: true
                        interactive: contentHeight > height

                        Column {
                            id: clipCol
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: controlRoot.clipEntries
                                delegate: Rectangle {
                                    id: clipRow
                                    required property var modelData

                                    readonly property string imgPath: "/tmp/qs-cc-clip-" + modelData.index + ".png"

                                    width: clipCol.width; height: modelData.isImage ? 160 : 32; radius: 0
                                    color: clipMouse.containsMouse ? Qt.lighter(PanelColors.rowBackground, 1.25) : PanelColors.rowBackground

                                    Component.onCompleted: {
                                        if (modelData.isImage)
                                            controlRoot.enqueueClipImage(modelData.index, modelData.raw)
                                    }

                                    // image entry: same preview style as the launcher's clipboard view
                                    Item {
                                        visible: clipRow.modelData.isImage
                                        anchors {
                                            top: parent.top; topMargin: 8
                                            bottom: parent.bottom; bottomMargin: 8
                                            left: parent.left; leftMargin: 14
                                            right: parent.right; rightMargin: 12
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            color: PanelColors.rowBackground
                                            visible: imgPreviewImg.status !== Image.Ready
                                        }

                                        Image {
                                            id: imgPreviewImg
                                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                                            width: status === Image.Ready
                                                ? Math.min(implicitWidth, parent.width)
                                                : parent.width
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            cache: false
                                            smooth: true
                                            mipmap: true
                                            sourceSize: Qt.size(480, 480)
                                            source: "file://" + clipRow.imgPath

                                            Connections {
                                                target: controlRoot
                                                function onClipDecodeReadyChanged() {
                                                    if (controlRoot.clipDecodeReady && controlRoot.clipDecodingId === clipRow.modelData.index) {
                                                        imgPreviewImg.source = ""
                                                        imgPreviewImg.source = "file://" + clipRow.imgPath
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            anchors.centerIn: imgPreviewImg
                                            color: "transparent"
                                            border.color: PanelColors.border
                                            border.width: 3
                                            width: imgPreviewImg.paintedWidth + border.width * 2
                                            height: imgPreviewImg.paintedHeight + border.width * 2
                                            visible: imgPreviewImg.status === Image.Ready
                                        }
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: !clipRow.modelData.isImage
                                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                        text: clipRow.modelData.preview.replace(/\n/g, " ")
                                        font.pixelSize: 16; font.family: FontConfig.fontFamily
                                        color: PanelColors.textMain
                                        elide: Text.ElideRight
                                    }
                                    MouseArea {
                                        id: clipMouse
                                        anchors.fill: parent; hoverEnabled: true
                                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: (mouse) => {
                                            if (mouse.button === Qt.RightButton) controlRoot.clipDelete(modelData.index)
                                            else controlRoot.clipCopy(modelData.index)
                                        }
                                    }
                                }
                            }

                            Text {
                                renderType: Text.NativeRendering
                                width: clipCol.width
                                visible: controlRoot.clipEntries.length === 0
                                text: "clipboard history is empty"
                                font.pixelSize: 16; font.family: FontConfig.fontFamily
                                color: PanelColors.textDim
                                horizontalAlignment: Text.AlignHCenter
                                topPadding: 12
                            }
                        }
                    }
                }
            }
