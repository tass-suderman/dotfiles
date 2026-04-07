// Hyprland workspaces – mirrors hyprland/workspaces.
// Scroll up/down switches workspaces; clicking activates the workspace.
// Icons match the format-icons map from modules.jsonc.
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Map workspace id/name → nerd-font icon, matching modules.jsonc format-icons
    readonly property var icons: ({
        "1":     "󰻞",
        "2":     "",
        "3":     "",
        "code":  "",
        "magic": ""
    })

    function iconFor(ws) {
        return icons[ws.id.toString()] || icons[ws.name] || ws.id.toString()
    }

    implicitWidth:  wsRow.implicitWidth + 14
    implicitHeight: parent ? parent.height : 30

    // ── Visual ────────────────────────────────────────────────────────────────
    Rectangle {
        anchors {
            fill:        parent
            topMargin:   2
            bottomMargin: 2
        }

        color:        Colors.backgroundPrimary
        radius:       12
        border.color: Colors.borderColor
        border.width: 2

        RowLayout {
            id: wsRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                // Sort workspaces by ID for consistent ordering.
                // HyprlandWorkspace objects are accessible via Hyprland.workspaces.
                model: {
                    let list = []
                    for (let i = 0; i < Hyprland.workspaces.count; i++) {
                        list.push(Hyprland.workspaces.get(i))
                    }
                    list.sort((a, b) => a.id - b.id)
                    return list
                }

                delegate: Rectangle {
                    required property var modelData

                    property bool isActive: modelData.id === (Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1)
                    property bool isEmpty:  modelData.windowCount === 0

                    width:  wsIcon.implicitWidth + 20
                    height: 22
                    radius: 8

                    color: isActive
                           ? Colors.lavender
                           : isEmpty
                             ? Colors.backgroundSecondary
                             : Colors.backgroundPrimary

                    border.color: isActive ? Colors.blue : Colors.borderColor
                    border.width: 1
                    opacity:      isEmpty && !isActive ? 0.4 : 1.0

                    Behavior on color   { ColorAnimation { duration: 120 } }
                    Behavior on opacity { NumberAnimation { duration: 120 } }

                    Text {
                        id:             wsIcon
                        anchors.centerIn: parent
                        text:           root.iconFor(modelData)
                        color:          isActive ? Colors.base : Colors.subtext0
                        font.family:    "Hack Nerd Font"
                        font.pixelSize: 14
                        font.weight:    Font.Bold
                    }

                    MouseArea {
                        anchors.fill:    parent
                        acceptedButtons: Qt.LeftButton
                        cursorShape:     Qt.PointingHandCursor

                        onClicked:       Hyprland.dispatch("workspace " + modelData.id)

                        // Scroll up = previous workspace, scroll down = next workspace,
                        // matching waybar's on-scroll-up / on-scroll-down settings.
                        onWheel: (wheel) => {
                            if (wheel.angleDelta.y > 0)
                                Hyprland.dispatch("workspace r-1")
                            else
                                Hyprland.dispatch("workspace r+1")
                        }
                    }
                }
            }
        }
    }
}
