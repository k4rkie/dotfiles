import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../theme"

Rectangle {
    id: root
    height: 30
    width: trayRow.implicitWidth + 12
    visible: SystemTray.items.values.length > 0
    color: PanelColors.barBackground
    border.color: PanelColors.barBorder
    border.width: 2
    radius: 0

    // The parent PanelWindow, injected from StatusBar so QsMenuAnchor can anchor correctly.
    // Falls back to QsWindow.window attached property if not provided.
    property var barWindow: QsWindow.window

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: delegateRoot
                required property SystemTrayItem modelData
                width: 20
                height: 20

                readonly property var targetWindow: root.barWindow ? root.barWindow : delegateRoot.Window.window

                // Keep icon centered
                IconImage {
                    id: iconImg
                    anchors.centerIn: parent
                    source: delegateRoot.modelData.icon
                    implicitSize: 16
                    width: 16
                    height: 16
                    asynchronous: true
                }

                // DE-like menu anchor for DBusMenu applications
                QsMenuAnchor {
                    id: menuAnchor
                    anchor.window: delegateRoot.targetWindow
                    anchor.edges: Edges.Top
                    anchor.gravity: Edges.Top
                    menu: delegateRoot.modelData.menu
                    onVisibleChanged: console.log("[tray] DBusMenu visible:", visible, "for", delegateRoot.modelData.id)
                }

                function openTrayMenu() {
                    const win = delegateRoot.targetWindow
                    const pos = delegateRoot.mapToItem(null, 0, 0)
                    const itemWidth = delegateRoot.width
                    const itemHeight = delegateRoot.height

                    console.log("[tray] openTrayMenu for", delegateRoot.modelData.id,
                                "hasMenu:", delegateRoot.modelData.hasMenu,
                                "menu:", delegateRoot.modelData.menu,
                                "win:", win, "pos:", pos.x, pos.y)

                    // Update anchor rect with exact current item coordinates inside window
                    menuAnchor.anchor.rect = Qt.rect(pos.x, pos.y, itemWidth, itemHeight)

                    if (delegateRoot.modelData.hasMenu && delegateRoot.modelData.menu !== null) {
                        console.log("[tray] opening DBusMenu via QsMenuAnchor")
                        menuAnchor.open()
                    } else {
                        console.log("[tray] calling SNI display() for native popup at", pos.x, pos.y)
                        try {
                            if (win) {
                                delegateRoot.modelData.display(win, Math.round(pos.x), Math.round(pos.y))
                            } else {
                                delegateRoot.modelData.secondaryActivate()
                            }
                        } catch (e) {
                            console.log("[tray] display failed, falling back to secondaryActivate", e)
                            delegateRoot.modelData.secondaryActivate()
                        }
                    }
                }

                MouseArea {
                    id: tipArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    // Scroll on tray icon (e.g., volume)
                    onWheel: (wheel) => {
                        const delta = wheel.angleDelta.y > 0 ? 1 : -1
                        const horizontal = Math.abs(wheel.angleDelta.x) > Math.abs(wheel.angleDelta.y)
                        delegateRoot.modelData.scroll(horizontal ? (wheel.angleDelta.x > 0 ? 1 : -1) : delta, horizontal)
                    }

                    onEntered: iconImg.opacity = 0.7
                    onExited: iconImg.opacity = 1.0

                    onClicked: (mouse) => {
                        console.log("[tray] clicked", delegateRoot.modelData.id,
                                    "button:", mouse.button,
                                    "onlyMenu:", delegateRoot.modelData.onlyMenu,
                                    "hasMenu:", delegateRoot.modelData.hasMenu)

                        if (mouse.button === Qt.LeftButton) {
                            // Waybar behavior: if an item has a menu (or is menu-only), left click pops up the menu!
                            if (delegateRoot.modelData.hasMenu || delegateRoot.modelData.onlyMenu) {
                                delegateRoot.openTrayMenu()
                            } else {
                                console.log("[tray] left activate")
                                delegateRoot.modelData.activate()
                            }
                        } else if (mouse.button === Qt.RightButton) {
                            delegateRoot.openTrayMenu()
                        } else if (mouse.button === Qt.MiddleButton) {
                            console.log("[tray] middle secondaryActivate")
                            delegateRoot.modelData.secondaryActivate()
                        }
                    }

                    onPressAndHold: {
                        delegateRoot.openTrayMenu()
                    }
                }
            }
        }
    }
}
