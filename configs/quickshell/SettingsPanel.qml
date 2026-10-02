import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Popup {
    id: settingsPanel

    width: 320
    height: 400
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: "#1e1e2e"
        radius: 8
        border.color: "#45475a"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 12
            samples: 25
            color: "#80000000"
            verticalOffset: 4
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Brightness slider
        ColumnLayout {
            spacing: 8

            RowLayout {
                Text {
                    text: "󰃠"
                    font.pixelSize: 18
                    color: "#cdd6f4"
                }
                Text {
                    text: "Brightness"
                    font.pixelSize: 14
                    color: "#cdd6f4"
                    Layout.fillWidth: true
                }
                Text {
                    text: "100%"
                    font.pixelSize: 12
                    color: "#cba6f7"
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: 1
                onValueChanged: Quickshell.exec("brightnessctl set " + Math.round(value * 100) + "%")
            }
        }

        // Volume slider
        ColumnLayout {
            spacing: 8

            RowLayout {
                Text {
                    text: "󰕾"
                    font.pixelSize: 18
                    color: "#cdd6f4"
                }
                Text {
                    text: "Volume"
                    font.pixelSize: 14
                    color: "#cdd6f4"
                    Layout.fillWidth: true
                }
                Text {
                    text: "50%"
                    font.pixelSize: 12
                    color: "#cba6f7"
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: 0.5
                onValueChanged: Quickshell.exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(value * 100) + "%")
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
        }

        // Quick toggles
        GridLayout {
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 8
                color: "#313244"
                border.color: "#45475a"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰖩"
                        font.pixelSize: 24
                        color: "#cdd6f4"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "WiFi"
                        font.pixelSize: 11
                        color: "#cdd6f4"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 8
                color: "#313244"
                border.color: "#45475a"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂯"
                        font.pixelSize: 24
                        color: "#cdd6f4"
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Bluetooth"
                        font.pixelSize: 11
                        color: "#cdd6f4"
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#45475a"
        }

        // Action buttons
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 6
                color: "#313244"
                border.color: "#45475a"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰹑"
                        font.pixelSize: 18
                        color: "#cdd6f4"
                    }

                    Text {
                        text: "Screenshot"
                        font.pixelSize: 13
                        color: "#cdd6f4"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Quickshell.exec("grim -g \"$(slurp)\" - | wl-copy")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 6
                color: "#313244"
                border.color: "#45475a"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: "󰕧"
                        font.pixelSize: 18
                        color: "#cdd6f4"
                    }

                    Text {
                        text: "Screen Recording"
                        font.pixelSize: 13
                        color: "#cdd6f4"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Quickshell.exec("wf-recorder -g \"$(slurp)\" -f ~/Videos/recording_$(date +%Y%m%d_%H%M%S).mp4")
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Theme switcher
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true

            Text {
                text: "Theme"
                font.pixelSize: 12
                color: "#cdd6f4"
                opacity: 0.7
            }

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: "#cba6f7"

                    Text {
                        anchors.centerIn: parent
                        text: "Catppuccin"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#1e1e2e"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.exec("bash -c 'cd ~/.config/wkstationz && ./scripts/apply-theme.sh catppuccin'")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: "#fe8019"

                    Text {
                        anchors.centerIn: parent
                        text: "Gruvbox"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#1e1e2e"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.exec("bash -c 'cd ~/.config/wkstationz && ./scripts/apply-theme.sh gruvbox'")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: "#88c0d0"

                    Text {
                        anchors.centerIn: parent
                        text: "Nord"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#1e1e2e"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.exec("bash -c 'cd ~/.config/wkstationz && ./scripts/apply-theme.sh nord'")
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 4
                    color: "#7aa2f7"

                    Text {
                        anchors.centerIn: parent
                        text: "Tokyo"
                        font.pixelSize: 10
                        font.bold: true
                        color: "#1e1e2e"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Quickshell.exec("bash -c 'cd ~/.config/wkstationz && ./scripts/apply-theme.sh tokyo-night'")
                    }
                }
            }
        }
    }
}
