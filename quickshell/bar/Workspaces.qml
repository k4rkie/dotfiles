import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    height: 30
    width: row.implicitWidth + 4
    visible: visibleTags.length > 0
    color: PanelColors.barBackground
    border.color: PanelColors.border
    border.width: 2
    radius: 0

    property var tags: []

    readonly property var visibleTags: {
        const out = []
        for (let i = 0; i < root.tags.length; i++) {
            const t = root.tags[i]
            if (t.client_count > 0 || t.is_active) out.push(t)
        }
        return out
    }

    readonly property var labels: ({
        1: "one", 2: "two", 3: "three", 4: "four", 5: "five",
        6: "six", 7: "seven", 8: "eight", 9: "nine"
    })

    Process {
        id: watchProc
        running: true
        command: ["mmsg", "watch", "all-tags"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.trim() === "") return
                try {
                    const parsed = JSON.parse(data)
                    const all = parsed.all_tags
                    if (all && all.length > 0) root.tags = all[0].tags
                } catch (e) {}
            }
        }
    }

    function switchTo(index) {
        Quickshell.execDetached(["mmsg", "dispatch", "view," + index])
    }

    Row {
        id: row
        x: 2
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Repeater {
            model: root.visibleTags
            delegate: Rectangle {
                required property var modelData
                required property int index
                readonly property int tagIndex: modelData.index
                readonly property bool isActive: modelData.is_active

                width: Math.max(isActive ? 48 : 36, wsLabel.implicitWidth + 16)
                height: 22
                color: isActive ? PanelColors.workspaceActive : (area.containsMouse ? PanelColors.rowBackground : PanelColors.barBackground)

                Text {
                    id: wsLabel
                    anchors.centerIn: parent
                    text: root.labels[tagIndex]
                    font.family: FontConfig.fontFamily
                    font.pixelSize: FontConfig.size
                    color: isActive ? PanelColors.barBackground : (area.containsMouse ? PanelColors.textAccent : PanelColors.workspaceInactive)
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchTo(tagIndex)
                }
            }
        }
    }
}
