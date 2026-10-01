import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

Popup {
    id: settingsPanel
    width: 320
    height: 400
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    property var theme: ThemeLoader.theme
    
    background: Rectangle {
        color: theme.background
        radius: 8
        border.color: theme.border
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
                    color: theme.foreground
                }
                Text {
                    text: "Brightness"
                    font.pixelSize: 14
                    color: theme.foreground
                    Layout.fillWidth: true
                }
                Text {
                    text: Math.round(Brightness.value * 100) + "%"
                    font.pixelSize: 12
                    color: theme.accent
                }
            }
            
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: Brightness.value
                onValueChanged: Brightness.value = value
                
                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth
                    height: 4
                    radius: 2
                    color: theme.surface
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        color: theme.accent
                        radius: 2
                    }
                }
                
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: theme.accent
                }
            }
        }
        
        // Volume slider
        ColumnLayout {
            spacing: 8
            
            RowLayout {
                Text {
                    text: Audio.muted ? "󰖁" : "󰕾"
                    font.pixelSize: 18
                    color: theme.foreground
                }
                Text {
                    text: "Volume"
                    font.pixelSize: 14
                    color: theme.foreground
                    Layout.fillWidth: true
                }
                Text {
                    text: Math.round(Audio.volume * 100) + "%"
                    font.pixelSize: 12
                    color: theme.accent
                }
            }
            
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: Audio.volume
                onValueChanged: Audio.volume = value
                
                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth
                    height: 4
                    radius: 2
                    color: theme.surface
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        color: theme.accent
                        radius: 2
                    }
                }
                
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: theme.accent
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.border
        }
        
        // Quick toggles
        GridLayout {
            columns: 2
            columnSpacing: 12
            rowSpacing: 12
            Layout.fillWidth: true
            
            // WiFi toggle
            ToggleButton {
                icon: "󰖩"
                text: "WiFi"
                enabled: Network.wifiEnabled
                Layout.fillWidth: true
                onClicked: Network.toggleWifi()
            }
            
            // Bluetooth toggle
            ToggleButton {
                icon: "󰂯"
                text: "Bluetooth"
                enabled: Bluetooth.enabled
                Layout.fillWidth: true
                onClicked: Bluetooth.toggle()
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.border
        }
        
        // Action buttons
        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true
            
            ActionButton {
                icon: "󰹑"
                text: "Screenshot"
                Layout.fillWidth: true
                onClicked: {
                    Quickshell.exec(["grim", "-g", "$(slurp)", "-"], function(output) {
                        Quickshell.exec(["wl-copy"], function() {}, output)
                    })
                }
            }
            
            ActionButton {
                icon: "󰕧"
                text: "Screen Recording"
                Layout.fillWidth: true
                onClicked: {
                    // TODO: Implement screen recording
                    console.log("Screen recording not yet implemented")
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
                color: theme.foreground
                opacity: 0.7
            }
            
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                
                ThemeButton {
                    color: "#cba6f7"
                    name: "Catppuccin"
                    Layout.fillWidth: true
                    onClicked: Quickshell.exec(["bash", "-c", "cd ~/.config/arch-setup && ./scripts/apply-theme.sh catppuccin"])
                }
                
                ThemeButton {
                    color: "#fe8019"
                    name: "Gruvbox"
                    Layout.fillWidth: true
                    onClicked: Quickshell.exec(["bash", "-c", "cd ~/.config/arch-setup && ./scripts/apply-theme.sh gruvbox"])
                }
                
                ThemeButton {
                    color: "#88c0d0"
                    name: "Nord"
                    Layout.fillWidth: true
                    onClicked: Quickshell.exec(["bash", "-c", "cd ~/.config/arch-setup && ./scripts/apply-theme.sh nord"])
                }
                
                ThemeButton {
                    color: "#7aa2f7"
                    name: "Tokyo"
                    Layout.fillWidth: true
                    onClicked: Quickshell.exec(["bash", "-c", "cd ~/.config/arch-setup && ./scripts/apply-theme.sh tokyo-night"])
                }
            }
        }
    }
}

// Toggle button component
Component {
    id: toggleButtonComponent
    
    Rectangle {
        id: toggleButton
        property string icon: ""
        property string text: ""
        property bool enabled: false
        
        signal clicked()
        
        height: 60
        radius: 8
        color: mouseArea.pressed ? theme.surface : (enabled ? theme.accent + "40" : theme.surface)
        border.color: enabled ? theme.accent : theme.border
        border.width: 1
        
        Column {
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleButton.icon
                font.pixelSize: 24
                color: toggleButton.enabled ? theme.accent : theme.foreground
            }
            
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: toggleButton.text
                font.pixelSize: 11
                color: theme.foreground
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: toggleButton.clicked()
        }
    }
}

// Action button component
Component {
    id: actionButtonComponent
    
    Rectangle {
        id: actionButton
        property string icon: ""
        property string text: ""
        
        signal clicked()
        
        height: 40
        radius: 6
        color: mouseArea.pressed ? theme.surface : "transparent"
        border.color: theme.border
        border.width: 1
        
        Row {
            anchors.centerIn: parent
            spacing: 8
            
            Text {
                text: actionButton.icon
                font.pixelSize: 18
                color: theme.foreground
            }
            
            Text {
                text: actionButton.text
                font.pixelSize: 13
                color: theme.foreground
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: actionButton.clicked()
        }
    }
}

// Theme button component
Component {
    id: themeButtonComponent
    
    Rectangle {
        id: themeButton
        property color color: "#ffffff"
        property string name: ""
        
        signal clicked()
        
        height: 32
        radius: 4
        color: themeButton.color
        
        Text {
            anchors.centerIn: parent
            text: themeButton.name
            font.pixelSize: 10
            font.bold: true
            color: "#ffffff"
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: themeButton.clicked()
        }
    }
}
