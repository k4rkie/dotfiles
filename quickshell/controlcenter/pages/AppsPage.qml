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
                visible: controlRoot.page === "apps"
                onVisibleChanged: {
                    if (visible) { controlRoot.ccAppsSearch = ""; ccAppsSearchInput.text = ""; controlRoot.ccAppsFilterTimer.restart(); Qt.callLater(function(){ ccAppsSearchInput.forceActiveFocus() }) }
                    else { controlRoot.ccAppsSearch = ""; if (ccAppsSearchInput) ccAppsSearchInput.text = ""; controlRoot.ccAppsSelected = -1; controlRoot.ccAppsFiltered = []; }
                }

                Rectangle {
                    width: parent.width; height: 36; radius: 0
                    color: PanelColors.rowBackground; border.width: 1; border.color: PanelColors.border
                    Row {
                        anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Text { text: ""; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim; anchors.verticalCenter: parent.verticalCenter; renderType: Text.NativeRendering }
                        TextInput {
                            id: ccAppsSearchInput
                            width: parent.width - 20
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textMain
                            focus: controlRoot.page === "apps"
                            property string placeholderText: "Search apps..."
                            onTextChanged: { controlRoot.ccAppsSearch = text; controlRoot.ccAppsFilterTimer.restart() }
                            onAccepted: {
                                var idx = controlRoot.ccAppsSelected >= 0 ? controlRoot.ccAppsSelected : (controlRoot.ccAppsFiltered.length > 0 ? controlRoot.ccAppsFiltered[0] : -1)
                                if (idx >= 0) controlRoot.ccAppsLaunch(idx)
                                else if (text.trim() !== "") { Quickshell.execDetached(["bash","-c", text]); controlRoot.close() }
                            }
                            Text {
                                anchors.fill: parent; verticalAlignment: Text.AlignVCenter
                                text: ccAppsSearchInput.placeholderText; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                                opacity: 0.6
                                visible: ccAppsSearchInput.text === ""
                            }
                            Keys.onEscapePressed: controlRoot.page = "main"
                            Keys.onUpPressed: {
                                var i = controlRoot.ccAppsFiltered.indexOf(controlRoot.ccAppsSelected)
                                if (i > 0) { controlRoot.ccAppsSelected = controlRoot.ccAppsFiltered[i-1]; ccAppsList.positionViewAtIndex(i-1, ListView.Contain) }
                            }
                            Keys.onDownPressed: {
                                var i = controlRoot.ccAppsFiltered.indexOf(controlRoot.ccAppsSelected)
                                if (i >= 0 && i < controlRoot.ccAppsFiltered.length - 1) { controlRoot.ccAppsSelected = controlRoot.ccAppsFiltered[i+1]; ccAppsList.positionViewAtIndex(i+1, ListView.Contain) }
                                else if (controlRoot.ccAppsFiltered.length > 0 && i === -1) { controlRoot.ccAppsSelected = controlRoot.ccAppsFiltered[0] }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: controlRoot.ccAppsFiltered.length === 0 ? 70 : Math.min(ccAppsList.contentHeight, 260)
                    clip: true
                    ListView {
                        id: ccAppsList
                        anchors.fill: parent
                        spacing: 2
                        clip: true
                        model: controlRoot.ccAppsFiltered
                        delegate: Item {
                            required property var modelData
                            required property int index
                            readonly property int origIdx: modelData
                            readonly property var entry: DesktopEntries.applications.values[origIdx]
                            readonly property bool isSelected: controlRoot.ccAppsSelected === origIdx
                            width: ccAppsList.width; height: 36
                            Rectangle {
                                anchors { fill: parent; leftMargin: 2; rightMargin: 2 }
                                radius: 0
                                color: isSelected ? PanelColors.launcher : ccAppHover.containsMouse ? PanelColors.rowBackground : "transparent"
                                Row {
                                    anchors { fill: parent; leftMargin: 10; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                    spacing: 10
                                    IconImage { anchors.verticalCenter: parent.verticalCenter; implicitSize: 22; source: entry ? Quickshell.iconPath(entry.icon) : "" }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry ? entry.name : ""; font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily
                                        color: isSelected ? PanelColors.pillForeground : PanelColors.textMain; elide: Text.ElideRight
                                        width: parent.width - 22 - 10 - 8; renderType: Text.NativeRendering
                                    }
                                }
                                MouseArea {
                                    id: ccAppHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onEntered: controlRoot.ccAppsSelected = origIdx
                                    onClicked: controlRoot.ccAppsLaunch(origIdx)
                                }
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: controlRoot.ccAppsFiltered.length === 0
                        text: controlRoot.ccAppsSearch === "" ? "No apps" : "No match"
                        font.pixelSize: FontConfig.size - 2; font.family: FontConfig.fontFamily; color: PanelColors.textDim
                        renderType: Text.NativeRendering
                    }
                }
            }
