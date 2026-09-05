import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "theme"

// Transient notification toasts, stacked at the top-right corner of the
// screen. Fed by the shared NotifState singleton; each card auto-expires after
// 5s (or on click), while the notification stays in the control center's
// history page.
PanelWindow {
    id: root
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; right: true }
    margins { top: 8; right: 8 }

    implicitWidth: 360
    implicitHeight: toastList.contentHeight
    visible: NotifState.toasts.count > 0

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    ListView {
        id: toastList
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: contentHeight
        spacing: 6
        interactive: false
        model: NotifState.toasts

        delegate: Rectangle {
            id: toastCard
            required property var modelData

            readonly property bool isCritical:
                modelData.urgency === NotificationUrgency.Critical

            // icon hint: raw image → file path → theme icon name → letter
            readonly property string iconSource: {
                if (modelData.image !== "") return modelData.image
                if (modelData.appIcon === "") return ""
                if (modelData.appIcon.startsWith("/")) return "file://" + modelData.appIcon
                return Quickshell.iconPath(modelData.appIcon)
            }

            width: toastList.width
            height: contentRow.implicitHeight + 24; radius: 0
            color: PanelColors.popupBackground
            border.color: PanelColors.border
            border.width: 1

            Row {
                id: contentRow
                anchors { left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12; top: parent.top; topMargin: 12 }
                spacing: 12

                Rectangle {
                    width: 42; height: 42; radius: 0
                    color: PanelColors.rowBackground
                    border.width: 1
                    border.color: PanelColors.border
                    clip: true

                    Image {
                        anchors.fill: parent; anchors.margins: 2
                        source: toastCard.iconSource
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: toastCard.iconSource !== ""
                    }
                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        visible: toastCard.iconSource === ""
                        text: toastCard.modelData.appName !== "" ? toastCard.modelData.appName.charAt(0).toUpperCase() : "?"
                        font.pixelSize: 18; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textAccent
                    }
                }

                Column {
                    spacing: 6
                    width: parent.width - 42 - parent.spacing

                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        topPadding: 2
                        text: toastCard.modelData.summary !== "" ? toastCard.modelData.summary : toastCard.modelData.appName
                        font.pixelSize: 16; font.bold: true; font.family: FontConfig.fontFamily
                        color: PanelColors.textMain
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                    }
                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        topPadding: 0
                        visible: toastCard.modelData.body !== ""
                        text: toastCard.modelData.body
                        font.pixelSize: 12; font.family: FontConfig.fontFamily
                        color: PanelColors.textDim
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                    }
                }
            }

            MouseArea {
                anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotifState.dismissToast(toastCard.modelData)
            }

            Timer {
                interval: toastCard.modelData.expireTimeout > 0 ? toastCard.modelData.expireTimeout : 5000
                running: !toastCard.isCritical
                onTriggered: NotifState.dismissToast(toastCard.modelData)
            }
        }
    }
}
