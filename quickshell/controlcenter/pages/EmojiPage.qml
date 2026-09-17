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
                id: emojiPage
    required property var controlRoot
                width: parent.width
                spacing: 8
                visible: controlRoot.page === "emoji"
                onVisibleChanged: if (visible) { controlRoot._emojiQuery = ""; controlRoot.emojiLoad(); Qt.callLater(function(){ emojiSearchInput.forceActiveFocus() }) }

                function _emojiMoveLocal(colDelta, rowDelta) {
                    if (controlRoot.emojiFiltered.length === 0) return
                    var cols = 8
                    var maxIdx = controlRoot.emojiFiltered.length - 1
                    var cur = emojiGrid.currentIndex < 0 ? 0 : emojiGrid.currentIndex
                    var next = Math.max(0, Math.min(cur + colDelta + rowDelta * cols, maxIdx))
                    emojiGrid.currentIndex = next
                    emojiGrid.positionViewAtIndex(next, GridView.Contain)
                }

                Rectangle {
                    width: parent.width; height: 36; radius: 0
                    color: PanelColors.rowBackground; border.width: 1; border.color: PanelColors.border
                    Row {
                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text { text: "󰞅"; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter; renderType: Text.NativeRendering }
                        TextInput {
                            id: emojiSearchInput
                            width: parent.width - 20
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textMain
                            focus: controlRoot.page === "emoji"
                            property string placeholderText: "Search emoji..."
                            onTextChanged: { controlRoot._emojiQuery = text; controlRoot._applyEmojiFilter() }
                            onAccepted: {
                                if (controlRoot.emojiFiltered.length > 0) { controlRoot.emojiCopyProc.copyEmoji(controlRoot.emojiFiltered[emojiGrid.currentIndex].char); controlRoot.close() }
                            }
                            Text {
                                anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                                text: emojiSearchInput.placeholderText; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                                opacity: 0.6
                                visible: emojiSearchInput.text === ""
                            }
                            Keys.onEscapePressed: controlRoot.page = "main"
                            Keys.onUpPressed: emojiPage._emojiMoveLocal(0, -1)
                            Keys.onDownPressed: emojiPage._emojiMoveLocal(0, 1)
                            Keys.onLeftPressed: emojiPage._emojiMoveLocal(-1, 0)
                            Keys.onRightPressed: emojiPage._emojiMoveLocal(1, 0)
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 280
                    clip: true
                    GridView {
                        id: emojiGrid
                        anchors.fill: parent
                        clip: true
                        visible: controlRoot.emojiFiltered.length > 0
                        cellWidth: Math.floor(width / 8)
                        cellHeight: Math.floor(width / 8)
                        model: controlRoot.emojiFiltered
                        currentIndex: controlRoot.emojiSelected
                        onCurrentIndexChanged: controlRoot.emojiSelected = currentIndex
                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: emojiGrid.cellWidth; height: emojiGrid.cellHeight
                            Rectangle {
                                anchors { fill: parent; margins: 2 }
                                radius: 0
                                color: emojiMouse.containsMouse || index === emojiGrid.currentIndex ? Qt.rgba(1,1,1,0.10) : "transparent"
                                border.color: index === emojiGrid.currentIndex ? PanelColors.launcher : "transparent"
                                border.width: 2
                                Text { anchors.centerIn: parent; text: modelData.char; font.family: "Noto Color Emoji"; font.pixelSize: 26; renderType: Text.NativeRendering }
                            }
                            MouseArea {
                                id: emojiMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: { controlRoot.emojiCopyProc.copyEmoji(modelData.char); controlRoot.close() }
                                onEntered: emojiGrid.currentIndex = index
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: controlRoot.emojiFiltered.length === 0
                        text: "No matches"
                        font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                        renderType: Text.NativeRendering
                    }
                }
            }
