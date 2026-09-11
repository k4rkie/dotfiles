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

    property var buttonWidths: []
    readonly property int activeIndex: {
        for (let i = 0; i < visibleTags.length; i++) {
            if (visibleTags[i].is_active) return i
        }
        return 0
    }

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

    // Sliding indicator behind the active button
    Rectangle {
        id: indicator
        x: {
            var offset = 0
            for (var i = 0; i < root.activeIndex; i++)
                offset += (root.buttonWidths[i] || 0)
            return 2 + offset
        }
        width: root.buttonWidths[root.activeIndex] || 0
        height: 22
        anchors.verticalCenter: parent.verticalCenter
        color: PanelColors.workspaceActive
        visible: root.visibleTags.length > 0
        radius: 0


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
                onWidthChanged: {
                    var w = root.buttonWidths.slice()
                    w[index] = width
                    root.buttonWidths = w
                }
                height: 22
                // transparent when active so indicator shows through
                color: isActive ? "transparent" : (area.containsMouse ? PanelColors.rowBackground : "transparent")

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
