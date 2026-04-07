// System tray – mirrors the waybar tray module.
// icon-size: 20, spacing: 10, show-passive-items: true (matching modules.jsonc).
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    implicitWidth:  trayRow.implicitWidth + 20
    implicitHeight: parent ? parent.height : 30

    // Hide entirely when the tray is empty
    visible: SystemTray.items.count > 0

    Rectangle {
        anchors {
            fill:         parent
            topMargin:    6
            bottomMargin: 6
        }

        color: Colors.backgroundPrimary

        RowLayout {
            id: trayRow
            anchors.centerIn: parent
            spacing: 10

            Repeater {
                model: SystemTray.items

                delegate: Item {
                    required property SystemTrayItem modelData

                    // Passive items are shown at reduced opacity (show-passive-items: true)
                    opacity: modelData.status === SystemTrayItem.Passive ? 0.7 : 1.0

                    width:  20
                    height: 20

                    // Tray icon
                    Image {
                        anchors.fill: parent
                        source:       modelData.icon
                        smooth:       true
                        mipmap:       true
                    }

                    // Attention indicator – red background for "needs attention" items
                    Rectangle {
                        visible:     modelData.status === SystemTrayItem.NeedsAttention
                        anchors.fill: parent
                        color:       Colors.error
                        opacity:     0.35
                        radius:      6
                    }

                    MouseArea {
                        id:              trayItemMouseArea
                        anchors.fill:    parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape:     Qt.PointingHandCursor
                        hoverEnabled:    true

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton)
                                modelData.activate(mouse.x, mouse.y)
                            else
                                modelData.secondaryActivate(mouse.x, mouse.y)
                        }

                        onWheel: (wheel) => {
                            modelData.scroll(
                                wheel.angleDelta.x,
                                wheel.angleDelta.y
                            )
                        }
                    }

                    // Item tooltip
                    ToolTip {
                        visible: trayItemMouseArea.containsMouse
                        text:    modelData.tooltipTitle || modelData.title || ""
                        delay:   600
                    }
                }
            }
        }
    }
}
