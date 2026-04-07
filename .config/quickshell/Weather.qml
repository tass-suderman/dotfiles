// Weather widget – mirrors custom/weather.
// Reuses the existing ~/.config/waybar/scripts/openweathermap.sh script.
// Refreshes every 30 minutes, matching waybar's interval of 1800.
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string weatherText: "󰖙 Loading…"

    implicitWidth:  weatherLabel.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // ── Fetch timer ───────────────────────────────────────────────────────────
    Timer {
        interval:         1800000 // 30 minutes
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered:      weatherProc.running = true
    }

    Process {
        id: weatherProc
        command: ["bash", "-c", "~/.config/waybar/scripts/openweathermap.sh"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                if (line.length > 0) root.weatherText = line
            }
        }

        onExited: running = false
    }

    // ── Visual ────────────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
            rightMargin:  2
        }

        color:        Colors.backgroundPrimary
        radius:       12
        border.color: Colors.blue
        border.width: 4

        Text {
            id:             weatherLabel
            anchors.centerIn: parent
            text:           root.weatherText
            color:          Colors.blue
            font.family:    "JetBrains Mono"
            font.pixelSize: 14
            font.weight:    Font.DemiBold
        }

        HoverHandler {
            onHoveredChanged: parent.opacity = hovered ? 0.8 : 1.0
        }
    }
}
