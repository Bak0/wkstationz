import QtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    height: 40
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        opacity: 0.95
    }

    Row {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        // Left section - Workspace selector
        Row {
            spacing: 4

            Repeater {
                model: 9

                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: Hyprland.activeWorkspace.id === index + 1 ? "#cba6f7" : "#313244"

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: Hyprland.activeWorkspace.id === index + 1 ? "#1e1e2e" : "#cdd6f4"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("hl.dsp.focus({workspace = " + (index + 1) + "})")
                    }
                }
            }
        }

        Item { width: 20 }

        // Center section - Clock and Date (BIGGER and BOLDER)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: timeText
                text: Qt.formatTime(new Date(), "HH:mm")
                font.pixelSize: 24
                font.bold: true
                color: "#cdd6f4"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "ddd, MMM d")
                font.pixelSize: 14
                font.bold: true
                color: "#cdd6f4"
                opacity: 0.8
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    timeText.text = Qt.formatTime(new Date(), "HH:mm")
                    dateText.text = Qt.formatDate(new Date(), "ddd, MMM d")
                }
            }
        }

        Item { width: 20 }

        // Right section - Status indicators
        Row {
            anchors.right: parent.right
            spacing: 12

            // Audio indicator
            Text {
                text: "󰕾"
                font.pixelSize: 18
                color: "#cdd6f4"

                MouseArea {
                    anchors.fill: parent
                    onClicked: Quickshell.exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
                }
            }

            // Settings button
            Rectangle {
                width: 28
                height: 28
                radius: 4
                color: settingsButton.pressed ? "#cba6f7" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    font.pixelSize: 18
                    color: "#cdd6f4"
                }

                MouseArea {
                    id: settingsButton
                    anchors.fill: parent
                    onClicked: settingsPanel.visible = !settingsPanel.visible
                }
            }
        }
    }

    // Settings panel (dropdown)
    SettingsPanel {
        id: settingsPanel
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 8
        visible: false
    }
}
