/**
 * Copyright (C) 2015 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/
import QtQuick 2.2
import QtGraphicalEffects 1.0

MouseArea {
    id: root
    width: button_background.width + 10
    height: button_background.height + 10
    hoverEnabled: true
    state: "normal"

    property alias label: txt.text

    property color borderColor: Qt.rgba(0, 0, 0, 1)
    property color contentColor: Qt.rgba(1, 1, 1, 1)

    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: root
                contentColor: Qt.rgba(1, 1, 1, 0.8)
                borderColor: Qt.rgba(1, 1, 1, 1)
            }
        },
        State {
            name: "hover"
            PropertyChanges {
                target: root
                contentColor: "#9AD7FF"
                borderColor: "#2AACF9"
            }
        },
        State {
            name: "press"
            PropertyChanges {
                target: root
                contentColor: "#68C3FF"
                borderColor: "#4A9FFF"
            }
        }
    ]

    onEntered: state = "hover"
    onExited: state = "normal"
    onPressed: state = "press"
    onReleased: state = "hover"

    Item {
        id: source_item
        anchors.fill: parent

        Rectangle {
            id: button_background

            width: Math.max(txt.implicitWidth + 10 * 2, 70)
            height: 22
            color: "transparent"
            radius: 3
            border.width: 1
            border.color: borderColor

            anchors.centerIn: parent

            Rectangle {
                x: 1
                y: 1
                width: parent.width - 2
                height: parent.height - 2
                color: contentColor
                radius: 2

                Text {
                    id: txt
                    font.pixelSize: 12

                    anchors.centerIn: parent
                }
            }
        }
    }

    DropShadow {
        anchors.fill: source_item
        verticalOffset: 2
        radius: 6.0
        samples: 16
        color: Qt.rgba(0, 0, 0, 0.3)
        source: source_item
    }
}