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
                id: wallPage
                width: parent.width
                spacing: 8
                visible: controlRoot.page === "wallpaper"

                onVisibleChanged: {
                    if (visible) {
                        controlRoot.loadWallpapers()
                        wallSearch.text = ""
                        Qt.callLater(function(){ wallSearch.forceActiveFocus() })
                    } else {
                        if (wallSearch) wallSearch.text = ""
                    }
                }

                // name filter; empty query = everything
                readonly property var filteredWalls: {
                    const q = wallSearch.text.toLowerCase().trim()
                    if (q === "") return controlRoot.wallEntries
                    return controlRoot.wallEntries.filter(e => e.wallName.toLowerCase().includes(q))
                }

                Rectangle {
                    width: parent.width; height: 36; radius: 0
                    color: PanelColors.rowBackground; border.width: 1; border.color: PanelColors.border
                    Row {
                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text { text: ""; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter; renderType: Text.NativeRendering }
                        TextInput {
                            id: wallSearch
                            width: parent.width - 20
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textMain
                            focus: controlRoot.page === "wallpaper"
                            property string placeholderText: "Search wallpapers..."
                            clip: true
                            selectByMouse: true
                            Keys.onEscapePressed: controlRoot.page = "main"
                            Text {
                                anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                                text: wallSearch.placeholderText; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                                opacity: 0.6
                                visible: wallSearch.text === ""
                            }
                        }
                    }
                }

                // Fixed height so fewer results never shrink the menu.
                Item {
                    width: parent.width
                    height: 320
                    clip: true

                    GridView {
                        id: wallGrid
                        anchors.fill: parent
                        clip: true
                        visible: wallPage.filteredWalls.length > 0

                        readonly property int cols: 3
                        readonly property int thumbW: Math.floor((width - 8) / cols)
                        readonly property int thumbH: Math.floor(thumbW * 0.58)
                        cellWidth: thumbW
                        cellHeight: thumbH
                        model: wallPage.filteredWalls

                        delegate: Item {
                            required property var modelData
                            width: wallGrid.cellWidth
                            height: wallGrid.cellHeight

                            Column {
                                anchors { fill: parent; margins: 4 }
                                spacing: 4

                                Rectangle {
                                    width: parent.width
                                    height: wallGrid.thumbH - 8
                                    radius: 0
                                    color: PanelColors.rowBackground
                                    border.width: wallHover.containsMouse ? 2 : 1
                                    border.color: wallHover.containsMouse ? PanelColors.launcher : PanelColors.border

                                    Image {
                                        anchors.fill: parent; anchors.margins: 2
                                        source: "file://" + modelData.filePath
                                        sourceSize: Qt.size(256, 160)
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        smooth: true
                                        mipmap: true
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        visible: modelData.isVideo
                                        anchors { right: parent.right; bottom: parent.bottom; margins: 4 }
                                        text: "VID"
                                        font.pixelSize: 13; font.bold: true; font.family: FontConfig.fontFamily
                                        color: PanelColors.scanning
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    height: 18
                                    visible: false
                                    opacity: 0
                                    text: modelData.wallName
                                    font.pixelSize: 12; font.bold: true; font.family: FontConfig.fontFamily
                                    color: wallHover.containsMouse ? PanelColors.launcher : PanelColors.textMain
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: wallHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: controlRoot.wallpaperSetProc.apply(modelData.filePath, modelData.isVideo)
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: wallPage.filteredWalls.length === 0
                        text: "No matches"
                        font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                        renderType: Text.NativeRendering
                    }
                }
            }
