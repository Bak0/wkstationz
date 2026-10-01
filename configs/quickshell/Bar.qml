import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

ShellRoot {
    id: root
    
    // Load theme
    property var theme: ThemeLoader.theme
    
    PanelWindow {
        id: bar
        anchors.top: true
        anchors.left: true
        anchors.right: true
        height: 40
        color: "transparent"
        
        // Background with blur
        Rectangle {
            anchors.fill: parent
            color: theme.background
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
                        color: Hyprland.activeWorkspace.id === index + 1 ? theme.accent : theme.surface
                        
                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: Hyprland.activeWorkspace.id === index + 1 ? theme.background : theme.foreground
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.switchWorkspace(index + 1)
                        }
                    }
                }
            }
            
            Item { width: 20 } // Spacer
            
            // Center section - Clock and Date (BIGGER and BOLDER)
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                
                Text {
                    id: timeText
                    text: Qt.formatTime(new Date(), "HH:mm")
                    font.pixelSize: 24
                    font.bold: true
                    color: theme.foreground
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    id: dateText
                    text: Qt.formatDate(new Date(), "ddd, MMM d")
                    font.pixelSize: 14
                    font.bold: true
                    color: theme.foreground
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
            
            Item { width: 20 } // Spacer
            
            // Right section - Status indicators
            Row {
                anchors.right: parent.right
                spacing: 12
                
                // Bluetooth indicator
                Text {
                    text: "󰂯"
                    font.pixelSize: 18
                    color: Bluetooth.connected ? theme.accent : theme.foreground
                    opacity: Bluetooth.enabled ? 1.0 : 0.4
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Bluetooth.toggle()
                    }
                }
                
                // Audio indicator
                Text {
                    text: Audio.muted ? "󰖁" : "󰕾"
                    font.pixelSize: 18
                    color: theme.foreground
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Audio.toggleMute()
                    }
                }
                
                // Settings button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 4
                    color: settingsButton.pressed ? theme.accent : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⚙"
                        font.pixelSize: 18
                        color: theme.foreground
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
}
