// CAVA audio visualiser – mirrors custom/cava.
// Reuses the existing ~/.config/waybar/scripts/cava.sh script.
// Left-click  → playerctl previous
// Middle-click → playerctl play-pause
// Right-click → playerctl next
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string bars: "▁▂▃▄▅▆▇"

    implicitWidth:  barRow.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── CAVA process ─────────────────────────────────────────────────────────
    // Runs continuously; each output line is a new set of bars.
    Process {
        id: cavaProc
        command: ["bash", "-c", "~/.config/waybar/scripts/cava.sh"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                if (line.length > 0) root.bars = line
            }
        }

        // Auto-restart if the process dies unexpectedly
        onExited: running = true
    }

    // ── Playerctl helpers ─────────────────────────────────────────────────────
    Process { id: prevProc;  command: ["playerctl", "previous"];  running: false; onExited: running = false }
    Process { id: pauseProc; command: ["playerctl", "play-pause"]; running: false; onExited: running = false }
    Process { id: nextProc;  command: ["playerctl", "next"];      running: false; onExited: running = false }

    // ── Visual ───────────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
            leftMargin:   2
        }

        color:        Colors.backgroundPrimary
        radius:       12
        border.color: Colors.green
        border.width: 4

        Row {
            id: barRow
            anchors.centerIn: parent
            spacing: 4

            Text {
                text:           "♪"
                color:          Colors.green
                font.family:    "JetBrains Mono"
                font.pixelSize: 14
                font.weight:    Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text:           root.bars
                color:          Colors.green
                font.family:    "JetBrains Mono"
                font.pixelSize: 14
                font.weight:    Font.DemiBold
            }
        }

        MouseArea {
            anchors.fill:    parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            cursorShape:     Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton)      pauseProc.running = true
                else if (mouse.button === Qt.RightButton)  nextProc.running  = true
                else                                       prevProc.running  = true
            }

            HoverHandler {
                onHoveredChanged: parent.parent.opacity = hovered ? 0.8 : 1.0
            }
        }
    }
}
