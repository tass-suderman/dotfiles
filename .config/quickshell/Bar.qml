// Top-level bar window – mirrors waybar config.jsonc layout:
//   left  : Launcher | Cava | Weather
//   center: Workspaces
//   right : Battery | Bluetooth | Audio | Clock | BarTray | Notifications
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Render on the bottom Wayland layer so app windows are always on top,
    // matching waybar's `"layer": "bottom"`.
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-bar"

    anchors {
        top:   true
        left:  true
        right: true
    }

    height: 30
    exclusiveZone: height

    // Transparent window background – the opaque pill is drawn by the child Rectangle.
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Colors.barBackground

        // 1-px bottom border, matching waybar's border-bottom
        Rectangle {
            anchors {
                bottom: parent.bottom
                left:   parent.left
                right:  parent.right
            }
            height: 1
            color:  Colors.barBorder
        }

        // ── Layout container ─────────────────────────────────────────────────
        Item {
            anchors.fill: parent

            // Left modules
            RowLayout {
                anchors {
                    left:           parent.left
                    leftMargin:     4
                    verticalCenter: parent.verticalCenter
                }
                height:  parent.height
                spacing: 4

                Launcher {}
                Cava {}
                Weather {}
            }

            // Center – workspaces, always centred regardless of left/right widths
            Workspaces {
                anchors.centerIn: parent
            }

            // Right modules
            RowLayout {
                anchors {
                    right:          parent.right
                    rightMargin:    4
                    verticalCenter: parent.verticalCenter
                }
                height:  parent.height
                spacing: 0

                Battery {}
                Bluetooth {}
                Audio {}
                Clock {}
                BarTray {}
                Notifications {}
            }
        }
    }
}
