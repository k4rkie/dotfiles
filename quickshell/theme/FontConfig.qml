pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    readonly property string fontFamily: "Maple Mono NF"

    readonly property int size: 18
    readonly property int sizeSmall: size - 4
    readonly property int sizeTiny: size - 6
}
