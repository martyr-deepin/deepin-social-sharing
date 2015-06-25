import QtQuick 2.1

Item {
    id: toolButton
    width: 16
    height: 16
    state: "off"

    property url dirImage: "../../images/"
    property string imageName: ""

    property var toolImageOpacity: toolImage.opacity
    property bool toolImageEnabled: true
    property bool switchable: true
    property alias toolImage: toolImage
    property var group: null

    signal entered()
    signal exited()
    signal clicked()
    states: [
            State {
                    name : "on"
                    PropertyChanges {
                        target:toolImage
                        source: toolButton.dirImage + toolButton.imageName + "_press.svg"
                     }
            },
            State {
                    name : "off"
                    PropertyChanges {
                        target:toolImage
                        source: toolButton.dirImage + toolButton.imageName + "_normal.svg"
                    }
        }
    ]

    onStateChanged: if (group&&state == "on") group.checkState(toolButton)

    Image {
        id: toolImage
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        enabled: toolImageEnabled
        onEntered: {
            if (toolButton.state == "off") {
                toolImage.source = toolButton.dirImage + toolButton.imageName + "_hover.svg"
            }
            toolButton.entered()
        }

        onExited: {
            toolButton.exited()
        }

        onClicked:{
            if (switchable) {
                toolButton.state = toolButton.state == "on" ? "off" : "on"
            } else {
                toolButton.state = "on"
            }
            toolButton.clicked()
        }
    }
}


