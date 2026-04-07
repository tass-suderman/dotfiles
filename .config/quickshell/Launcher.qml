// Launcher button – opens rofi in drun mode, mirroring custom/launcher.
import Quickshell.Io
import QtQuick

Item {
    id: root

    implicitWidth:  label.implicitWidth + 26
    implicitHeight: parent ? parent.height : 30

    // Reusable process for launching rofi
    Process {
        id: rofiProc
        command: ["rofi", "-show", "drun"]
        running: false
        onExited: running = false
    }

    Rectangle {
        anchors {
            fill:        parent
            topMargin:   2
            bottomMargin: 2
            leftMargin:  2
            rightMargin: 2
        }

        color:        Colors.backgroundSecondary
        radius:       12
        border.color: Colors.teal
        border.width: 2

        Text {
            id: label
            anchors.centerIn: parent
            text:             "󰣇"
            color:            Colors.blue
            // NerdFont glyph – use the Hack Nerd Font that waybar also uses
            font.family:      "Hack Nerd Font"
            font.pixelSize:   20
            font.weight:      Font.Bold
        }

        MouseArea {
            anchors.fill:  parent
            cursorShape:   Qt.PointingHandCursor
            onClicked:     rofiProc.running = true

            HoverHandler {
                onHoveredChanged: parent.parent.opacity = hovered ? 0.8 : 1.0
            }
        }
    }
}
