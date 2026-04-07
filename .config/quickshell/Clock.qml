// Clock widget – mirrors the waybar clock module.
// Format: "yyyy-MM-dd HH:mm" matching waybar's "%Y-%m-%d %H:%M".
// Updates every second (matching interval: 1 in modules.jsonc).
import QtQuick

Item {
    id: root

    property string timeText: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")

    implicitWidth:  clockLabel.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    Timer {
        interval:    1000
        running:     true
        repeat:      true
        onTriggered: root.timeText = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm")
    }

    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
            leftMargin:   2
        }

        color:        Colors.backgroundPrimary
        radius:       12
        border.color: Colors.teal
        border.width: 4

        Text {
            id:             clockLabel
            anchors.centerIn: parent
            text:           root.timeText
            color:          Colors.teal
            font.family:    "JetBrains Mono"
            font.pixelSize: 14
            font.weight:    Font.DemiBold
        }

        HoverHandler {
            onHoveredChanged: parent.opacity = hovered ? 0.8 : 1.0
        }
    }
}
